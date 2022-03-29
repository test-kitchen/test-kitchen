#
# Author:: Fletcher Nichol (<fnichol@nichol.ca>)
#
# Copyright (C) 2012, Fletcher Nichol
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

require "kitchen"

module Kitchen
  module Driver
    class Speedy < Base
    end

    class Dodgy < Base
      no_parallel_for :setup
    end

    class Slow < Base
      no_parallel_for :create, :destroy
      no_parallel_for :verify
    end
  end
end

describe Kitchen::Driver::Base do
  let(:logged_output) { StringIO.new }
  let(:logger)        { Logger.new(logged_output) }
  let(:config)        { {} }
  let(:state)         { {} }

  let(:busser) do
    stub(setup_cmd: "setup", sync_cmd: "sync", run_cmd: "run")
  end

  let(:instance) do
    stub(
      name: "coolbeans",
      logger: logger,
      busser: busser,
      to_str: "instance"
    )
  end

  let(:driver) do
    Kitchen::Driver::Base.new(config).finalize_config!(instance)
  end

  it "#instance returns its instance" do
    _(driver.instance).must_equal instance
  end

  it "#puts calls logger.info" do
    driver.send(:puts, "yo")

    _(logged_output.string).must_match(/I, /)
    _(logged_output.string).must_match(/yo\n/)
  end

  it "#print calls logger.info" do
    driver.send(:print, "yo")

    _(logged_output.string).must_match(/I, /)
    _(logged_output.string).must_match(/yo\n/)
  end

  %i{create setup verify destroy}.each do |action|
    it "has a #{action} method that takes state" do
      # TODO: revert back
      # state = Hash.new
      # driver.public_send(action, state).must_be_nil
      driver.respond_to?(action)
    end
  end

  describe ".pre_create_command" do
    it "run command" do
      Kitchen::Driver::Base.any_instance.stubs(:run_command).returns(true)

      config[:pre_create_command] = "echo works 2&>1 > /dev/null"
      driver.expects(:run_command).with("echo works 2&>1 > /dev/null")
      driver.send(:pre_create_command)
    end

    it "error if cannot run" do
      class ShellCommandFailed < Kitchen::ShellOut::ShellCommandFailed; end
      Kitchen::Driver::Base.any_instance.stubs(:run_command).raises(ShellCommandFailed, "Expected process to exit with [0], but received '1'")

      config[:pre_create_command] = "touch /this/dir/does/not/exist 2&>1 > /dev/null"
      _(proc { driver.send(:pre_create_command) }).must_raise Kitchen::ActionFailed
    end
  end

  describe ".no_parallel_for" do
    it "registers no serial actions when none are declared" do
      _(Kitchen::Driver::Speedy.serial_actions).must_be_nil
    end

    it "registers a single serial action method" do
      _(Kitchen::Driver::Dodgy.serial_actions).must_equal [:setup]
    end

    it "registers multiple serial action methods" do
      actions = Kitchen::Driver::Slow.serial_actions

      _(actions).must_include :create
      _(actions).must_include :verify
      _(actions).must_include :destroy
    end

    it "raises a ClientError if value is not an action method" do
      _(proc do
        Class.new(Kitchen::Driver::Base) { no_parallel_for :telling_stories }
      end).must_raise Kitchen::ClientError
    end
  end
end
