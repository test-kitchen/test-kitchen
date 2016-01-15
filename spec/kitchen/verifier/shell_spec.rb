# -*- encoding: utf-8 -*-
#
# Author:: SAWANOBORI Yukihiko (<sawanoboriyu@higanworks.com>)
#
# Copyright (C) 2015, HiganWorks LLC
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

require "kitchen/verifier/shell"

describe Kitchen::Verifier::Shell do

  let(:logged_output) { StringIO.new }
  let(:logger)        { Logger.new(logged_output) }
  let(:platform)      { stub(:os_type => nil, :shell_type => nil, :name => "coolbeans") }
  let(:suite)         { stub(:name => "fries") }
  let(:state)         { Hash.new }

  let(:config) do
    { :test_base_path => "/basist", :kitchen_root => "/rooty" }
  end

  let(:instance) do
    stub(
      :name => [platform.name, suite.name].join("-"),
      :to_str => "instance",
      :logger => logger,
      :suite => suite,
      :platform => platform
    )
  end

  let(:verifier) do
    Kitchen::Verifier::Shell.new(config).finalize_config!(instance)
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

    it "sets :command to 'true' by default" do
      verifier[:command].must_equal "true"
    end

    it "sets :live_stream to stdout by default" do
      verifier[:live_stream].must_equal $stdout
    end
  end

  describe "#call" do

    describe "#shell_out" do
      it "calls sleep if :sleep value is greater than 0" do
        config[:sleep] = 3
        verifier.expects(:sleep).with(1).returns(true).at_least(3)

        verifier.call(state)
      end

      it "states are set to environment" do
        state[:hostname] = "testhost"
        state[:server_id] = "i-xxxxxx"
        verifier.call(state)
        config[:shellout_opts][:environment]["KITCHEN_HOSTNAME"].must_equal "testhost"
        config[:shellout_opts][:environment]["KITCHEN_SERVER_ID"].must_equal "i-xxxxxx"
        config[:shellout_opts][:environment]["KITCHEN_INSTANCE"].must_equal "coolbeans-fries"
        config[:shellout_opts][:environment]["KITCHEN_PLATFORM"].must_equal "coolbeans"
        config[:shellout_opts][:environment]["KITCHEN_SUITE"].must_equal "fries"
      end

      it "raises ActionFailed if set false to :command" do
        config[:command] = "false"

        proc { verifier.call(state) }.must_raise Kitchen::ActionFailed
      end

      it "logs a converge event to INFO" do
        verifier.call(state)

        logged_output.string.must_match(/^.+ INFO .+ \[Shell\] Verify on .+$/)
      end
    end

    describe "remote_exec" do
      let(:transport) do
        t = mock("transport")
        t.responds_like_instance_of(Kitchen::Transport::Ssh)
        t
      end

      let(:connection) do
        c = mock("transport_connection")
        c.responds_like_instance_of(Kitchen::Transport::Ssh::Connection)
        c
      end

      let(:instance) do
        stub(
          :name => "coolbeans",
          :to_str => "instance",
          :logger => logger,
          :platform => platform,
          :suite => suite,
          :transport => transport
        )
      end

      before do
        transport.stubs(:connection).yields(connection)
        connection.stubs(:execute)
      end

      it "execute command onto instance." do
        config[:remote_exec] = true

        transport.expects(:connection).with(state).yields(connection)
        verifier.call(state)
      end
    end
  end

  describe "#run_command" do
    it "execute localy and returns nil" do
      verifier.run_command
    end

    it "returns string when remote_exec" do
      config[:remote_exec] = true
      verifier.run_command.must_equal "true"
    end
  end
end
