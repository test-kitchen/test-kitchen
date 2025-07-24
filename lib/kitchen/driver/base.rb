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
require_relative "../lazy_hash"
require_relative "../logging"
require_relative "../plugin_base"
require_relative "../shell_out"

module Kitchen
  module Driver
    # Base class for a driver.
    class Base < Kitchen::Plugin::Base
      include Configurable
      include Logging
      include ShellOut

      default_config :pre_create_command, nil

      # Creates a new Driver object using the provided configuration data
      # which will be merged with any default configuration.
      #
      # @param config [Hash] provided driver configuration
      def initialize(config = {})
        init_config(config)
      end

      # Creates an instance.
      #
      # @param state [Hash] mutable instance and driver state
      # @raise [ActionFailed] if the action could not be completed
      def create(state) # rubocop:disable Lint/UnusedMethodArgument
        pre_create_command
      end

      # Destroys an instance.
      #
      # @param state [Hash] mutable instance and driver state
      # @raise [ActionFailed] if the action could not be completed
      def destroy(state); end

      # Package an instance.
      #
      # @param state [Hash] mutable instance and driver state
      # @raise [ActionFailed] if the action could not be completed
      def package(state); end

      # Check system and configuration for common errors.
      #
      # @param state [Hash] mutable instance and driver state
      # @returns [Boolean] Return true if a problem is found.
      def doctor(state)
        false
      end

      # Sets the API version for this driver. If the driver does not set this
      # value, then `nil` will be used and reported.
      #
      # Sets the API version for this driver
      #
      # @example setting an API version
      #
      #   module Kitchen
      #     module Driver
      #       class NewDriver < Kitchen::Driver::Base
      #
      #         kitchen_driver_api_version 2
      #
      #       end
      #     end
      #   end
      #
      # @param version [Integer,String] a version number
      #
      def self.kitchen_driver_api_version(version)
        @api_version = version
      end

      # Cache directory that a driver could implement to inform the provisioner
      # that it can leverage it internally
      #
      # @return path [String] a path of the cache directory
      def cache_directory; end

      private

      # Run command if config[:pre_create_command] is set
      def pre_create_command
        if config[:pre_create_command]
          begin
            run_command(config[:pre_create_command])
          rescue ShellCommandFailed => error
            raise ActionFailed,
              "pre_create_command '#{config[:pre_create_command]}' failed to execute #{error}"
          end
        end
      end

      # Intercepts any bare #puts calls in subclasses and issues an INFO log
      # event instead.
      #
      # @param msg [String] message string
      def puts(msg)
        info(msg)
      end

      # Intercepts any bare #print calls in subclasses and issues an INFO log
      # event instead.
      #
      # @param msg [String] message string
      def print(msg)
        info(msg)
      end
    end
  end
end
