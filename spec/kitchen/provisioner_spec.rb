#
# Author:: Fletcher Nichol (<fnichol@nichol.ca>)
#
# Copyright (C) 2013, Fletcher Nichol
# Copyright (C) Chef Software Inc.
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

require_relative "../spec_helper"

require "kitchen/provisioner"
require "kitchen/provisioner/base"

module Kitchen
  module Provisioner
    class Coolbeans < Kitchen::Provisioner::Base
    end
  end
end

describe Kitchen::Provisioner do
  describe ".for_plugin" do
    before do
      Kitchen::Plugin.stubs(:require).returns(true)
    end

    it "uses Kitchen::Plugin.load" do
      faux_provisioner = Object.new
      Kitchen::Plugin.stubs(:load).returns(faux_provisioner)
      provisioner = Kitchen::Provisioner.for_plugin("faux", {})

      _(provisioner).must_equal faux_provisioner
    end

    it "returns a provisioner object of the correct class" do
      provisioner = Kitchen::Provisioner.for_plugin("coolbeans", {})

      _(provisioner).must_be_kind_of Kitchen::Provisioner::Coolbeans
    end

    it "returns a provisioner initialized with its config" do
      provisioner = Kitchen::Provisioner.for_plugin("coolbeans", foo: "bar")

      _(provisioner[:foo]).must_equal "bar"
    end

    it "raises ClientError if the provisioner could not be required" do
      Kitchen::Plugin.stubs(:require).raises(LoadError)

      _ { Kitchen::Provisioner.for_plugin("coolbeans", {}) }
        .must_raise Kitchen::ClientError
    end

    it "raises ClientError if the provisioner's class constant was not found" do
      # pretend require worked
      Kitchen::Plugin.stubs(:require).returns(true)

      _ { Kitchen::Provisioner.for_plugin("nope", {}) }
        .must_raise Kitchen::ClientError
    end
  end
end
