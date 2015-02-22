# -*- encoding: utf-8 -*-
#
# Author:: Fletcher (<fnichol@nichol.ca>)
#
# Copyright (C) 2015, Fletcher Nichol
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

require "erb"
require "ostruct"

module Kitchen

  module Transport

    class Winrm < Kitchen::Transport::Base

      # Wraps an ERb template which can be called multiple times with
      # different binding contexts.
      #
      # @author Fletcher Nichol <fnichol@nichol.ca>
      # @api private
      class Template

        # Initializes an ERb template using a file as the template source.
        #
        # @param file [String] path to an ERb template file
        def initialize(file)
          @erb = ERB.new(IO.read(file))
        end

        # Renders the template using a hash as context.
        #
        # @param vars [Hash] a hash used for context
        # @return [String] the rendered template
        def render(vars)
          @erb.result(Context.for(vars))
        end
        alias_method :%, :render

        # Internal class which wraps a binding context for rendering
        # an ERb template.
        #
        # @author Fletcher Nichol <fnichol@nichol.ca>
        # @api private
        class Context < OpenStruct

          # Creates a new binding context for a hash of data.
          #
          # @param vars [Hash] a hash used for context
          # @return [Binding] a binding context for the given hash
          def self.for(vars)
            new(vars).my_binding
          end

          # @return [Binding] a binding context
          def my_binding
            binding
          end
        end
      end
    end
  end
end
