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

require "kitchen/provisioner/chef_base"

module Kitchen

  module Provisioner

    # Chef Zero provisioner.
    #
    # @author Fletcher Nichol <fnichol@nichol.ca>
    class ChefZero < ChefBase

      kitchen_provisioner_api_version 2

      plugin_version Kitchen::VERSION

      default_config :client_rb, {}
      default_config :named_run_list, {}
      default_config :json_attributes, true
      default_config :chef_zero_host, nil
      default_config :chef_zero_port, 8889

      default_config :chef_client_path do |provisioner|
        provisioner.
          remote_path_join(%W[#{provisioner[:chef_omnibus_root]} bin chef-client]).
          tap { |path| path.concat(".bat") if provisioner.windows_os? }
      end

      default_config :ruby_bindir do |provisioner|
        provisioner.
          remote_path_join(%W[#{provisioner[:chef_omnibus_root]} embedded bin])
      end

      # (see Base#create_sandbox)
      def create_sandbox
        super
        prepare_chef_client_zero_rb
        prepare_validation_pem
        prepare_client_rb
      end

      # (see Base#prepare_command)
      def prepare_command
        return if modern?

        gem_bin = remote_path_join(config[:ruby_bindir], "gem").
          tap { |path| path.concat(".bat") if windows_os? }
        vars = [
          chef_client_zero_env,
          shell_var("gem", sudo(gem_bin))
        ].join("\n").concat("\n")

        prefix_command(shell_code_from_file(vars, "chef_zero_prepare_command_legacy"))
      end

      # (see Base#run_command)
      def run_command
        cmd = modern? ? local_mode_command : shim_command

        prefix_command(
          wrap_shell_code(
            [cmd, *chef_client_args, last_exit_code].join(" ").
            tap { |str| str.insert(0, reload_ps1_path) if windows_os? }
          )
        )
      end

      private

      def last_exit_code
        "; exit $LastExitCode" if powershell_shell?
      end

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
        if config[:log_file]
          args << "--logfile #{config[:log_file]}"
        end
        return unless modern?

        # these flags are modern/chef-client local most only and will not work
        # on older versions of chef-client
        if config[:chef_zero_host]
          args << "--chef-zero-host #{config[:chef_zero_host]}"
        end
        if config[:chef_zero_port]
          args << "--chef-zero-port #{config[:chef_zero_port]}"
        end
        if config[:profile_ruby]
          args << "--profile-ruby"
        end
      end
      # rubocop:enable Metrics/CyclomaticComplexity

      # Returns an Array of command line arguments for the chef client.
      #
      # @return [Array<String>] an array of command line arguments
      # @api private
      def chef_client_args
        level = config[:log_level]
        args = [
          "--config #{remote_path_join(config[:root_path], "client.rb")}",
          "--log_level #{level}",
          "--force-formatter",
          "--no-color"
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
          shell_env_var("GEM_CACHE", gem_cache)
        ].join("\n").concat("\n")
      end

      # Returns the command that will run chef client in local mode (a.k.a.
      # chef zero mode).
      #
      # @return [String] the command string
      # @api private
      def local_mode_command
        "#{sudo(config[:chef_client_path])} --local-mode".
          tap { |str| str.insert(0, "& ") if powershell_shell? }
      end

      # Determines whether or not local mode (a.k.a chef zero mode) is
      # supported in the version of Chef as determined by inspecting the
      # require_chef_omnibus config variable.
      #
      # The only way this method returns false is if require_chef_omnibus has
      # an explicit version set to less than 11.8.0, when chef zero mode was
      # introduced. Otherwise a modern Chef installation is assumed.
      #
      # @return [true,false] whether or not the desired version of Chef
      #   supports local mode
      # @api private
      def modern?
        version = config[:require_chef_omnibus]

        case version
        when nil, false, true, 11, "11", "latest"
          true
        else
          if Gem::Version.correct?(version)
            Gem::Version.new(version) >= Gem::Version.new("11.8.0") ? true : false
          else
            # Build versions of chef, for example
            # 12.5.0-current.0+20150721082808.git.14.c91b337-1
            true
          end
        end
      end

      # Writes a chef-client local-mode shim script to the sandbox directory
      # only if the desired version of Chef is old enough. The version of Chef
      # is determined using the `config[:require_chef_omnibus]` value.
      #
      # @api private
      def prepare_chef_client_zero_rb
        return if modern?

        info("Preparing chef-client-zero.rb")
        debug("Using a vendored chef-client-zero.rb")

        source = File.join(File.dirname(__FILE__),
          %w[.. .. .. support chef-client-zero.rb])
        FileUtils.cp(source, File.join(sandbox_path, "chef-client-zero.rb"))
      end

      # Writes a client.rb configuration file to the sandbox directory.
      #
      # @api private
      def prepare_client_rb
        data = default_config_rb.merge(config[:client_rb])
        data = data.merge(:named_run_list => config[:named_run_list]) if config[:named_run_list]

        info("Preparing client.rb")
        debug("Creating client.rb from #{data.inspect}")

        File.open(File.join(sandbox_path, "client.rb"), "wb") do |file|
          file.write(format_config_file(data))
        end
      end

      # Writes a fake (but valid) validation.pem into the sandbox directory.
      #
      # @api private
      def prepare_validation_pem
        info("Preparing validation.pem")
        debug("Using a dummy validation.pem")

        source = File.join(File.dirname(__FILE__),
          %w[.. .. .. support dummy-validation.pem])
        FileUtils.cp(source, File.join(sandbox_path, "validation.pem"))
      end

      # Returns the command that will run a backwards compatible shim script
      # that approximates local mode in a modern chef-client run.
      #
      # @return [String] the command string
      # @api private
      def shim_command
        ruby = remote_path_join(config[:ruby_bindir], "ruby").
          tap { |path| path.concat(".exe") if windows_os? }
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
    end
  end
end
