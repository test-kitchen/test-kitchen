#
# Author:: Fletcher Nichol (<fnichol@nichol.ca>)
#
# Copyright (C) 2015, Fletcher Nichol
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

require "kitchen/verifier"
require "kitchen/verifier/base"

module Kitchen
  module Verifier
    class Coolbeans < Kitchen::Verifier::Base
    end
  end
end

describe Kitchen::Verifier do
  describe ".for_plugin" do
    before do
      Kitchen::Plugin.stubs(:require).returns(true)
    end

    it "uses Kitchen::Plugin.load" do
      faux_verifier = Object.new
      Kitchen::Plugin.stubs(:load).returns(faux_verifier)
      verifier = Kitchen::Verifier.for_plugin("faux", {})

      _(verifier).must_equal faux_verifier
    end

    it "returns a verifier object of the correct class" do
      verifier = Kitchen::Verifier.for_plugin("coolbeans", {})

      _(verifier).must_be_kind_of Kitchen::Verifier::Coolbeans
    end

    it "returns a verifier initialized with its config" do
      verifier = Kitchen::Verifier.for_plugin("coolbeans", foo: "bar")

      _(verifier[:foo]).must_equal "bar"
    end

    it "raises ClientError if the verifier could not be required" do
      Kitchen::Plugin.stubs(:require).raises(LoadError)

      _ { Kitchen::Verifier.for_plugin("coolbeans", {}) }
        .must_raise Kitchen::ClientError
    end

    it "raises ClientError if the verifier's class constant was not found" do
      # pretend require worked
      Kitchen::Plugin.stubs(:require).returns(true)

      _ { Kitchen::Verifier.for_plugin("nope", {}) }
        .must_raise Kitchen::ClientError
    end
  end
end
