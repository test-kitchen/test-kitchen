#
# Author:: Fletcher Nichol (<fnichol@nichol.ca>)
#
# Copyright (C) 2015, Fletcher Nichol
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

require_relative "../../spec_helper"

require "logger"
require "stringio"

require "kitchen/provisioner/dummy"

describe Kitchen::Provisioner::Dummy do
  let(:logged_output) { StringIO.new }
  let(:logger)        { Logger.new(logged_output) }
  let(:platform)      { stub(os_type: nil, shell_type: nil) }
  let(:suite)         { stub(name: "fries") }
  let(:state)         { {} }

  let(:config) do
    { test_base_path: "/basist", kitchen_root: "/rooty" }
  end

  let(:instance) do
    stub(
      name: "coolbeans",
      to_str: "instance",
      logger: logger,
      suite: suite,
      platform: platform
    )
  end

  let(:provisioner) do
    Kitchen::Provisioner::Dummy.new(config).finalize_config!(instance)
  end

  it "provisioner api_version is 2" do
    _(provisioner.diagnose_plugin[:api_version]).must_equal 2
  end

  it "plugin_version is set to Kitchen::VERSION" do
    _(provisioner.diagnose_plugin[:version]).must_equal Kitchen::VERSION
  end

  describe "configuration" do
    it "sets :sleep to 0 by default" do
      _(provisioner[:sleep]).must_equal 0
    end

    it "sets :random_failure to false by default" do
      _(provisioner[:random_failure]).must_equal false
    end
  end

  describe "#call" do
    it "calls sleep if :sleep value is greater than 0" do
      config[:sleep] = 12.5
      provisioner.expects(:sleep).with(12.5).returns(true)

      provisioner.call(state)
    end

    it "raises ActionFailed if :fail is set" do
      config[:fail] = true

      _ { provisioner.call(state) }.must_raise Kitchen::ActionFailed
    end

    it "randomly raises ActionFailed if :random_failure is set" do
      config[:random_failure] = true
      provisioner.stubs(:randomly_fail?).returns(true)

      _ { provisioner.call(state) }.must_raise Kitchen::ActionFailed
    end

    it "logs a converge event to INFO" do
      provisioner.call(state)

      _(logged_output.string).must_match(/^.+ INFO .+ \[Dummy\] Converge on .+$/)
    end
  end
end
