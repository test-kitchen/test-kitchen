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

require "kitchen/provisioner/chef/berkshelf"
require "kitchen/provisioner/chef/common_sandbox"
require "kitchen/provisioner/chef/librarian"
require "kitchen/util"

module Kitchen

  module Provisioner

    # Common implementation details for Chef-related provisioners.
    #
    # @author Fletcher Nichol <fnichol@nichol.ca>
    class ChefBase < Base

      default_config :require_chef_omnibus, true
      default_config :chef_omnibus_url, "https://www.chef.io/chef/install.sh"
      default_config :chef_omnibus_install_options, nil
      default_config :run_list, []
      default_config :attributes, {}
      default_config :log_file, nil
      default_config :cookbook_files_glob, %w[
        README.* metadata.{json,rb}
        attributes/**/* definitions/**/* files/**/* libraries/**/*
        providers/**/* recipes/**/* resources/**/* templates/**/*
      ].join(",")

      default_config :chef_metadata_url do |provisioner|
        provisioner.default_windows_chef_metadata_url if provisioner.windows_os?
      end

      default_config :chef_omnibus_root do |provisioner|
        if provisioner.windows_os?
          "$env:systemdrive\\opscode\\chef"
        else
          "/opt/chef"
        end
      end

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

      # (see Base#create_sandbox)
      def create_sandbox
        super
        Chef::CommonSandbox.new(config, sandbox_path, instance).populate
      end

      # @return [String] a metadata URL for the Chef Omnitruck API suitable
      #   for installing a Windows MSI package
      def default_windows_chef_metadata_url
        version = config[:require_chef_omnibus]
        version = "latest" if version == true
        base = if config[:chef_omnibus_url] =~ %r{/install.sh$}
          "#{File.dirname(config[:chef_omnibus_url])}/"
        else
          "https://www.chef.io/chef/"
        end

        url = "#{base}#{metadata_project_from_options}"
        url << "?p=windows&m=x86_64&pv=2008r2" # same pacakge for all versions
        url << "&v=#{version.to_s.downcase}"
        url
      end

      # (see Base#init_command)
      def init_command
        dirs = %w[cookbooks data data_bags environments roles clients].
          sort.map { |dir| remote_path_join(config[:root_path], dir) }

        if powershell_shell?
          init_command_for_powershell(dirs)
        else
          init_command_for_bourne(dirs)
        end
      end

      # (see Base#install_command)
      def install_command
        return unless config[:require_chef_omnibus]

        if powershell_shell?
          install_command_for_powershell
        else
          install_command_for_bourne
        end
      end

      private

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
          )
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
        if obj.is_a?(String)
          %{"#{obj.gsub(/\\/, "\\\\\\\\")}"}
        elsif obj.is_a?(Array)
          %{[#{obj.map { |i| format_value(i) }.join(", ")}]}
        else
          obj.inspect
        end
      end

      # Generates the init command for Bourne shell-based platforms.
      #
      # @param dirs [Array<String>] directories
      # @return [String] command
      # @api private
      def init_command_for_bourne(dirs)
        vars = Util.outdent!(<<-VARS)
          sudo_rm="#{sudo("rm")}"
          dirs="#{dirs.join(" ")}"
          root_path="#{config[:root_path]}"
        VARS

        Util.wrap_command(shell_code(vars, "chef_base_init_command.sh"))
      end

      # Generates the init command for PowerShell-based platforms.
      #
      # @param dirs [Array<String>] directories
      # @return [String] command
      # @api private
      def init_command_for_powershell(dirs)
        vars = Util.outdent!(<<-VARS)
          $dirs = @(#{dirs.map { |d| %{"#{d}"} }.join(", ")})
          $root_path = "#{config[:root_path]}"
        VARS

        shell_code(vars, "chef_base_init_command.ps1")
      end

      # Generates the install command for Bourne shell-based platforms.
      #
      # @return [String] command
      # @api private
      def install_command_for_bourne
        version = config[:require_chef_omnibus].to_s.downcase
        install_flags = %w[latest true].include?(version) ? "" : "-v #{version}"
        if config[:chef_omnibus_install_options]
          install_flags << " " << config[:chef_omnibus_install_options]
        end

        vars = Util.outdent!(<<-BOURNE_VARS)
          chef_omnibus_root="#{config[:chef_omnibus_root]}"
          chef_omnibus_url="#{config[:chef_omnibus_url]}"
          install_flags="#{install_flags.strip}"
          pretty_version="#{pretty_version(version)}"
          sudo_sh="#{sudo("sh")}"
          version="#{version}"
        BOURNE_VARS

        Util.wrap_command(shell_code(vars, "chef_base_install_command.sh"))
      end

      # Generates the install command for PowerShell-based platforms.
      #
      # @return [String] command
      # @api private
      def install_command_for_powershell
        version = config[:require_chef_omnibus].to_s.downcase

        vars = Util.outdent!(<<-POWERSHELL_VARS)
          $env:http_proxy = "#{config[:http_proxy]}"
          $env:https_proxy = "#{config[:https_proxy]}"
          $chef_metadata_url = "#{config[:chef_metadata_url]}"
          $chef_omnibus_root = "#{config[:chef_omnibus_root]}"
          $msi = "$env:TEMP\\chef-#{version}.msi"
          $pretty_version = "#{pretty_version(version)}"
          $version = "#{version}"
        POWERSHELL_VARS

        shell_code(vars, "chef_base_install_command.ps1")
      end

      # Load cookbook dependency resolver code, if required.
      #
      # (see Base#load_needed_dependencies!)
      def load_needed_dependencies!
        super
        if File.exist?(berksfile)
          debug("Berksfile found at #{berksfile}, loading Berkshelf")
          Chef::Berkshelf.load!(logger)
        elsif File.exist?(cheffile)
          debug("Cheffile found at #{cheffile}, loading Librarian-Chef")
          Chef::Librarian.load!(logger)
        end
      end

      # @return the correct Chef Omnitruck API metadata endpoint, based on
      #   project type which could live in
      #   `config[:chef_omnibus_install_options]`
      # @api private
      def metadata_project_from_options
        match = /\s*-P (\w+)\s*/.match(config[:chef_omnibus_install_options])

        if match.nil? || match[1].downcase == "chef"
          "metadata"
        else
          "metadata-#{match[1].downcase}"
        end
      end

      # @return [String] a pretty/helpful representation of a Chef Omnibus
      #   package version
      # @api private
      def pretty_version(version)
        case version
        when "true" then "install only if missing"
        when "latest" then "always install latest version"
        else version
        end
      end

      # Builds a complete command given a variables String preamble and a file
      # containing shell code.
      #
      # @param vars [String] shell variables, as a String
      # @param file [String] file basename containing shell code
      # @return [String] command
      # @api private
      def shell_code(vars, file)
        [
          "",
          vars,
          IO.read(File.join(File.dirname(__FILE__), %w[.. .. .. support], file))
        ].join("\n")
      end
    end
  end
end
