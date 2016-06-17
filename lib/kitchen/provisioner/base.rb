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

module Kitchen

  module Provisioner

    # Base class for a provisioner.
    #
    # @author Fletcher Nichol <fnichol@nichol.ca>
    class Base

      include Configurable
      include Logging

      default_config :http_proxy, nil
      default_config :https_proxy, nil
      default_config :ftp_proxy, nil

      default_config :retry_on_exit_code, []
      default_config :max_retries, 1
      default_config :wait_for_retry, 30

      default_config :root_path do |provisioner|
        provisioner.windows_os? ? "$env:TEMP\\kitchen" : "/tmp/kitchen"
      end

      default_config :sudo do |provisioner|
        provisioner.windows_os? ? nil : true
      end

      default_config :sudo_command do |provisioner|
        provisioner.windows_os? ? nil : "sudo -E"
      end

      default_config :command_prefix, nil

      expand_path_for :test_base_path

      # Constructs a new provisioner by providing a configuration hash.
      #
      # @param config [Hash] initial provided configuration
      def initialize(config = {})
        init_config(config)
      end

      # Runs the provisioner on the instance.
      #
      # @param state [Hash] mutable instance state
      # @raise [ActionFailed] if the action could not be completed
      # rubocop:disable Metrics/AbcSize
      def call(state)
        create_sandbox
        sandbox_dirs = Dir.glob(File.join(sandbox_path, "*"))

        instance.transport.connection(state) do |conn|
          conn.execute(install_command)
          conn.execute(init_command)
          info("Transferring files to #{instance.to_str}")
          conn.upload(sandbox_dirs, config[:root_path])
          debug("Transfer complete")
          conn.execute(prepare_command)
          conn.execute_with_retry(
            run_command,
            config[:retry_on_exit_code],
            config[:max_retries],
            config[:wait_for_retry]
          )
        end
      rescue Kitchen::Transport::TransportFailed => ex
        raise ActionFailed, ex.message
      ensure
        cleanup_sandbox
      end

      # Generates a command string which will install and configure the
      # provisioner software on an instance. If no work is required, then `nil`
      # will be returned.
      #
      # @return [String] a command string
      def install_command
      end

      # Generates a command string which will perform any data initialization
      # or configuration required after the provisioner software is installed
      # but before the sandbox has been transferred to the instance. If no work
      # is required, then `nil` will be returned.
      #
      # @return [String] a command string
      def init_command
      end

      # Generates a command string which will perform any commands or
      # configuration required just before the main provisioner run command but
      # after the sandbox has been transferred to the instance. If no work is
      # required, then `nil` will be returned.
      #
      # @return [String] a command string
      def prepare_command
      end

      # Generates a command string which will invoke the main provisioner
      # command on the prepared instance. If no work is required, then `nil`
      # will be returned.
      #
      # @return [String] a command string
      def run_command
      end

      # Creates a temporary directory on the local workstation into which
      # provisioner related files and directories can be copied or created. The
      # contents of this directory will be copied over to the instance before
      # invoking the provisioner's run command. After this method completes, it
      # is expected that the contents of the sandbox is complete and ready for
      # copy to the remote instance.
      #
      # **Note:** any subclasses would be well advised to call super first when
      # overriding this method, for example:
      #
      # @example overriding `#create_sandbox`
      #
      #   class MyProvisioner < Kitchen::Provisioner::Base
      #     def create_sandbox
      #       super
      #       # any further file copies, preparations, etc.
      #     end
      #   end
      def create_sandbox
        @sandbox_path = Dir.mktmpdir("#{instance.name}-sandbox-")
        File.chmod(0755, sandbox_path)
        info("Preparing files for transfer")
        debug("Creating local sandbox in #{sandbox_path}")
      end

      # Returns the absolute path to the sandbox directory or raises an
      # exception if `#create_sandbox` has not yet been called.
      #
      # @return [String] the absolute path to the sandbox directory
      # @raise [ClientError] if the sandbox directory has no yet been created
      #   by calling `#create_sandbox`
      def sandbox_path
        @sandbox_path || (raise ClientError, "Sandbox directory has not yet " \
          "been created. Please run #{self.class}#create_sandox before " \
          "trying to access the path.")
      end

      # Deletes the sandbox path. Without calling this method, the sandbox path
      # will persist after the process terminates. In other words, cleanup is
      # explicit. This method is safe to call multiple times.
      def cleanup_sandbox
        return if sandbox_path.nil?

        debug("Cleaning up local sandbox in #{sandbox_path}")
        FileUtils.rmtree(sandbox_path)
      end

      # Sets the API version for this provisioner. If the provisioner does not
      # set this value, then `nil` will be used and reported.
      #
      # Sets the API version for this provisioner
      #
      # @example setting an API version
      #
      #   module Kitchen
      #     module Provisioner
      #       class NewProvisioner < Kitchen::Provisioner::Base
      #
      #         kitchen_provisioner_api_version 2
      #
      #       end
      #     end
      #   end
      #
      # @param version [Integer,String] a version number
      #
      def self.kitchen_provisioner_api_version(version)
        @api_version = version
      end

      private

      # Builds a complete command given a variables String preamble and a file
      # containing shell code.
      #
      # @param vars [String] shell variables, as a String
      # @param file [String] file basename (without extension) containing
      #   shell code
      # @return [String] command
      # @api private
      def shell_code_from_file(vars, file)
        src_file = File.join(
          File.dirname(__FILE__),
          %w[.. .. .. support],
          file + (powershell_shell? ? ".ps1" : ".sh")
        )

        wrap_shell_code([vars, "", IO.read(src_file)].join("\n"))
      end

      # Conditionally prefixes a command with a sudo command.
      #
      # @param command [String] command to be prefixed
      # @return [String] the command, conditionally prefixed with sudo
      # @api private
      def sudo(script)
        "#{sudo_command} #{script}".lstrip
      end

      # Returns the sudo command to use or empty string if sudo is not configured
      #
      # @return [String] the sudo command if sudo config is true
      # @api private
      def sudo_command
        config[:sudo] ? config[:sudo_command].to_s : ""
      end

      # Conditionally prefixes a command with a command prefix.
      # This should generally be done after a command has been
      # conditionally prefixed by #sudo as certain platforms, such as
      # Cisco Nexus, require all commands to be run with a prefix to
      # obtain outbound network access.
      #
      # @param command [String] command to be prefixed
      # @return [String] the command, conditionally prefixed with the configured prefix
      # @api private
      def prefix_command(script)
        config[:command_prefix] ? "#{config[:command_prefix]} #{script}" : script
      end
    end
  end
end
