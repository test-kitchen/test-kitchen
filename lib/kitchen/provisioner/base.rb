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

      default_config :root_path, "/tmp/kitchen"
      default_config :sudo, true

      expand_path_for :test_base_path

      # Constructs a new provisioner by providing a configuration hash.
      #
      # @param config [Hash] initial provided configuration
      def initialize(config = {})
        init_config(config)
      end

      # Performs any final configuration required for the provisioner to do its
      # work. A reference to an Instance is required as configuration dependant
      # data may need access through an Instance. This also acts as a hook
      # point where the object may wish to perform other last minute checks,
      # valiations, or configuration expansions.
      #
      # @param instance [Instance] an associated instance
      # @return [self] itself, used for chaining
      # @raise [ClientError] if instance parameter is nil
      def finalize_config!(instance)
        super
        load_needed_dependencies!
        # Overwrite the sudo configuration comming from the Transport
        config[:sudo] = instance.transport.sudo
        self
      end

      # Returns the name of this driver, suitable for display in a CLI.
      #
      # @return [String] name of this driver
      def name
        self.class.name.split("::").last
      end

      # Generates a command string which will install and configure the
      # provisioner software on an instance. If no work is required, then `nil`
      # will be returned.
      #
      # @return [String] a command string
      def install_command
      end

      # Override sudo configuration
      #
      # @param boolean [Boolean] activate/deactivate sudo
      # @author Salim Afiune <salim@afiunemaya.com.mx>
      def sudo=(boolean)
        @config[:sudo] = boolean
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

      private

      # Loads any required third party Ruby libraries or runs any shell out
      # commands to prepare the provisioner. This method will be called in the
      # context of the main thread of execution and so does not necessarily
      # have to be thread safe.
      #
      # **Note:** any subclasses overriding this method would be well advised
      # to call super when overriding this method, for example:
      #
      # @example overriding `#load_needed_dependencies!`
      #
      #   class MyProvisioner < Kitchen::Provisioner::Base
      #     def load_needed_dependencies!
      #       super
      #       # any further work
      #     end
      #   end
      #
      # @raise [ClientError] if any library loading fails or any of the
      #   dependency requirements cannot be satisfied
      # @api private
      def load_needed_dependencies!
      end

      # @return [Transport.shell] the transport desired shell for this instance 
      # This would help us know which commands to use. Bourne, Powershell, etc.
      #
      # @api private
      def shell
        instance.transport.shell
      end

      # @return [Logger] the instance's logger or Test Kitchen's common logger
      #   otherwise
      # @api private
      def logger
        instance ? instance.logger : Kitchen.logger
      end

      # Conditionally prefixes a command with a sudo command.
      #
      # @param command [String] command to be prefixed
      # @return [String] the command, conditionaly prefixed with sudo
      # @api private
      def sudo(script)
        config[:sudo] ? "sudo -E #{script}" : script
      end
    end
  end
end
