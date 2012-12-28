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

      def create(instance, state)
        state['my_id'] = "#{instance.name}-#{Time.now.to_i}"
        report(:create, instance, state)
      end

      def converge(instance, state)
        report(:converge, instance, state)
      end

      def setup(instance, state)
        report(:setup, instance, state)
      end

      def verify(instance, state)
        report(:verify, instance, state)
      end

      def destroy(instance, state)
        report(:destroy, instance, state)
        state.delete('my_id')
      end

      private

      def report(action, instance, state)
        puts "[Dummy] Action ##{action} called on " +
          "instance=#{instance} with state=#{state}"
      end
    end
  end
end
