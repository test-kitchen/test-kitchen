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
end
