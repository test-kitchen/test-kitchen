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
    # Command to... include the sink.
    #
    # @author Seth Vargo <sethvargo@gmail.com>
    class Sink < Kitchen::Command::Base
      # Invoke the command.
      def call
        puts [
          "",
          "                    ___              ",
          "                   ' _ '.            ",
          '                 / /` `\\ \\         ',
          "                 | |   [__]          ",
          "                 | |    {{           ",
          "                 | |    }}           ",
          "              _  | |  _ {{           ",
          "  ___________<_>_| |_<_>}}________   ",
          "      .=======^=(___)=^={{====.      ",
          '     / .----------------}}---. \\    ',
          '    / /                 {{    \\ \\  ',
          '   / /                  }}     \\ \\ ',
          "  (  '========================='  )  ",
          "   '-----------------------------'   ",
          "                                     ", # necessary newline
          "",
        ].map(&:rstrip).join("\n")
      end
    end
  end
end
