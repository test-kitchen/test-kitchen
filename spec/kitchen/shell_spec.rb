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

require_relative "../spec_helper"

require "kitchen/errors"
require "kitchen/logging"
require "kitchen/shell"
require "kitchen/shell/base"

module Kitchen

  module Shell

    class Soft < Kitchen::Shell::Base
    end
  end
end

describe Kitchen::Shell do

  describe ".for_plugin" do

    before do
      Kitchen::Shell.stubs(:require).returns(true)
    end

    it "returns a shell object of the correct class" do
      shell = Kitchen::Shell.for_plugin("soft")

      shell.must_be_kind_of Kitchen::Shell::Soft
    end

    it "raises ClientError if the shell could not be required" do
      Kitchen::Shell.stubs(:require).raises(LoadError)

      proc { Kitchen::Shell.for_plugin("soft") }.
        must_raise Kitchen::ClientError
    end

    it "raises ClientError if the shell's class constant was not found" do
      # pretend require worked
      Kitchen::Shell.stubs(:require).returns(true)

      proc { Kitchen::Shell.for_plugin("nope") }.
        must_raise Kitchen::ClientError
    end
  end
end
