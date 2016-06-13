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

require "kitchen"

describe Kitchen::Transport::Base do

  let(:logged_output)   { StringIO.new }
  let(:logger)          { Logger.new(logged_output) }
  let(:config)          { Hash.new }

  let(:instance) do
    stub(:name => "coolbeans", :logger => logger)
  end

  let(:transport) do
    Kitchen::Transport::Base.new(config).finalize_config!(instance)
  end

  it "has an #connection method which raises a ClientError" do
    proc { transport.connection({}) }.must_raise Kitchen::ClientError
  end

  describe "#logger" do

    before  { @klog = Kitchen.logger }
    after   { Kitchen.logger = @klog }

    it "returns the instance's logger" do
      transport.send(:logger).must_equal logger
    end

    it "returns the default logger if instance's logger is not set" do
      transport = Kitchen::Transport::Base.new(config)
      Kitchen.logger = "yep"

      transport.send(:logger).must_equal Kitchen.logger
    end
  end

  describe Kitchen::Transport::TransportFailed do

    let(:failure_with_no_exit_code) { Kitchen::Transport::TransportFailed.new("Boom") }
    let(:failure_with_exit_code) { Kitchen::Transport::TransportFailed.new("Boom", 123) }

    describe "when no exit code is provided" do

      it "#exit_code is nil" do
        failure_with_no_exit_code.exit_code.must_be_nil
      end
    end

    describe "when an exit code is provided" do

      it "#exit_code returns the supplied exit code" do
        failure_with_exit_code.exit_code.must_equal 123
      end
    end
  end

end

describe Kitchen::Transport::Base::Connection do

  let(:logged_output)   { StringIO.new }
  let(:logger)          { Logger.new(logged_output) }
  let(:options)         { { :logger => logger } }

  let(:connection) do
    Kitchen::Transport::Base::Connection.new(options)
  end

  it "has a #close method that does nothing" do
    connection.close.must_be_nil
  end

  it "has an #execute method which raises a ClientError" do
    proc { connection.execute("boo") }.must_raise Kitchen::ClientError
  end

  it "has a #login_command method which raises an ActionFailed" do
    proc { connection.login_command }.must_raise Kitchen::ActionFailed
  end

  it "has an #upload method which raises a ClientError" do
    proc { connection.upload(["file"], "/path/to") }.
      must_raise Kitchen::ClientError
  end

  it "has a #wait_until_ready method that does nothing" do
    connection.wait_until_ready.must_be_nil
  end

  describe "#execute_with_retry" do

    let(:failure_with_exit_code) { Kitchen::Transport::TransportFailed.new("Boom", 123) }

    it "raises ClientError with no retries" do
      proc { connection.execute_with_retry("hi", [], nil, nil) }.
        must_raise Kitchen::ClientError
    end

    it "retries three times" do
      connection.expects(:execute).with("Hi").returns("Hello")
      connection.expects(:debug).with("Attempting to execute command - try 3 of 3.")
      connection.expects(:execute).with("Hi").raises(failure_with_exit_code)
      connection.expects(:debug).with("Attempting to execute command - try 2 of 3.")
      connection.expects(:execute).with("Hi").raises(failure_with_exit_code)
      connection.expects(:debug).with("Attempting to execute command - try 1 of 3.")

      connection.execute_with_retry("Hi", [123], 3, 1).must_equal "Hello"
    end
  end
end
