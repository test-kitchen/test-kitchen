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
        url << "&v=#{CGI.escape(version.to_s.downcase)}"
        url
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

        shell_code_from_file(vars, "chef_base_init_command")
      end

      # (see Base#install_command)
      def install_command
        return unless config[:require_chef_omnibus]

        version = config[:require_chef_omnibus].to_s.downcase

        vars = if powershell_shell?
          install_command_vars_for_powershell(version)
        else
          install_command_vars_for_bourne(version)
        end

        shell_code_from_file(vars, "chef_base_install_command")
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

      # Generates the install command variables for Bourne shell-based
      # platforms.
      #
      # @param version [String] version string
      # @return [String] shell variable lines
      # @api private
      def install_command_vars_for_bourne(version)
        install_flags = %w[latest true].include?(version) ? "" : "-v #{CGI.escape(version)}"
        if config[:chef_omnibus_install_options]
          install_flags << " " << config[:chef_omnibus_install_options]
        end

        [
          shell_var("chef_omnibus_root", config[:chef_omnibus_root]),
          shell_var("chef_omnibus_url", config[:chef_omnibus_url]),
          shell_var("install_flags", install_flags.strip),
          shell_var("pretty_version", pretty_version(version)),
          shell_var("sudo_sh", sudo("sh")),
          shell_var("version", version)
        ].join("\n")
      end

      # Generates the install command variables for PowerShell-based platforms.
      #
      # @param version [String] version string
      # @return [String] shell variable lines
      # @api private
      def install_command_vars_for_powershell(version)
        [
          shell_var("chef_metadata_url", config[:chef_metadata_url]),
          shell_var("chef_omnibus_root", config[:chef_omnibus_root]),
          shell_var("msi", "$env:TEMP\\chef-#{version}.msi"),
          shell_var("pretty_version", pretty_version(version)),
          shell_var("version", version)
        ].join("\n")
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

      # @return [String] a powershell command to reload the `PATH` environment
      #   variable, only to be used to support old Omnibus Chef packages that
      #   require `PATH` to find the `ruby.exe` binary
      # @api private
      def reload_ps1_path
        [
          %{$env:PATH},
          %{[System.Environment]::GetEnvironmentVariable("PATH","Machine")\n\n}
        ].join(" = ")
      end
    end
  end
end
