# -*- encoding: utf-8 -*-
#
# Author:: Fletcher Nichol (<fnichol@nichol.ca>)
#
# Copyright (C) 2013, Fletcher Nichol
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

require "kitchen/command"

module Kitchen
  module Command
    # Command to launch a Pry-based Kitchen console..
    #
    # @author Fletcher Nichol <fnichol@nichol.ca>
    class Console < Kitchen::Command::Base
      # Invoke the command.
      def call
        require "pry"
        Pry.start(@config, prompt: [prompt(">"), prompt("*")])
      rescue LoadError
        warn %{Make sure you have the pry gem installed. You can install it with:}
        warn %{`gem install pry` or including 'gem "pry"' in your Gemfile.}
        exit 1
      end

      private

      # Construct a custom Pry prompt proc.
      #
      # @param char [String] prompt character
      # @return [proc] a prompt proc
      # @api private
      def prompt(char)
        proc do |target_self, nest_level, pry|
          [
            "[#{pry.input_array.size}] ",
            "kc(#{Pry.view_clip(target_self.class)})",
            "#{":#{nest_level}" unless nest_level == 0}#{char} ",
          ].join
        end
      end
    end
  end
end
