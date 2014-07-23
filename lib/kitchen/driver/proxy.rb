# -*- encoding: utf-8 -*-
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

require "kitchen"

module Kitchen

  module Driver

    # Simple driver that proxies commands through to a test instance whose
    # lifecycle is not managed by Test Kitchen. This driver is useful for long-
    # lived non-ephemeral test instances that are simply "reset" between test
    # runs. Think executing against devices like network switches--this is why
    # the driver was created.
    #
    # @author Seth Chisamore <schisamo@opscode.com>
    class Proxy < Kitchen::Driver::SSHBase

      required_config :host
      required_config :reset_command

      no_parallel_for :create, :destroy

      # (see Base#create)
      def create(state)
        state[:hostname] = config[:host]
        reset_instance(state)
      end

      # (see Base#destroy)
      def destroy(state)
        return if state[:hostname].nil?
        reset_instance(state)
        state.delete(:hostname)
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
          ssh(build_ssh_args(state), cmd)
        end
      end
    end
  end
end
