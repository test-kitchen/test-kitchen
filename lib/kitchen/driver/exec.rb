# -*- encoding: utf-8 -*-
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require "kitchen/driver/base"
require "kitchen/shell_out"
require "kitchen/transport/exec"
require "kitchen/version"

module Kitchen
  module Driver
    # Simple driver that runs commands locally. As with the proxy driver, this
    # has no isolation in general.
    class Exec < Kitchen::Driver::Base
      include ShellOut

      plugin_version Kitchen::VERSION

      default_config :reset_command, nil

      no_parallel_for :create, :converge, :destroy

      # Hack to force using the exec transport when using this driver.
      # If someone comes up with a use case for using the driver with a different
      # transport, please let us know.
      #
      # @api private
      def finalize_config!(instance)
        super.tap do
          instance.transport = Kitchen::Transport::Exec.new
        end
      end

      # (see Base#create)
      def create(state)
        super
        reset_instance(state)
      end

      # (see Base#destroy)
      def destroy(state)
        reset_instance(state)
      end

      private

      # Resets the non-Kitchen managed instance using by issuing a command
      # over SSH.
      #
      # @param state [Hash] the state hash
      # @api private
      def reset_instance(state)
        if cmd = config[:reset_command]
          info("Resetting instance state with command: #{cmd}")
          run_command(cmd)
        end
      end
    end
  end
end
