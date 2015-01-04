# -*- encoding: utf-8 -*-
#
# Author:: Matt Wrock (<matt@mattwrock.com>)
#
# Copyright (C) 2014, Matt Wrock
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

require_relative "../../spec_helper"

require "kitchen"
require "kitchen/shell/base"
require "kitchen/shell/powershell"

describe Kitchen::Shell::Powershell do

  let(:shell) do
    Kitchen::Shell::Powershell.new
  end

  describe "set_env" do

    let(:env) { shell.set_env("my_var", "this is my value") }

    it "sets the value given to the variable" do
      env.must_equal(
        <<-CMD.gsub(/^ {10}/, "")
          $env:my_var="this is my value"
        CMD
      )
    end
  end

  def regexify(str, line = :whole_line)
    r = Regexp.escape(str)
    r = "^\s*#{r}$" if line == :whole_line
    Regexp.new(r)
  end
end
