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

module Kitchen
  # Utility methods to help ouput colorized text in a terminal. The
  # implementation is a compressed mashup of code from the Thor and Foreman
  # projects.
  #
  # @author Fletcher Nichol <fnichol@nichol.ca>
  module Color
    ANSI = {
      reset: 0, black: 30, red: 31, green: 32, yellow: 33,
      blue: 34, magenta: 35, cyan: 36, white: 37,
      bright_black: 90, bright_red: 91, bright_green: 92,
      bright_yellow: 93, bright_blue: 94, bright_magenta: 95,
      bright_cyan: 96, bright_white: 97
    }.freeze

    COLORS = %w{
      cyan yellow green magenta blue bright_cyan bright_yellow
      bright_green bright_magenta bright_blue
    }.freeze

    # Returns an ansi escaped string representing a color control sequence.
    #
    # @param name [Symbol] a valid color representation, taken from
    #   Kitchen::Color::ANSI
    # @return [String] an ansi escaped string if the color is valid and an
    #   empty string otherwise
    def self.escape(name)
      return "" if name.nil?
      return "" unless ANSI[name]
      "\e[#{ANSI[name]}m"
    end

    # Returns a colorized ansi escaped string with the given color.
    #
    # @param str [String] a string to colorize
    # @param name [Symbol] a valid color representation, taken from
    #   Kitchen::Color::ANSI
    # @return [String] an ansi escaped string if the color is valid and an
    #   unescaped string otherwise
    def self.colorize(str, name)
      color = escape(name)
      color.empty? ? str : "#{color}#{str}#{escape(:reset)}"
    end
  end
end
