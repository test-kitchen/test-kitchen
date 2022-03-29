#
# Author:: Fletcher Nichol (<fnichol@nichol.ca>)
#
# Copyright (C) 2014, Fletcher Nichol
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

require "kitchen/driver/proxy"

describe Kitchen::Driver::Proxy do
  let(:logged_output) { StringIO.new }
  let(:logger)        { Logger.new(logged_output) }
  let(:state)         { {} }

  let(:config) do
    { host: "foobnoobs.com", reset_command: "mulligan" }
  end

  let(:instance) do
    stub(name: "coolbeans", logger: logger, to_str: "instance")
  end

  let(:driver) do
    Kitchen::Driver::Proxy.new(config).finalize_config!(instance)
  end

  it "plugin_version is set to Kitchen::VERSION" do
    _(driver.diagnose_plugin[:version]).must_equal Kitchen::VERSION
  end

  describe "non-parallel action" do
    it "create must be serially executed" do
      _(Kitchen::Driver::Proxy.serial_actions).must_include :create
    end

    it "destroy must be serially executed" do
      _(Kitchen::Driver::Proxy.serial_actions).must_include :destroy
    end
  end

  describe "required_config" do
    it "requires host" do
      config.delete(:host)
      err = assert_raises(Kitchen::UserError) { driver }
      _(err.message).must_include "config[:host] cannot be blank"
    end

    it "does not require reset_command" do
      config.delete(:reset_command)
      driver # Just make sure it doesn't raise
    end
  end

  describe "#create" do
    it "sets :hostname in state config" do
      driver.stubs(:ssh)
      driver.create(state)

      _(state[:hostname]).must_equal "foobnoobs.com"
    end

    it "calls the reset command over ssh" do
      driver.expects(:ssh).with do |ssh_args, cmd|
        _(ssh_args[0]).must_equal "foobnoobs.com"
        _(cmd).must_equal "mulligan"
      end

      driver.create(state)
    end

    it "skips ssh call if :reset_command is falsey" do
      config[:reset_command] = false
      driver.expects(:ssh).never

      driver.create(state)
    end
  end

  describe "#destroy" do
    before do
      state[:hostname] = "beep"
    end

    it "deletes :hostname in state config" do
      driver.stubs(:ssh)
      driver.destroy(state)

      _(state[:hostname]).must_be_nil
    end

    it "calls the reset command over ssh" do
      driver.expects(:ssh).with do |ssh_args, cmd|
        _(ssh_args[0]).must_equal "beep"
        _(cmd).must_equal "mulligan"
      end

      driver.destroy(state)
    end

    it "skips ssh call if :hostname is not in state config" do
      state.delete(:hostname)
      driver.expects(:ssh).never

      driver.destroy(state)
    end

    it "skips ssh call if :reset_command is falsey" do
      config[:reset_command] = false
      driver.expects(:ssh).never

      driver.destroy(state)
    end
  end
end
