#
# Author:: Matt Wrock (<matt@mattwrock.com>)
#
# Copyright (C) 2014, Matt Wrock
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

require "kitchen/transport"
require "kitchen/transport/base"

module Kitchen
  module Transport
    class Coolbeans < Kitchen::Transport::Base
    end
  end
end

describe Kitchen::Transport do
  describe ".for_plugin" do
    before do
      Kitchen::Plugin.stubs(:require).returns(true)
    end

    it "uses Kitchen::Plugin.load" do
      faux_transport = Object.new
      Kitchen::Plugin.stubs(:load).returns(faux_transport)
      transport = Kitchen::Transport.for_plugin("faux", {})

      _(transport).must_equal faux_transport
    end

    it "returns a transport object of the correct class" do
      transport = Kitchen::Transport.for_plugin("coolbeans", {})

      _(transport).must_be_kind_of Kitchen::Transport::Coolbeans
    end

    it "returns a transport initialized with its config" do
      transport = Kitchen::Transport.for_plugin("coolbeans", foo: "bar")

      _(transport[:foo]).must_equal "bar"
    end

    it "raises ClientError if the transport could not be required" do
      Kitchen::Plugin.stubs(:require).raises(LoadError)

      _ { Kitchen::Transport.for_plugin("coolbeans", {}) }
        .must_raise Kitchen::ClientError
    end

    it "raises ClientError if the transport's class constant was not found" do
      # pretend require worked
      Kitchen::Plugin.stubs(:require).returns(true)

      _ { Kitchen::Transport.for_plugin("nope", {}) }
        .must_raise Kitchen::ClientError
    end
  end
end
