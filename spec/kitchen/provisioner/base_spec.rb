# -*- encoding: utf-8 -*-
#
# Author:: Fletcher Nichol (<fnichol@nichol.ca>)
#
# Copyright (C) 2013, Fletcher Nichol
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

  module Provisioner

    class TestingDummy < Kitchen::Provisioner::Base

      attr_reader :called_create_sandbox, :called_cleanup_sandbox

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

      def create_sandbox
        @called_create_sandbox = true
      end

      def cleanup_sandbox
        @called_cleanup_sandbox = true
      end

      def sandbox_path
        "/tmp/sandbox"
      end
    end
  end
end

describe Kitchen::Provisioner::Base do

  let(:logged_output)   { StringIO.new }
  let(:logger)          { Logger.new(logged_output) }
  let(:platform)        { stub(:os_type => nil, :shell_type => nil) }
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
      :transport => transport
    )
  end

  let(:provisioner) do
    Kitchen::Provisioner::Base.new(config).finalize_config!(instance)
  end

  describe "configuration" do

    describe "for unix operating systems" do

      before { platform.stubs(:os_type).returns("unix") }

      it ":root_path defaults to /tmp/kitchen" do
        provisioner[:root_path].must_equal "/tmp/kitchen"
      end

      it ":sudo defaults to true" do
        provisioner[:sudo].must_equal true
      end

      it ":sudo_command defaults to sudo -E" do
        provisioner[:sudo_command].must_equal "sudo -E"
      end
    end

    describe "for windows operating systems" do

      before { platform.stubs(:os_type).returns("windows") }

      it ":root_path defaults to $env:TEMP\\kitchen" do
        provisioner[:root_path].must_equal "$env:TEMP\\kitchen"
      end

      it ":sudo defaults to nil" do
        provisioner[:sudo].must_equal nil
      end

      it ":sudo_command defaults to nil" do
        provisioner[:sudo_command].must_equal nil
      end
    end

    it ":http_proxy defaults to nil" do
      provisioner[:http_proxy].must_equal nil
    end

    it ":http_proxys defaults to nil" do
      provisioner[:https_proxy].must_equal nil
    end

    it ":ftp_proxy defaults to nil" do
      provisioner[:ftp_proxy].must_equal nil
    end
  end

  describe "#call" do

    let(:state) { Hash.new }
    let(:cmd)   { provisioner.call(state) }

    let(:connection) do
      c = mock("transport_connection")
      c.responds_like_instance_of(Kitchen::Transport::Base::Connection)
      c
    end

    let(:provisioner) do
      Kitchen::Provisioner::TestingDummy.new(config).finalize_config!(instance)
    end

    before do
      FakeFS.activate!
      FileUtils.mkdir_p(File.join(provisioner.sandbox_path, "stuff"))
      transport.stubs(:connection).yields(connection)
      connection.stubs(:execute)
      connection.stubs(:execute_with_retry)
      connection.stubs(:upload)
    end

    after do
      FakeFS.deactivate!
      FakeFS::FileSystem.clear
    end

    it "creates the sandbox" do
      provisioner.expects(:create_sandbox)

      cmd
    end

    it "ensures that the sandbox is cleanup up" do
      transport.stubs(:connection).raises
      provisioner.expects(:cleanup_sandbox)

      begin
        cmd
      rescue # rubocop:disable Lint/HandleExceptions
      end
    end

    it "yields a connection given the state" do
      state[:a] = "b"
      transport.expects(:connection).with(state).yields(connection)

      cmd
    end

    it "invokes the provisioner commands over the transport" do
      order = sequence("order")
      connection.expects(:execute).with("install").in_sequence(order)
      connection.expects(:execute).with("init").in_sequence(order)
      connection.expects(:execute).with("prepare").in_sequence(order)
      connection.expects(:execute_with_retry).with("run", [], 1, 30).in_sequence(order)

      cmd
    end

    it "logs to info" do
      cmd

      logged_output.string.
        must_match(/INFO -- : Transferring files to instance$/)
    end

    it "uploads sandbox files" do
      connection.expects(:upload).with(["/tmp/sandbox/stuff"], "/tmp/kitchen")

      cmd
    end

    it "logs to debug" do
      cmd

      logged_output.string.must_match(/DEBUG -- : Transfer complete$/)
    end

    it "raises an ActionFailed on transfer when TransportFailed is raised" do
      connection.stubs(:upload).
        raises(Kitchen::Transport::TransportFailed.new("dang"))

      proc { cmd }.must_raise Kitchen::ActionFailed
    end

    it "raises an ActionFailed on execute when TransportFailed is raised" do
      connection.stubs(:execute).
        raises(Kitchen::Transport::TransportFailed.new("dang"))

      proc { cmd }.must_raise Kitchen::ActionFailed
    end
  end

  [:init_command, :install_command, :prepare_command, :run_command].each do |cmd|

    it "has a #{cmd} method" do
      provisioner.public_send(cmd).must_be_nil
    end
  end

  describe "sandbox" do

    after do
      begin
        provisioner.cleanup_sandbox
      rescue # rubocop:disable Lint/HandleExceptions
      end
    end

    it "raises ClientError if #sandbox_path is called before #create_sandbox" do
      proc { provisioner.sandbox_path }.must_raise Kitchen::ClientError
    end

    it "#create_sandbox creates a temporary directory" do
      provisioner.create_sandbox

      File.directory?(provisioner.sandbox_path).must_equal true
      format("%o", File.stat(provisioner.sandbox_path).mode)[1, 4].
        must_equal "0755"
    end

    it "#create_sandbox logs an info message" do
      provisioner.create_sandbox

      logged_output.string.must_match info_line("Preparing files for transfer")
    end

    it "#create_sandbox logs a debug message" do
      provisioner.create_sandbox

      logged_output.string.
        must_match debug_line_starting_with("Creating local sandbox in ")
    end

    it "#cleanup_sandbox deletes the sandbox directory" do
      provisioner.create_sandbox
      provisioner.cleanup_sandbox

      File.directory?(provisioner.sandbox_path).must_equal false
    end

    it "#cleanup_sandbox logs a debug message" do
      provisioner.create_sandbox
      provisioner.cleanup_sandbox

      logged_output.string.
        must_match debug_line_starting_with("Cleaning up local sandbox in ")
    end

    def info_line(msg)
      %r{^I, .* : #{Regexp.escape(msg)}$}
    end

    def debug_line_starting_with(msg)
      %r{^D, .* : #{Regexp.escape(msg)}}
    end
  end

  describe "#sudo" do

    describe "with :sudo set" do

      before { config[:sudo] = true }

      it "prepends sudo command" do
        provisioner.send(:sudo, "wakka").must_equal("sudo -E wakka")
      end

      it "customizes sudo when :sudo_command is set" do
        config[:sudo_command] = "blueto -Ohai"

        provisioner.send(:sudo, "wakka").must_equal("blueto -Ohai wakka")
      end
    end

    describe "with :sudo falsey" do

      before { config[:sudo] = false }

      it "does not include sudo command" do
        provisioner.send(:sudo, "wakka").must_equal("wakka")
      end

      it "does not include sudo command, even when :sudo_command is set" do
        config[:sudo_command] = "blueto -Ohai"

        provisioner.send(:sudo, "wakka").must_equal("wakka")
      end
    end
  end

  describe "#sudo_command" do

    describe "with :sudo set" do

      before { config[:sudo] = true }

      it "returns the default sudo_command" do
        provisioner.send(:sudo_command).must_equal("sudo -E")
      end

      it "returns the custom sudo_command" do
        config[:sudo_command] = "mysudo"

        provisioner.send(:sudo_command).must_equal("mysudo")
      end
    end

    describe "with :sudo falsey" do

      before { config[:sudo] = false }

      it "returns empty string for default sudo_command" do
        provisioner.send(:sudo_command).must_equal("")
      end

      it "returns empty string for custom sudo_command" do
        config[:sudo_command] = "mysudo"

        provisioner.send(:sudo_command).must_equal("")
      end
    end
  end

  describe "#prefix_command" do

    describe "with :command_prefix set" do

      before { config[:command_prefix] = "my_prefix" }

      it "prepends the command with the prefix" do
        provisioner.send(:prefix_command, "my_command").must_equal("my_prefix my_command")
      end
    end

    describe "with :command_prefix unset" do

      before { config[:command_prefix] = nil }

      it "returns an unaltered command" do
        provisioner.send(:prefix_command, "my_command").must_equal("my_command")
      end
    end
  end
end
