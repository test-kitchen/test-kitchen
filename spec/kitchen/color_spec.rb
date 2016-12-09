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

require_relative "../spec_helper"

require "kitchen/color"

describe Kitchen::Color do
  describe ".escape" do
    it "returns an empty string if name is nil" do
      Kitchen::Color.escape(nil).must_equal ""
    end

    it "returns an empty string if name is not in the ANSI hash" do
      Kitchen::Color.escape(:puce).must_equal ""
    end

    it "returns an ansi escape sequence string for cyan" do
      Kitchen::Color.escape(:cyan).must_equal "\e[36m"
    end

    it "returns an ansi escape sequence string for reset" do
      Kitchen::Color.escape(:reset).must_equal "\e[0m"
    end
  end

  describe ".colorize" do
    it "returns an ansi escaped string colored yellow" do
      Kitchen::Color.colorize("hello", :yellow).must_equal "\e[33mhello\e[0m"
    end

    it "returns an unescaped string if color is not in the ANSI hash" do
      Kitchen::Color.colorize("double", :rainbow).must_equal "double"
    end
  end
end
