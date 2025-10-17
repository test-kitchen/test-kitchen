# frozen_string_literal: true
#
# Author:: Fletcher Nichol (<fnichol@nichol.ca>)
#
# Copyright (C) 2013, Fletcher Nichol
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require_relative "chef_base"
require "kitchen/licensing/base"

module Kitchen
  module Provisioner
    # Chef Zero provisioner.
    #
    # @author Fletcher Nichol <fnichol@nichol.ca>
    class ChefInfra < ChefBase

      kitchen_provisioner_api_version 2

      plugin_version Kitchen::VERSION

      default_config :client_rb, {}
      default_config :named_run_list, {}
      default_config :json_attributes, true
      default_config :chef_zero_host, nil
      default_config :chef_zero_port, 8889
      default_config :chef_license_key, nil
      default_config :chef_license_server, []

      default_config :chef_client_path do |provisioner|
        provisioner
          .remote_path_join(%W{#{provisioner[:chef_omnibus_root]} bin chef-client})
          .tap { |path| path.concat(".bat") if provisioner.windows_os? }
      end

      default_config :ruby_bindir do |provisioner|
        provisioner
          .remote_path_join(%W{#{provisioner[:chef_omnibus_root]} embedded bin})
      end

      # (see Base#create_sandbox)
      def create_sandbox
        super
        prepare_validation_pem
        prepare_config_rb
      end

      def run_command
        cmd = "#{context_env_command} #{sudo(config[:chef_client_path])} --local-mode "

        chef_cmd(cmd)
      end

      def check_license
        super

        info("Fetching the Chef license key")
        unless config[:chef_license_server].nil? || config[:chef_license_server].empty?
          ENV["CHEF_LICENSE_SERVER"] = config[:chef_license_server].join(",")
        end

        key, type, install_sh_url = if config[:chef_license_key].nil?
                                      Licensing::Base.get_license_keys
                                    else
                                      key = config[:chef_license_key]
                                      client = Licensing::Base.get_license_client([key])

                                      [key, client.license_type, Licensing::Base.install_sh_url(client.license_type, [key])]
                                    end

        info("Chef license key: #{key}")
        config[:chef_license_key] = key
        config[:install_sh_url] = install_sh_url
        config[:chef_license_type] = type
      end

      def chef_license_key
        config[:chef_license_key]
      end

      def chef_license_server
        config[:chef_license_server]
      end

      private

      # Adds optional flags to a chef-client command, depending on
      # configuration data. Note that this method mutates the incoming Array.
      #
      # @param args [Array<String>] array of flags
      # @api private
      # rubocop:disable Metrics/CyclomaticComplexity
      def add_optional_chef_client_args!(args)
        if config[:json_attributes]
          json = remote_path_join(config[:root_path], "dna.json")
          args << "--json-attributes #{json}"
        end

        args << "--logfile #{config[:log_file]}" if config[:log_file]

        # these flags are chef-client local mode only and will not work
        # on older versions of chef-client
        if config[:chef_zero_host]
          args << "--chef-zero-host #{config[:chef_zero_host]}"
        end

        if config[:chef_zero_port]
          args << "--chef-zero-port #{config[:chef_zero_port]}"
        end

        args << "--profile-ruby" if config[:profile_ruby]

        if config[:slow_resource_report]
          if config[:slow_resource_report].is_a?(Integer)
            args << "--slow-report #{config[:slow_resource_report]}"
          else
            args << "--slow-report"
          end
        end
      end
      # rubocop:enable Metrics/CyclomaticComplexity

      # Returns an Array of command line arguments for the chef client.
      #
      # @return [Array<String>] an array of command line arguments
      # @api private
      def chef_args(client_rb_filename)
        level = config[:log_level]
        args = [
            "--config #{remote_path_join(config[:root_path], client_rb_filename)}",
            "--log_level #{level}",
            "--force-formatter",
            "--no-color",
        ]
        add_optional_chef_client_args!(args)

        args
      end

      # Generates a string of shell environment variables needed for the
      # chef-client-zero.rb shim script to properly function.
      #
      # @return [String] a shell script string
      # @api private
      def chef_client_zero_env
        root = config[:root_path]
        gem_home = gem_path = remote_path_join(root, "chef-client-zero-gems")
        gem_cache = remote_path_join(gem_home, "cache")

        [
            shell_env_var("CHEF_REPO_PATH", root),
            shell_env_var("GEM_HOME", gem_home),
            shell_env_var("GEM_PATH", gem_path),
            shell_env_var("GEM_CACHE", gem_cache),
        ].join("\n").concat("\n")
      end

      # Writes a fake (but valid) validation.pem into the sandbox directory.
      #
      # @api private
      def prepare_validation_pem
        info("Preparing validation.pem")
        debug("Using a dummy validation.pem")

        source = File.join(File.dirname(__FILE__),
          %w{.. .. .. support dummy-validation.pem})
        FileUtils.cp(source, File.join(sandbox_path, "validation.pem"))
      end

      # Returns the command that will run a backwards compatible shim script
      # that approximates local mode in a modern chef-client run.
      #
      # @return [String] the command string
      # @api private
      def shim_command
        ruby = remote_path_join(config[:ruby_bindir], "ruby")
          .tap { |path| path.concat(".exe") if windows_os? }
        shim = remote_path_join(config[:root_path], "chef-client-zero.rb")

        "#{chef_client_zero_env}\n#{sudo(ruby)} #{shim}"
      end

      # This provisioner supports policyfiles, so override the default (which
      # is false)
      # @return [true] always returns true
      # @api private
      def supports_policyfile?
        true
      end

      def context_env_command
        if powershell_shell?
          "$env:IS_KITCHEN = 'true'; &"
        else
          "export IS_KITCHEN='true'; "
        end
      end
    end
  end
end
