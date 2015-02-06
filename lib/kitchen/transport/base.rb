# -*- encoding: utf-8 -*-
#
# Author:: Salim Afiune (<salim@afiunemaya.com.mx>)
#
# Copyright (C) 2014, Salim Afiune
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

require "kitchen/lazy_hash"

require "kitchen/errors"
require "kitchen/login_command"

module Kitchen

  module Transport

    # Wrapped exception for any internally raised Transport errors.
    #
    # @author Salim Afiune <salim@afiunemaya.com.mx>
    class TransportFailed < TransientFailure; end

    # Base class for a transport.
    #
    # @author Salim Afiune <salim@afiunemaya.com.mx>
    class Base

      include Configurable
      include Logging

      # Create a new Transport object using the provided configuration data
      # which will be merged with any default configuration.
      #
      # @param config [Hash] provided transport configuration
      def initialize(config = {})
        init_config(config)
      end

      def connection(_state)
        raise ClientError, "#{self.class}#connection must be implemented"
      end

      # Performs any final configuration required for the transport to do its
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
        self
      end

      # Returns the name of this transport, suitable for display in a CLI.
      #
      # @return [String] name of this transport
      def name
        self.class.name.split("::").last
      end

      # Performs whatever tests that may be required to ensure that this
      # transport will be able to function in the current environment. This may
      # involve checking for the presence of certain directories, software
      # installed, etc.
      #
      # @raise [UserError] if the transport will not be able to perform or if
      #   a documented dependency is missing from the system
      def verify_dependencies
        # this method may be left unimplemented if that is applicable
      end

      # TODO: comment
      class Connection

        include Logging

        def initialize(options = {})
          init_options(options)

          if block_given?
            yield self
          end
        end

        # Closes the session connection, if it is still active.
        def close
          # this method may be left unimplemented if that is applicable
        end

        # Execute a command on the remote host.
        #
        # @param command [String] command string to execute
        # @raise [TransportFailed] if the command does not exit with a 0 code
        def execute(_command)
          raise ClientError, "#{self.class}#execute must be implemented"
        end

        # Builds a LoginCommand which can be used to open an interactive session
        # on the remote host.
        #
        # @return [LoginCommand] an object containing the array of command line
        #   tokens and exec options to be used in a fork/exec
        # @raise [ActionFailed] if the action could not be completed
        def login_command
          raise ActionFailed, "Remote login not supported in #{self.class}."
        end

        # Uploads local files or directories to remote host.
        #
        # @param locals [Array<String>] paths to local files or directories
        # @param remote [String] path to remote destination
        def upload(_locals, _remote)
          raise ClientError, "#{self.class}#upload must be implemented"
        end

        def wait_until_ready
          # this method may be left unimplemented if that is applicable
        end

        private

        attr_reader :logger

        # @return [Hash] connection options
        # @api private
        attr_reader :options

        def init_options(options)
          @options = options.dup
          @logger = @options.delete(:logger) || Kitchen.logger
        end
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
      #   class MyTransport < Kitchen::Transport::Base
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
        # this method may be left unimplemented if that is applicable
      end

      # Returns a suitable logger to use for output.
      #
      # @return [Kitchen::Logger] a logger
      # @api private
      def logger
        instance ? instance.logger : Kitchen.logger
      end
    end
  end
end
