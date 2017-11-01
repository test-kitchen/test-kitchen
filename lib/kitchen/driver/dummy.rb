# -*- encoding: utf-8 -*-
#
# Author:: Fletcher Nichol (<fnichol@nichol.ca>)
#
# Copyright (C) 2012, 2013, 2014 Fletcher Nichol
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

require "kitchen"

module Kitchen
  module Driver
    # Dummy driver for Kitchen. This driver does nothing but report what would
    # happen if this driver did anything of consequence. As a result it may
    # be a useful driver to use when debugging or developing new features or
    # plugins.
    #
    # @author Fletcher Nichol <fnichol@nichol.ca>
    class Dummy < Kitchen::Driver::Base
      kitchen_driver_api_version 2

      plugin_version Kitchen::VERSION

      default_config :sleep, 0
      default_config :random_failure, false

      # (see Base#create)
      def create(state)
        # Intentionally not calling `super` to avoid pre_create_command.
        state[:my_id] = "#{instance.name}-#{Time.now.to_i}"
        report(:create, state)
      end

      # (see Base#setup)
      def setup(state)
        report(:setup, state)
      end

      # (see Base#verify)
      def verify(state)
        report(:verify, state)
      end

      # (see Base#destroy)
      def destroy(state)
        report(:destroy, state)
        state.delete(:my_id)
      end

      private

      # Report what action is taking place, sleeping if so configured, and
      # possibly fail randomly.
      #
      # @param action [Symbol] the action currently taking place
      # @param state [Hash] the state hash
      # @api private
      def report(action, state)
        what = action.capitalize
        info("[Dummy] #{what} on instance=#{instance} with state=#{state}")
        sleep_if_set
        failure_if_set(action)
        debug("[Dummy] #{what} completed (#{config[:sleep]}s).")
      end

      # Sleep for a period of time, if a value is set in the config.
      #
      # @api private
      def sleep_if_set
        sleep(config[:sleep].to_f) if config[:sleep].to_f > 0.0
      end

      # Simulate a failure in an action, if set in the config.
      #
      # @param action [Symbol] the action currently taking place
      # @api private
      def failure_if_set(action)
        if config[:"fail_#{action}"]
          debug("[Dummy] Failure for action ##{action}.")
          raise ActionFailed, "Action ##{action} failed for #{instance.to_str}."
        elsif config[:random_failure] && randomly_fail?
          debug("[Dummy] Random failure for action ##{action}.")
          raise ActionFailed, "Action ##{action} failed for #{instance.to_str}."
        end
      end

      # Determine whether or not to randomly fail.
      #
      # @return [true, false]
      # @api private
      def randomly_fail?
        [true, false].sample
      end
    end
  end
end
