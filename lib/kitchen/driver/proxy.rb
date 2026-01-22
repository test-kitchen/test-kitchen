# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require_relative "base"
require_relative "../version"

module Kitchen
  module Driver
    # Simple driver that proxies commands through to a test instance whose
    # lifecycle is not managed by Test Kitchen. This driver is useful for long-
    # lived non-ephemeral test instances that are simply "reset" between test
    # runs. Think executing against devices like network switches--this is why
    # the driver was created.
    #
    # @author Seth Chisamore <schisamo@opscode.com>
    class Proxy < Kitchen::Driver::Base
      plugin_version Kitchen::VERSION

      required_config :host
      default_config :reset_command, nil

      no_parallel_for :create, :destroy

      # (see Base#create)
      def create(state)
        super
        state[:hostname] = config[:host]
        state[:port] = config[:port] if config[:port]
        state[:username] = config[:username] if config[:username]
        state[:password] = config[:password] if config[:password]
        reset_instance(state)
      end

      # (see Base#destroy)
      def destroy(state)
        return if state[:hostname].nil?

        reset_instance(state)
        state.delete(:hostname)
      end

      private

      # Resets the non-Kitchen managed instance by issuing a command
      # over the transport.
      #
      # @param state [Hash] the state hash
      # @api private
      def reset_instance(state)
        if (cmd = config[:reset_command])
          info("Resetting instance state with command: #{cmd}")
          instance.transport.connection(state) do |conn|
            conn.execute(cmd)
          end
        end
      end
    end
  end
end
