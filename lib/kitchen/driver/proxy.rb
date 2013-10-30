#
# Author:: Seth Chisamore <schisamo@opscode.com>
#
# Copyright:: Copyright (c) 2013 Opscode, Inc.
# License:: Apache License, Version 2.0
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

require 'kitchen/driver/ssh_base'

module Kitchen

  module Driver

    # Proxy driver for Test Kitchen.
    #
    # @author Seth Chisamore <schisamo@opscode.com>
    class Proxy < Kitchen::Driver::SSHBase

      required_config :host
      required_config :reset_command

      no_parallel_for :create, :destroy

      def create(state)
        state[:hostname] = config[:host]
        reset_instance(state)
      end

      def destroy(state)
        return if state[:hostname].nil?
        reset_instance(state)
        state.delete(:hostname)
      end

      private

      def reset_instance(state)
        if cmd = config[:reset_command]
          info("Resetting instance state with command: #{cmd}")
          ssh(build_ssh_args(state), cmd)
        end
      end

    end
  end
end
