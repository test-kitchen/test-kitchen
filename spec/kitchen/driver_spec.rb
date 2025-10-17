#
# Author:: Fletcher Nichol (<fnichol@nichol.ca>)
#
# Copyright (C) 2013, Fletcher Nichol
# Copyright (C) 2018, Chef Software
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

require "kitchen/driver"
require "kitchen/driver/base"

module Kitchen
  module Driver
    class Coolbeans < Kitchen::Driver::Base
    end
  end
end

describe Kitchen::Driver do
  describe ".for_plugin" do
    before do
      Kitchen::Plugin.stubs(:require).returns(true)
    end

    it "uses Kitchen::Plugin.load" do
      faux_driver = Object.new
      Kitchen::Plugin.stubs(:load).returns(faux_driver)
      driver = Kitchen::Driver.for_plugin("faux", {})

      _(driver).must_equal faux_driver
    end

    it "returns a driver object of the correct class" do
      driver = Kitchen::Driver.for_plugin("coolbeans", {})

      _(driver).must_be_kind_of Kitchen::Driver::Coolbeans
    end

    it "returns a driver initialized with its config" do
      driver = Kitchen::Driver.for_plugin("coolbeans", jelly: "beans")

      _(driver[:jelly]).must_equal "beans"
    end

    it "raises ClientError if the driver could not be required" do
      Kitchen::Plugin.stubs(:require).raises(LoadError)

      error = assert_raises(Kitchen::ClientError) { Kitchen::Driver.for_plugin("coolbeans", {}) }
      _(error.message).must_include "Could not load the 'coolbeans' driver from the load path."
      _(error.message).must_include "Did you mean"
    end

    it "raises ClientError if driver is found on load path but require still fails" do
      Kitchen::Plugin.stubs(:require).raises(LoadError, "Some other problem.")

      error = assert_raises(Kitchen::ClientError) { Kitchen::Driver.for_plugin("dummy", {}) }
      _(error.message).must_include "Could not load the 'dummy' driver from the load path."
      _(error.message).must_include "Some other problem."
      _(error.message).wont_include "Did you mean"
    end

    it "raises ClientError if the driver's class constant could not be found" do
      Kitchen::Plugin.stubs(:require).returns(true) # pretend require worked

      error = assert_raises(Kitchen::ClientError) { Kitchen::Driver.for_plugin("nope", {}) }
      _(error.message).must_include "uninitialized constant Kitchen::Driver::Nope"
    end
  end
end
