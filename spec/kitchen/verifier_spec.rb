# -*- encoding: utf-8 -*-
#
# Author:: Fletcher Nichol (<fnichol@nichol.ca>)
#
# Copyright (C) 2015, Fletcher Nichol
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

require "kitchen/verifier"

require "kitchen/configurable"
module Kitchen
  module Verifier
    class Base
      include Configurable
      def initialize(config = {})
        init_config(config)
      end
    end
  end
end

module Kitchen
  module Verifier
    class Coolbeans < Kitchen::Verifier::Base
    end

    class ItDepends < Kitchen::Verifier::Base
      attr_reader :verify_call_count

      def initialize(config = {})
        @verify_call_count = 0
        super
      end

      def verify_dependencies
        @verify_call_count += 1
      end
    end

    class UnstableDepends < Kitchen::Verifier::Base
      def verify_dependencies
        raise UserError, "Oh noes, you don't have software!"
      end
    end
  end
end

describe Kitchen::Verifier do
  describe ".for_plugin" do
    before do
      Kitchen::Verifier.stubs(:require).returns(true)
    end

    it "returns a verifier object of the correct class" do
      verifier = Kitchen::Verifier.for_plugin("coolbeans", {})

      verifier.must_be_kind_of Kitchen::Verifier::Coolbeans
    end

    it "returns a verifier initialized with its config" do
      verifier = Kitchen::Verifier.for_plugin("coolbeans", foo: "bar")

      verifier[:foo].must_equal "bar"
    end

    it "calls #verify_dependencies on the transport object" do
      verifier = Kitchen::Verifier.for_plugin("it_depends", {})

      verifier.verify_call_count.must_equal 1
    end

    it "calls #verify_dependencies once per verifier require" do
      Kitchen::Verifier.stubs(:require).returns(true, false)
      verifier1 = Kitchen::Verifier.for_plugin("it_depends", {})
      verifier1.verify_call_count.must_equal 1
      verifier2 = Kitchen::Verifier.for_plugin("it_depends", {})

      verifier2.verify_call_count.must_equal 0
    end

    it "raises ClientError if the verifier could not be required" do
      Kitchen::Verifier.stubs(:require).raises(LoadError)

      proc { Kitchen::Verifier.for_plugin("coolbeans", {}) }
        .must_raise Kitchen::ClientError
    end

    it "raises ClientError if the verifier's class constant was not found" do
      # pretend require worked
      Kitchen::Verifier.stubs(:require).returns(true)

      proc { Kitchen::Verifier.for_plugin("nope", {}) }
        .must_raise Kitchen::ClientError
    end

    it "raises UserError if #verify_dependencies failes" do
      proc { Kitchen::Verifier.for_plugin("unstable_depends", {}) }
        .must_raise Kitchen::UserError
    end
  end
end
