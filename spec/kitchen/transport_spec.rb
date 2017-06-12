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

require "kitchen/configurable"
require "kitchen/errors"
require "kitchen/logging"
require "kitchen/transport"
require "kitchen/transport/base"

module Kitchen
  module Transport
    class Coolbeans < Kitchen::Transport::Base
    end

    class ItDepends < Kitchen::Transport::Base
      attr_reader :verify_call_count

      def initialize(config = {})
        @verify_call_count = 0
        super
      end

      def verify_dependencies
        @verify_call_count += 1
      end
    end

    class UnstableDepends < Kitchen::Transport::Base
      def verify_dependencies
        raise UserError, "Oh noes, you don't have software!"
      end
    end
  end
end

describe Kitchen::Transport do
  describe ".for_plugin" do
    before do
      Kitchen::Transport.stubs(:require).returns(true)
    end

    it "returns a transport object of the correct class" do
      transport = Kitchen::Transport.for_plugin("coolbeans", {})

      transport.must_be_kind_of Kitchen::Transport::Coolbeans
    end

    it "returns a transport initialized with its config" do
      transport = Kitchen::Transport.for_plugin("coolbeans", foo: "bar")

      transport[:foo].must_equal "bar"
    end

    it "calls #verify_dependencies on the transport object" do
      transport = Kitchen::Transport.for_plugin("it_depends", {})

      transport.verify_call_count.must_equal 1
    end

    it "calls #verify_dependencies once per transport require" do
      Kitchen::Transport.stubs(:require).returns(true, false)
      transport1 = Kitchen::Transport.for_plugin("it_depends", {})
      transport1.verify_call_count.must_equal 1
      transport2 = Kitchen::Transport.for_plugin("it_depends", {})

      transport2.verify_call_count.must_equal 0
    end

    it "raises ClientError if the transport could not be required" do
      Kitchen::Transport.stubs(:require).raises(LoadError)

      proc { Kitchen::Transport.for_plugin("coolbeans", {}) }
        .must_raise Kitchen::ClientError
    end

    it "raises ClientError if the transport's class constant was not found" do
      # pretend require worked
      Kitchen::Transport.stubs(:require).returns(true)

      proc { Kitchen::Transport.for_plugin("nope", {}) }
        .must_raise Kitchen::ClientError
    end

    it "raises UserError if #verify_dependencies failes" do
      proc { Kitchen::Transport.for_plugin("unstable_depends", {}) }
        .must_raise Kitchen::UserError
    end
  end
end
