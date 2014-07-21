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

require "kitchen/errors"
require "kitchen/logging"
require "kitchen/shell_out"
require "kitchen/driver"
require "kitchen/driver/base"

module Kitchen

  module Driver

    class Coolbeans < Kitchen::Driver::Base
    end

    class ItDepends < Kitchen::Driver::Base

      attr_reader :verify_call_count

      def initialize(config = {})
        @verify_call_count = 0
        super
      end

      def verify_dependencies
        @verify_call_count += 1
      end
    end

    class UnstableDepends < Kitchen::Driver::Base

      def verify_dependencies
        raise UserError, "Oh noes, you don't have software!"
      end
    end
  end
end

describe Kitchen::Driver do

  describe ".for_plugin" do

    before do
      Kitchen::Driver.stubs(:require).returns(true)
    end

    it "returns a driver object of the correct class" do
      driver = Kitchen::Driver.for_plugin("coolbeans", {})

      driver.must_be_kind_of Kitchen::Driver::Coolbeans
    end

    it "returns a driver initialized with its config" do
      driver = Kitchen::Driver.for_plugin("coolbeans", :jelly => "beans")

      driver[:jelly].must_equal "beans"
    end

    it "calls #verify_dependencies on the driver object" do
      driver = Kitchen::Driver.for_plugin("it_depends", {})

      driver.verify_call_count.must_equal 1
    end

    it "calls #verify_dependencies once per driver require" do
      Kitchen::Driver.stubs(:require).returns(true, false)
      driver1 = Kitchen::Driver.for_plugin("it_depends", {})
      driver1.verify_call_count.must_equal 1
      driver2 = Kitchen::Driver.for_plugin("it_depends", {})

      driver2.verify_call_count.must_equal 0
    end

    it "raises ClientError if the driver could not be required" do
      Kitchen::Driver.stubs(:require).raises(LoadError)

      proc { Kitchen::Driver.for_plugin("coolbeans", {}) }.
        must_raise Kitchen::ClientError
    end

    it "raises ClientError if the driver's class constant could not be found" do
      Kitchen::Driver.stubs(:require).returns(true) # pretend require worked

      proc { Kitchen::Driver.for_plugin("nope", {}) }.
        must_raise Kitchen::ClientError
    end

    it "raises UserError if #verify_dependencies fails" do
      proc { Kitchen::Driver.for_plugin("unstable_depends", {}) }.
        must_raise Kitchen::UserError
    end
  end
end
