# -*- encoding: utf-8 -*-
#
# Author:: Fletcher Nichol (<fnichol@nichol.ca>)
#
# Copyright (C) 2013, Fletcher Nichol
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "fileutils"
require "pathname"
require "json"
require "cgi"

require "kitchen/provisioner/chef/policyfile"
require "kitchen/provisioner/chef/berkshelf"
require "kitchen/provisioner/chef/common_sandbox"
require "kitchen/provisioner/chef/librarian"
require "kitchen/util"
require "mixlib/install"
require "mixlib/install/script_generator"

begin
  require "chef-config/config"
  require "chef-config/workstation_config_loader"
rescue LoadError # rubocop:disable Lint/HandleExceptions
  # This space left intentionally blank.
end

module Kitchen

  module Provisioner

    # Common implementation details for Chef-related provisioners.
    #
    # @author Fletcher Nichol <fnichol@nichol.ca>
    class ChefBase < Base

      default_config :require_chef_omnibus, true
      default_config :chef_omnibus_url, "https://omnitruck.chef.io/install.sh"
      default_config :chef_omnibus_install_options, nil
      default_config :run_list, []
      default_config :attributes, {}
      default_config :config_path, nil
      default_config :log_file, nil
      default_config :log_level, "auto"
      default_config :profile_ruby, false
      # The older policyfile_zero used `policyfile` so support it for compat.
      default_config :policyfile, nil
      # Will try to autodetect by searching for `Policyfile.rb` if not set.
      # If set, will error if the file doesn't exist.
      default_config :policyfile_path, nil
      # If set to true (which is the default from `chef generate`), try to update
      # backend cookbook downloader on every kitchen run.
      default_config :always_update_cookbooks, false
      default_config :cookbook_files_glob, %w[
        README.* metadata.{json,rb}
        attributes/**/* definitions/**/* files/**/* libraries/**/*
        providers/**/* recipes/**/* resources/**/* templates/**/*
      ].join(",")
      # to ease upgrades, allow the user to turn deprecation warnings into errors
      default_config :deprecations_as_errors, false

      default_config :data_path do |provisioner|
        provisioner.calculate_path("data")
      end
      expand_path_for :data_path

      default_config :data_bags_path do |provisioner|
        provisioner.calculate_path("data_bags")
      end
      expand_path_for :data_bags_path

      default_config :environments_path do |provisioner|
        provisioner.calculate_path("environments")
      end
      expand_path_for :environments_path

      default_config :nodes_path do |provisioner|
        provisioner.calculate_path("nodes")
      end
      expand_path_for :nodes_path

      default_config :roles_path do |provisioner|
        provisioner.calculate_path("roles")
      end
      expand_path_for :roles_path

      default_config :clients_path do |provisioner|
        provisioner.calculate_path("clients")
      end
      expand_path_for :clients_path

      default_config :encrypted_data_bag_secret_key_path do |provisioner|
        provisioner.calculate_path("encrypted_data_bag_secret_key", :type => :file)
      end
      expand_path_for :encrypted_data_bag_secret_key_path

      # Reads the local Chef::Config object (if present).  We do this because
      # we want to start bring Chef config and ChefDK tool config closer
      # together.  For example, we want to configure proxy settings in 1
      # location instead of 3 configuration files.
      #
      # @param config [Hash] initial provided configuration
      def initialize(config = {})
        super(config)

        if defined?(ChefConfig::WorkstationConfigLoader)
          ChefConfig::WorkstationConfigLoader.new(config[:config_path]).load
        end
        # This exports any proxy config present in the Chef config to
        # appropriate environment variables, which Test Kitchen respects
        ChefConfig::Config.export_proxies if defined?(ChefConfig::Config.export_proxies)
      end

      # (see Base#create_sandbox)
      def create_sandbox
        super
        sanity_check_sandbox_options!
        Chef::CommonSandbox.new(config, sandbox_path, instance).populate
      end

      # (see Base#init_command)
      def init_command
        dirs = %w[
          cookbooks data data_bags environments roles clients
          encrypted_data_bag_secret
        ].sort.map { |dir| remote_path_join(config[:root_path], dir) }

        vars = if powershell_shell?
          init_command_vars_for_powershell(dirs)
        else
          init_command_vars_for_bourne(dirs)
        end

        prefix_command(shell_code_from_file(vars, "chef_base_init_command"))
      end

      # (see Base#install_command)
      def install_command
        return unless config[:require_chef_omnibus] || config[:product_name]
        prefix_command(sudo(install_script_contents))
      end

      private

      # @return [Hash] an option hash for the install commands
      # @api private
      def install_options
        project = /\s*-P (\w+)\s*/.match(config[:chef_omnibus_install_options])
        {
          :omnibus_url => config[:chef_omnibus_url],
          :project => project.nil? ? nil : project[1],
          :install_flags => config[:chef_omnibus_install_options],
          :sudo_command => sudo_command
        }.tap do |opts|
          opts[:root] = config[:chef_omnibus_root] if config.key? :chef_omnibus_root
          [:install_msi_url, :http_proxy, :https_proxy].each do |key|
            opts[key] = config[key] if config.key? key
          end
        end
      end

      # @return [String] an absolute path to a Policyfile, relative to the
      #   kitchen root
      # @api private
      def policyfile
        policyfile_basename = config[:policyfile_path] || config[:policyfile] || "Policyfile.rb"
        File.join(config[:kitchen_root], policyfile_basename)
      end

      # @return [String] an absolute path to a Berksfile, relative to the
      #   kitchen root
      # @api private
      def berksfile
        File.join(config[:kitchen_root], "Berksfile")
      end

      # @return [String] an absolute path to a Cheffile, relative to the
      #   kitchen root
      # @api private
      def cheffile
        File.join(config[:kitchen_root], "Cheffile")
      end

      # Generates a Hash with default values for a solo.rb or client.rb Chef
      # configuration file.
      #
      # @return [Hash] a configuration hash
      # @api private
      def default_config_rb # rubocop:disable Metrics/MethodLength
        root = config[:root_path].gsub("$env:TEMP", "\#{ENV['TEMP']\}")

        {
          :node_name        => instance.name,
          :checksum_path    => remote_path_join(root, "checksums"),
          :file_cache_path  => remote_path_join(root, "cache"),
          :file_backup_path => remote_path_join(root, "backup"),
          :cookbook_path    => [
            remote_path_join(root, "cookbooks"),
            remote_path_join(root, "site-cookbooks")
          ],
          :data_bag_path    => remote_path_join(root, "data_bags"),
          :environment_path => remote_path_join(root, "environments"),
          :node_path        => remote_path_join(root, "nodes"),
          :role_path        => remote_path_join(root, "roles"),
          :client_path      => remote_path_join(root, "clients"),
          :user_path        => remote_path_join(root, "users"),
          :validation_key   => remote_path_join(root, "validation.pem"),
          :client_key       => remote_path_join(root, "client.pem"),
          :chef_server_url  => "http://127.0.0.1:8889",
          :encrypted_data_bag_secret => remote_path_join(
            root, "encrypted_data_bag_secret"
          ),
          :treat_deprecation_warnings_as_errors => config[:deprecations_as_errors]
        }
      end

      # Generates a rendered client.rb/solo.rb/knife.rb formatted file as a
      # String.
      #
      # @param data [Hash] a key/value pair hash of configuration
      # @return [String] a rendered Chef config file as a String
      # @api private
      def format_config_file(data)
        data.each.map { |attr, value|
          [attr, format_value(value)].join(" ")
        }.join("\n")
      end

      # Converts a Ruby object to a String interpretation suitable for writing
      # out to a client.rb/solo.rb/knife.rb file.
      #
      # @param obj [Object] an object
      # @return [String] a string representation
      # @api private
      def format_value(obj)
        if obj.is_a?(String) && obj =~ /^:/
          obj
        elsif obj.is_a?(String)
          %{"#{obj.gsub(/\\/, "\\\\\\\\")}"}
        elsif obj.is_a?(Array)
          %{[#{obj.map { |i| format_value(i) }.join(", ")}]}
        else
          obj.inspect
        end
      end

      # Generates the init command variables for Bourne shell-based platforms.
      #
      # @param dirs [Array<String>] directories
      # @return [String] shell variable lines
      # @api private
      def init_command_vars_for_bourne(dirs)
        [
          shell_var("sudo_rm", sudo("rm")),
          shell_var("dirs", dirs.join(" ")),
          shell_var("root_path", config[:root_path])
        ].join("\n")
      end

      # Generates the init command variables for PowerShell-based platforms.
      #
      # @param dirs [Array<String>] directories
      # @return [String] shell variable lines
      # @api private
      def init_command_vars_for_powershell(dirs)
        [
          %{$dirs = @(#{dirs.map { |d| %{"#{d}"} }.join(", ")})},
          shell_var("root_path", config[:root_path])
        ].join("\n")
      end

      # Load cookbook dependency resolver code, if required.
      #
      # (see Base#load_needed_dependencies!)
      def load_needed_dependencies!
        super
        if File.exist?(policyfile)
          debug("Policyfile found at #{policyfile}, using Policyfile to resolve dependencies")
          Chef::Policyfile.load!(:logger => logger)
        elsif File.exist?(berksfile)
          debug("Berksfile found at #{berksfile}, loading Berkshelf")
          Chef::Berkshelf.load!(:logger => logger)
        elsif File.exist?(cheffile)
          debug("Cheffile found at #{cheffile}, loading Librarian-Chef")
          Chef::Librarian.load!(:logger => logger)
        end
      end

      # @return [String] contents of the install script
      # @api private
      def install_script_contents
        # by default require_chef_omnibus is set to true. Check config[:product_name] first
        # so that we can use it if configured.
        if config[:product_name]
          script_for_product
        elsif config[:require_chef_omnibus]
          script_for_omnibus_version
        end
      end

      # @return [String] contents of product based install script
      # @api private
      def script_for_product
        installer = Mixlib::Install.new({
          :product_name => config[:product_name],
          :product_version => config[:product_version],
          :channel => (config[:channel] || :stable).to_sym
        }.tap do |opts|
          opts[:shell_type] = :ps1 if powershell_shell?
          [:platform, :platform_version, :architecture].each do |key|
            opts[key] = config[key] if config[key]
          end
        end)
        config[:chef_omnibus_root] = installer.root
        if powershell_shell?
          installer.install_command
        else
          install_from_file(installer.install_command)
        end
      end

      def install_from_file(command)
        install_file = "/tmp/chef-installer.sh"
        script = ["cat > #{install_file} <<\"EOL\""]
        script << "#!/bin/bash"
        script << command
        script << "EOL"
        script << "chmod +x #{install_file}"
        script << sudo(install_file)
        script.join("\n")
      end

      # @return [String] contents of version based install script
      # @api private
      def script_for_omnibus_version
        installer = Mixlib::Install::ScriptGenerator.new(
          config[:require_chef_omnibus], powershell_shell?, install_options)
        config[:chef_omnibus_root] = installer.root
        installer.install_command
      end

      # Hook used in subclasses to indicate support for policyfiles.
      #
      # @abstract
      # @return [Boolean]
      # @api private
      def supports_policyfile?
        false
      end

      # @return [void]
      # @raise [UserError]
      # @api private
      def sanity_check_sandbox_options!
        if (config[:policyfile_path] || config[:policyfile]) && !File.exist?(policyfile)
          raise UserError, "policyfile_path set in config "\
            "(#{config[:policyfile_path]} could not be found. " \
            "Expected to find it at full path #{policyfile} " \
        end
        if File.exist?(policyfile) && !supports_policyfile?
          raise UserError, "policyfile detected, but provisioner " \
            "#{self.class.name} doesn't support policyfiles. " \
            "Either use a different provisioner, or delete/rename " \
            "#{policyfile}"
        end
      end
    end
  end
end
