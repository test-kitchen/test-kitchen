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

require "kitchen/verifier/base"
require "kitchen/transport/base"

module Kitchen

  module Verifier

    class TestingDummy < Kitchen::Verifier::Base

      def install_command
        "install"
      end

      def init_command
        "init"
      end

      def prepare_command
        "prepare"
      end

      def run_command
        "run"
      end
    end
  end
end

describe Kitchen::Verifier::Base do

  let(:logged_output)   { StringIO.new }
  let(:logger)          { Logger.new(logged_output) }
  let(:platform)        { stub(:os_type => nil, :shell_type => nil) }
  let(:suite)           { stub(:name => "germany") }
  let(:config)          { Hash.new }

  let(:transport) do
    t = mock("transport")
    t.responds_like_instance_of(Kitchen::Transport::Base)
    t
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

  let(:verifier) do
    Kitchen::Verifier::Base.new(config).finalize_config!(instance)
  end

  describe "configuration" do

    describe "for unix operating systems" do

      before { platform.stubs(:os_type).returns("unix") }

      it ":suite_name defaults to the passed in suite name" do
        verifier[:suite_name].must_equal "germany"
      end

      it ":sudo defaults to true" do
        verifier[:sudo].must_equal true
      end

      it ":root_path defaults to '/tmp/verifier'" do
        verifier[:root_path].must_equal "/tmp/verifier"
      end
    end
  end

  describe "#call" do

    let(:state) { Hash.new }
    let(:cmd)   { verifier.call(state) }

    let(:connection) do
      c = mock("transport_connection")
      c.responds_like_instance_of(Kitchen::Transport::Base::Connection)
      c
    end

    let(:verifier) do
      Kitchen::Verifier::TestingDummy.new(config).finalize_config!(instance)
    end

    before do
      transport.stubs(:connection).yields(connection)
      connection.stubs(:execute)
    end

    it "yields a connection given the state" do
      state[:a] = "b"
      transport.expects(:connection).with(state).yields(connection)

      cmd
    end

    it "invokes the verifier commands over the transport" do
      order = sequence("order")
      connection.expects(:execute).with("install").in_sequence(order)
      connection.expects(:execute).with("init").in_sequence(order)
      connection.expects(:execute).with("prepare").in_sequence(order)
      connection.expects(:execute).with("run").in_sequence(order)

      cmd
    end

    it "raises an ActionFailed on execute when TransportFailed is raised" do
      connection.stubs(:execute).
        raises(Kitchen::Transport::TransportFailed.new("dang"))

      proc { cmd }.must_raise Kitchen::ActionFailed
    end
  end

  [:init_command, :install_command, :prepare_command, :run_command].each do |cmd|

    it "has a #{cmd} method" do
      verifier.public_send(cmd).must_be_nil
    end
  end

  describe "#sudo" do

    it "if :sudo is set, prepend sudo command" do
      config[:sudo] = true

      verifier.send(:sudo, "wakka").must_equal("sudo -E wakka")
    end

    it "if :sudo is falsy, do not include sudo command" do
      config[:sudo] = false

      verifier.send(:sudo, "wakka").must_equal("wakka")
    end
  end
end
