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

  module Color
    ANSI = {
      :reset => 0, :black => 30, :red => 31, :green => 32, :yellow => 33,
      :blue => 34, :magenta => 35, :cyan => 36, :white => 37,
      :bright_black => 30, :bright_red => 31, :bright_green => 32,
      :bright_yellow => 33, :bright_blue => 34, :bright_magenta => 35,
      :bright_cyan => 36, :bright_white => 37
    }.freeze

    COLORS = %w(
      cyan yellow green magenta red blue bright_cyan bright_yellow
      bright_green bright_magenta bright_red bright_blue
    ).freeze

    def self.escape(name)
      return "" if name.nil?
      return "" unless ansi = ANSI[name]
      "\e[#{ansi}m"
    end

    def self.colorize(str, name)
      color = escape(name)
      color.empty? ? str : "#{color}#{str}#{escape(:reset)}"
    end
  end
end
