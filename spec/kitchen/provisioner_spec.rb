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

require "kitchen/configurable"
require "kitchen/errors"
require "kitchen/logging"
require "kitchen/provisioner"
require "kitchen/provisioner/base"

module Kitchen

  module Provisioner

    class Coolbeans < Kitchen::Provisioner::Base
    end

    class ItDepends < Kitchen::Provisioner::Base

      attr_reader :verify_call_count

      def initialize(config = {})
        @verify_call_count = 0
        super
      end

      def verify_dependencies
        @verify_call_count += 1
      end
    end

    class UnstableDepends < Kitchen::Provisioner::Base

      def verify_dependencies
        raise UserError, "Oh noes, you don't have software!"
      end
    end
  end
end

describe Kitchen::Provisioner do

  describe ".for_plugin" do

    before do
      Kitchen::Provisioner.stubs(:require).returns(true)
    end

    it "returns a provisioner object of the correct class" do
      provisioner = Kitchen::Provisioner.for_plugin("coolbeans", {})

      provisioner.must_be_kind_of Kitchen::Provisioner::Coolbeans
    end

    it "returns a provisioner initialized with its config" do
      provisioner = Kitchen::Provisioner.for_plugin("coolbeans", :foo => "bar")

      provisioner[:foo].must_equal "bar"
    end

    it "calls #verify_dependencies on the provisioner object" do
      provisioner = Kitchen::Provisioner.for_plugin("it_depends", {})

      provisioner.verify_call_count.must_equal 1
    end

    it "calls #verify_dependencies once per provisioner require" do
      Kitchen::Provisioner.stubs(:require).returns(true, false)
      provisioner1 = Kitchen::Provisioner.for_plugin("it_depends", {})
      provisioner1.verify_call_count.must_equal 1
      provisioner2 = Kitchen::Provisioner.for_plugin("it_depends", {})

      provisioner2.verify_call_count.must_equal 0
    end

    it "raises ClientError if the provisioner could not be required" do
      Kitchen::Provisioner.stubs(:require).raises(LoadError)

      proc { Kitchen::Provisioner.for_plugin("coolbeans", {}) }.
        must_raise Kitchen::ClientError
    end

    it "raises ClientError if the provisioner's class constant was not found" do
      # pretend require worked
      Kitchen::Provisioner.stubs(:require).returns(true)

      proc { Kitchen::Provisioner.for_plugin("nope", {}) }.
        must_raise Kitchen::ClientError
    end
  end
end
