#
# Author:: Fletcher Nichol (<fnichol@nichol.ca>)
#
# Copyright (C) 2014, Fletcher Nichol
#
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

module Kitchen
  module Plugin
    class Base
      class << self
        # @return [Array<Symbol>] an array of action method names that cannot
        #   be run concurrently and must be run in serial via a shared mutex
        attr_reader :serial_actions
      end

      # Registers certain driver actions that cannot be safely run concurrently
      # in threads across multiple instances. Typically this might be used
      # for create or destroy actions that use an underlying resource that
      # cannot be used at the same time.
      #
      # A shared mutex for this driver object will be used to synchronize all
      # registered methods.
      #
      # @example a single action method that cannot be run concurrently
      #
      #   no_parallel_for :create
      #
      # @example multiple action methods that cannot be run concurrently
      #
      #   no_parallel_for :create, :destroy
      #
      # @param methods [Array<Symbol>] one or more actions as symbols
      # @raise [ClientError] if any method is not a valid action method name
      def self.no_parallel_for(*methods)
        action_methods = %i{create setup converge verify destroy}

        Array(methods).each do |meth|
          next if action_methods.include?(meth)

          raise ClientError, "##{meth} is not a valid no_parallel_for method"
        end

        @serial_actions ||= []
        @serial_actions += methods
      end
    end
  end
end
