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

require 'jamie'

module Jamie

  module Driver

    # Dummy driver for Jamie.
    #
    # @author Fletcher Nichol <fnichol@nichol.ca>
    class Dummy < Jamie::Driver::Base

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

      private

      def report(action, state)
        info("[Dummy] Action ##{action} called on " +
          "instance=#{instance} with state=#{state}")
        sleep(config[:sleep].to_f) if config[:sleep].to_f > 0.0
        if config[:random_failure] && [true, false].sample
          debug("[Dummy] Random failure for action ##{action}.")
          raise ActionFailed, "Action ##{action} failed for #{instance.to_str}."
        end
        debug("[Dummy] Action ##{action} completed (#{config[:sleep]}s).")
      end
    end
  end
end
