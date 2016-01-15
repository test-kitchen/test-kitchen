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

require_relative "../../spec_helper"

require "logger"
require "stringio"

require "kitchen/verifier/dummy"

describe Kitchen::Verifier::Dummy do

  let(:logged_output) { StringIO.new }
  let(:logger)        { Logger.new(logged_output) }
  let(:platform)      { stub(:os_type => nil, :shell_type => nil) }
  let(:suite)         { stub(:name => "fries") }
  let(:state)         { Hash.new }

  let(:config) do
    { :test_base_path => "/basist", :kitchen_root => "/rooty" }
  end

  let(:instance) do
    stub(
      :name => "coolbeans",
      :to_str => "instance",
      :logger => logger,
      :suite => suite,
      :platform => platform
    )
  end

  let(:verifier) do
    Kitchen::Verifier::Dummy.new(config).finalize_config!(instance)
  end

  it "verifier api_version is 1" do
    verifier.diagnose_plugin[:api_version].must_equal 1
  end

  it "plugin_version is set to Kitchen::VERSION" do
    verifier.diagnose_plugin[:version].must_equal Kitchen::VERSION
  end

  describe "configuration" do

    it "sets :sleep to 0 by default" do
      verifier[:sleep].must_equal 0
    end

    it "sets :random_failure to false by default" do
      verifier[:random_failure].must_equal false
    end
  end

  describe "#call" do

    it "calls sleep if :sleep value is greater than 0" do
      config[:sleep] = 12.5
      verifier.expects(:sleep).with(12.5).returns(true)

      verifier.call(state)
    end

    it "raises ActionFailed if :fail is set" do
      config[:fail] = true

      proc { verifier.call(state) }.must_raise Kitchen::ActionFailed
    end

    it "randomly raises ActionFailed if :random_failure is set" do
      config[:random_failure] = true
      verifier.stubs(:randomly_fail?).returns(true)

      proc { verifier.call(state) }.must_raise Kitchen::ActionFailed
    end

    it "logs a converge event to INFO" do
      verifier.call(state)

      logged_output.string.must_match(/^.+ INFO .+ \[Dummy\] Verify on .+$/)
    end
  end
end
