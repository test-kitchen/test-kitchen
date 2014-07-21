# -*- encoding: utf-8 -*-
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
  let(:state)         { Hash.new }

  let(:config) do
    { :host => "foobnoobs.com", :reset_command => "mulligan" }
  end

  let(:instance) do
    stub(:name => "coolbeans", :logger => logger, :to_str => "instance")
  end

  let(:driver) do
    Kitchen::Driver::Proxy.new(config).finalize_config!(instance)
  end

  describe "non-parallel action" do

    it "create must be serially executed" do
      Kitchen::Driver::Proxy.serial_actions.must_include :create
    end

    it "destroy must be serially executed" do
      Kitchen::Driver::Proxy.serial_actions.must_include :destroy
    end
  end

  describe "required_config" do

    [:host, :reset_command].each do |attr|
      it "requires :#{attr}" do
        config.delete(attr)

        begin
          driver
          flunk "UserError must be raised for missing :#{attr}"
        rescue Kitchen::UserError => e
          e.message.must_match regexify("config[:#{attr}] cannot be blank")
        end
      end
    end

    def regexify(str)
      Regexp.new(Regexp.escape(str))
    end
  end

  describe "#create" do

    it "sets :hostname in state config" do
      driver.stubs(:ssh)
      driver.create(state)

      state[:hostname].must_equal "foobnoobs.com"
    end

    it "calls the reset command over ssh" do
      driver.expects(:ssh).with do |ssh_args, cmd|
        ssh_args[0].must_equal "foobnoobs.com"
        cmd.must_equal "mulligan"
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

      state[:hostname].must_equal nil
    end

    it "calls the reset command over ssh" do
      driver.expects(:ssh).with do |ssh_args, cmd|
        ssh_args[0].must_equal "beep"
        cmd.must_equal "mulligan"
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
