# -*- encoding: utf-8 -*-
#
# Author:: Fletcher Nichol (<fnichol@nichol.ca>)
#
# Copyright (C) 2012, Fletcher Nichol
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

require 'kitchen'

module Kitchen

  module Driver

    # Dummy driver for Kitchen.
    #
    # @author Fletcher Nichol <fnichol@nichol.ca>
    class Dummy < Kitchen::Driver::Base

      default_config :sleep, 0
      default_config :random_failure, false

      def create(state)
        state[:my_id] = "#{instance.name}-#{Time.now.to_i}"
        report(:create, state)
      end

      def converge(state)
        report(:converge, state)
      end

      def setup(state)
        report(:setup, state)
      end

      def verify(state)
        report(:verify, state)
      end

      def destroy(state)
        report(:destroy, state)
        state.delete(:my_id)
      end

      def start(state)
        report(:start, state)
      end

      private

      def report(action, state)
        what = action.capitalize
        info("[Dummy] #{what} on instance=#{instance} with state=#{state}")
        sleep_if_set
        random_failure_if_set(action)
        debug("[Dummy] #{what} completed (#{config[:sleep]}s).")
      end

      def sleep_if_set
        sleep(config[:sleep].to_f) if config[:sleep].to_f > 0.0
      end

      def random_failure_if_set(action)
        if config[:random_failure] && randomly_fail?
          debug("[Dummy] Random failure for action ##{action}.")
          raise ActionFailed, "Action ##{action} failed for #{instance.to_str}."
        end
      end

      def randomly_fail?
        [true, false].sample
      end
    end
  end
end
