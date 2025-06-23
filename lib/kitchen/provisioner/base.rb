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

require_relative "../configurable"
require_relative "../errors"
require_relative "../logging"
require_relative "../plugin_base"

module Kitchen
  module Provisioner
    # Base class for a provisioner.
    #
    # @author Fletcher Nichol <fnichol@nichol.ca>
    class Base < Kitchen::Plugin::Base
      include Configurable
      include Logging

      default_config :http_proxy, nil
      default_config :https_proxy, nil
      default_config :ftp_proxy, nil

      default_config :retry_on_exit_code, []
      default_config :max_retries, 1
      default_config :wait_for_retry, 30

      default_config :root_path do |provisioner|
        provisioner.windows_os? ? '$env:TEMP\\kitchen' : "/tmp/kitchen"
      end

      default_config :sudo do |provisioner|
        provisioner.windows_os? ? nil : true
      end

      default_config :sudo_command do |provisioner|
        provisioner.windows_os? ? nil : "sudo -E"
      end

      default_config :command_prefix, nil

      default_config :uploads, {}
      default_config :downloads, {}

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
        prepare_install_script

        instance.transport.connection(state) do |conn|
          binding.pry
          config[:uploads].to_h.each do |locals, remote|
            debug("Uploading #{Array(locals).join(", ")} to #{remote}")
            conn.upload(locals.to_s, remote)
          end

          # Run the init command to initialize everything
          conn.execute(init_command)

          # Upload the install script instead of directly executing the command
          if install_command
            remote_script_path = remote_path_join(config[:root_path], "install_script")
            if install_script_path
              debug("Uploading install script to #{remote_script_path}")
              conn.upload(install_script_path, remote_script_path)
              # Make script executable on remote host
              conn.execute(make_executable_command(remote_script_path))
              # Execute the uploaded script
              conn.execute(run_script_command(remote_script_path))
            end
          end

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
          info("Downloading files from #{instance.to_str}")
          config[:downloads].to_h.each do |remotes, local|
            debug("Downloading #{Array(remotes).join(", ")} to #{local}")
            conn.download(remotes, local)
          end
          debug("Download complete")
        end
      rescue Kitchen::Transport::TransportFailed => ex
        raise ActionFailed, ex.message
      ensure
        cleanup_sandbox
      end

      # Check system and configuration for common errors.
      #
      # @param state [Hash] mutable instance state
      # @returns [Boolean] Return true if a problem is found.
      def doctor(state)
        false
      end

      # Certain products that Test Kitchen uses to provision require accepting
      # a license to use. Overwrite this method in the specific provisioner
      # to implement this check.
      def check_license; end

      # Generates a command string which will install and configure the
      # provisioner software on an instance. If no work is required, then `nil`
      # will be returned.
      #
      # @return [String] a command string
      def install_command; end

      # Generates a command string which will perform any data initialization
      # or configuration required after the provisioner software is installed
      # but before the sandbox has been transferred to the instance. If no work
      # is required, then `nil` will be returned.
      #
      # @return [String] a command string
      def init_command; end

      # Generates a command string which will perform any commands or
      # configuration required just before the main provisioner run command but
      # after the sandbox has been transferred to the instance. If no work is
      # required, then `nil` will be returned.
      #
      # @return [String] a command string
      def prepare_command; end

      # Generates a command string which will invoke the main provisioner
      # command on the prepared instance. If no work is required, then `nil`
      # will be returned.
      #
      # @return [String] a command string
      def run_command; end

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
        @sandbox_path ||= raise ClientError, "Sandbox directory has not yet " \
          "been created. Please run #{self.class}#create_sandox before " \
          "trying to access the path."
      end

      # Returns the list of items in the sandbox directory
      #
      # @return [String] path of items in the sandbox directory
      def sandbox_dirs
        Util.list_directory(sandbox_path)
      end

      # Deletes the sandbox path. Without calling this method, the sandbox path
      # will persist after the process terminates. In other words, cleanup is
      # explicit. This method is safe to call multiple times.
      def cleanup_sandbox
        return if sandbox_path.nil?

        debug("Cleaning up local sandbox in #{sandbox_path}")
        @install_script_path = nil
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
          %w{.. .. .. support},
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

      # Writes the install command to a file that will be uploaded to the instance
      # and executed.
      #
      # @api private
      def prepare_install_script
        binding.pry
        command = install_command
        return if command.nil? || command.empty?

        info("Preparing install script")
        @install_script_path = File.join(sandbox_path, "install_script")

        debug("Creating install script at #{@install_script_path}")
        File.open(@install_script_path, "wb") do |file|
          # Add shebang based on OS
          if windows_os?
            file.write("@echo off\n")
          else
            file.write("#!/bin/sh\n")
          end

          file.write(command)
        end

        # Make script executable locally
        FileUtils.chmod(0755, @install_script_path) unless windows_os?
      end

      # Returns the path to the install script if it exists.
      #
      # @return [String] path to the install script
      # @api private
      def install_script_path
        @install_script_path
      end

      # Returns a command to make a script executable on the remote host.
      #
      # @param script_path [String] path to the script on the remote host
      # @return [String] command to make the script executable
      # @api private
      def make_executable_command(script_path)
        return "echo Making script executable" if windows_os?

        prefix_command(wrap_shell_code(sudo("chmod +x #{script_path}")))
      end

      # Returns a command to execute a script on the remote host.
      #
      # @param script_path [String] path to the script on the remote host
      # @return [String] command to execute the script
      # @api private
      def run_script_command(script_path)
        if windows_os?
          script_path
        else
          prefix_command(wrap_shell_code(sudo(script_path)))
        end
      end

      # Joins path parts to create a remote path on the remote instance.
      #
      # @param parts [Array<String>] parts of the path to join
      # @return [String] joined path
      # @api private
      def remote_path_join(*parts)
        path_separator = windows_os? ? "\\" : "/"
        parts.join(path_separator)
      end
    end
  end
end
