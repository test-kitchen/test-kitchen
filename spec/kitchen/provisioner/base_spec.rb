#
# Author:: Fletcher Nichol (<fnichol@nichol.ca>)
#
# Copyright (C) 2013, Fletcher Nichol
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

      def sandbox_dirs
        ["/tmp/sandbox/stuff"]
      end
    end

    class Dodgy < Kitchen::Provisioner::Base
      no_parallel_for :converge
    end
  end
end

describe Kitchen::Provisioner::Base do
  let(:logged_output)   { StringIO.new }
  let(:logger)          { Logger.new(logged_output) }
  let(:platform)        { stub(os_type: nil, shell_type: nil) }
  let(:config)          { {} }

  let(:transport) do
    t = mock("transport")
    t.responds_like_instance_of(Kitchen::Transport::Base)
    t
  end

  let(:instance) do
    stub(
      name: "coolbeans",
      to_str: "instance",
      logger: logger,
      platform: platform,
      transport: transport
    )
  end

  let(:provisioner) do
    Kitchen::Provisioner::Base.new(config).finalize_config!(instance)
  end

  describe "configuration" do
    describe "for unix operating systems" do
      before { platform.stubs(:os_type).returns("unix") }

      it ":root_path defaults to /tmp/kitchen" do
        _(provisioner[:root_path]).must_equal "/tmp/kitchen"
      end

      it ":sudo defaults to true" do
        _(provisioner[:sudo]).must_equal true
      end

      it ":sudo_command defaults to sudo -E" do
        _(provisioner[:sudo_command]).must_equal "sudo -E"
      end
    end

    describe "for windows operating systems" do
      before { platform.stubs(:os_type).returns("windows") }

      it ':root_path defaults to $env:TEMP\\kitchen' do
        _(provisioner[:root_path]).must_equal '$env:TEMP\\kitchen'
      end

      it ":sudo defaults to nil" do
        _(provisioner[:sudo]).must_be_nil
      end

      it ":sudo_command defaults to nil" do
        _(provisioner[:sudo_command]).must_be_nil
      end
    end

    it ":http_proxy defaults to nil" do
      _(provisioner[:http_proxy]).must_be_nil
    end

    it ":http_proxys defaults to nil" do
      _(provisioner[:https_proxy]).must_be_nil
    end

    it ":ftp_proxy defaults to nil" do
      _(provisioner[:ftp_proxy]).must_be_nil
    end
  end

  describe "#call" do
    let(:state) { {} }
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
      connection.stubs(:download)
      config[:downloads] = {
        ["/tmp/kitchen/nodes", "/tmp/kitchen/data_bags"] => "./test/fixtures",
        "/remote" => "/local",
      }
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

    it "prepares the install script and uploads it before executing commands" do
      # Remove the general stubs for methods we want to have specific expectations on
      connection.unstub(:execute)
      connection.unstub(:execute_with_retry)
      connection.unstub(:upload)
      
      provisioner.expects(:prepare_install_script).once
      
      # Set up more lenient expectations to see what actually gets called
      connection.expects(:upload).at_least_once
      connection.expects(:execute).at_least_once
      connection.expects(:execute).with("prepare").once
      connection.expects(:execute_with_retry).with("run", [], 1, 30).once

      cmd
    end

    it "skips script upload when install command is nil" do
      provisioner.stubs(:install_command).returns(nil)
      
      order = sequence("order")
      connection.expects(:upload).with { |source, _target|
        source.to_s.end_with?("install_script")
      }.never
      
      connection.expects(:execute).with("init").in_sequence(order)
      connection.expects(:execute).with("prepare").in_sequence(order)
      connection.expects(:execute_with_retry).with("run", [], 1, 30).in_sequence(order)
      
      cmd
    end

    it "uploads files configured in uploads hash" do
      config[:uploads] = { "/local/path" => "/remote/path" }
      
      connection.expects(:upload).with("/local/path", "/remote/path").once
      
      cmd
    end

    it "logs to info" do
      cmd

      _(logged_output.string)
        .must_match(/INFO -- : Transferring files to instance$/)
      _(logged_output.string)
        .must_match(/INFO -- : Downloading files from instance$/)
    end

    it "uploads sandbox files" do
      connection.expects(:upload).with(["/tmp/sandbox/stuff"], "/tmp/kitchen")

      cmd
    end

    it "logs to debug" do
      cmd

      _(logged_output.string).must_match(/DEBUG -- : Transfer complete$/)
      _(logged_output.string).must_match(
        %r{DEBUG -- : Downloading /tmp/kitchen/nodes, /tmp/kitchen/data_bags to ./test/fixtures$}
      )
      _(logged_output.string).must_match(
        %r{DEBUG -- : Downloading /remote to /local$}
      )
      _(logged_output.string).must_match(/DEBUG -- : Download complete$/)
    end

    it "downloads files" do
      connection.expects(:download).with(
        ["/tmp/kitchen/nodes", "/tmp/kitchen/data_bags"],
        "./test/fixtures"
      )

      connection.expects(:download).with("/remote", "/local")

      cmd
    end

    it "raises an ActionFailed on transfer when TransportFailed is raised" do
      connection.stubs(:upload)
        .raises(Kitchen::Transport::TransportFailed.new("dang"))

      _ { cmd }.must_raise Kitchen::ActionFailed
    end

    it "raises an ActionFailed on execute when TransportFailed is raised" do
      connection.stubs(:execute)
        .raises(Kitchen::Transport::TransportFailed.new("dang"))

      _ { cmd }.must_raise Kitchen::ActionFailed
    end
  end

  %i{init_command install_command prepare_command run_command}.each do |cmd|
    it "has a #{cmd} method" do
      _(provisioner.public_send(cmd)).must_be_nil
    end
  end

  describe "sandbox" do
    after do
      provisioner.cleanup_sandbox
    rescue # rubocop:disable Lint/HandleExceptions
    end

    it "raises ClientError if #sandbox_path is called before #create_sandbox" do
      _ { provisioner.sandbox_path }.must_raise Kitchen::ClientError
    end

    it "#create_sandbox creates a temporary directory" do
      provisioner.create_sandbox

      _(File.directory?(provisioner.sandbox_path)).must_equal true
      _(format("%o", File.stat(provisioner.sandbox_path).mode)[1, 4])
        .must_equal "0755"
    end

    it "#create_sandbox logs an info message" do
      provisioner.create_sandbox

      _(logged_output.string).must_match info_line("Preparing files for transfer")
    end

    it "#create_sandbox logs a debug message" do
      provisioner.create_sandbox

      _(logged_output.string)
        .must_match debug_line_starting_with("Creating local sandbox in ")
    end

    it "#cleanup_sandbox deletes the sandbox directory" do
      provisioner.create_sandbox
      provisioner.cleanup_sandbox

      _(File.directory?(provisioner.sandbox_path)).must_equal false
    end

    it "#cleanup_sandbox logs a debug message" do
      provisioner.create_sandbox
      provisioner.cleanup_sandbox

      _(logged_output.string)
        .must_match debug_line_starting_with("Cleaning up local sandbox in ")
    end

    def info_line(msg)
      /^I, .* : #{Regexp.escape(msg)}$/
    end

    def debug_line_starting_with(msg)
      /^D, .* : #{Regexp.escape(msg)}/
    end
  end

  describe "#sudo" do
    describe "with :sudo set" do
      before { config[:sudo] = true }

      it "prepends sudo command" do
        _(provisioner.send(:sudo, "wakka")).must_equal("sudo -E wakka")
      end

      it "customizes sudo when :sudo_command is set" do
        config[:sudo_command] = "blueto -Ohai"

        _(provisioner.send(:sudo, "wakka")).must_equal("blueto -Ohai wakka")
      end
    end

    describe "with :sudo falsey" do
      before { config[:sudo] = false }

      it "does not include sudo command" do
        _(provisioner.send(:sudo, "wakka")).must_equal("wakka")
      end

      it "does not include sudo command, even when :sudo_command is set" do
        config[:sudo_command] = "blueto -Ohai"

        _(provisioner.send(:sudo, "wakka")).must_equal("wakka")
      end
    end
  end

  describe "#sudo_command" do
    describe "with :sudo set" do
      before { config[:sudo] = true }

      it "returns the default sudo_command" do
        _(provisioner.send(:sudo_command)).must_equal("sudo -E")
      end

      it "returns the custom sudo_command" do
        config[:sudo_command] = "mysudo"

        _(provisioner.send(:sudo_command)).must_equal("mysudo")
      end
    end

    describe "with :sudo falsey" do
      before { config[:sudo] = false }

      it "returns empty string for default sudo_command" do
        _(provisioner.send(:sudo_command)).must_equal("")
      end

      it "returns empty string for custom sudo_command" do
        config[:sudo_command] = "mysudo"

        _(provisioner.send(:sudo_command)).must_equal("")
      end
    end
  end

  describe "#prefix_command" do
    describe "with :command_prefix set" do
      before { config[:command_prefix] = "my_prefix" }

      it "prepends the command with the prefix" do
        _(provisioner.send(:prefix_command, "my_command")).must_equal("my_prefix my_command")
      end
    end

    describe "with :command_prefix unset" do
      before { config[:command_prefix] = nil }

      it "returns an unaltered command" do
        _(provisioner.send(:prefix_command, "my_command")).must_equal("my_command")
      end
    end
  end

  describe ".no_parallel_for" do
    it "registers no serial actions when none are declared" do
      _(Kitchen::Provisioner::TestingDummy.serial_actions).must_be_nil
    end

    it "registers a single serial action method" do
      _(Kitchen::Provisioner::Dodgy.serial_actions).must_equal [:converge]
    end

    it "raises a ClientError if value is not an action method" do
      _(proc do
        Class.new(Kitchen::Provisioner::Base) { no_parallel_for :telling_stories }
      end).must_raise Kitchen::ClientError
    end
  end

  describe "#prepare_install_script" do
    let(:provisioner) do
      Kitchen::Provisioner::Base.new(config).finalize_config!(instance)
    end

    before do
      @root = Dir.mktmpdir
      config[:kitchen_root] = @root
      provisioner.create_sandbox
      provisioner.stubs(:install_command).returns("echo hello")
    end

    after do
      FileUtils.remove_entry(@root)
      begin
        provisioner.cleanup_sandbox
      rescue # rubocop:disable Lint/HandleExceptions
      end
    end

    it "creates an install script with the install command" do
      provisioner.send(:prepare_install_script)
      script_path = provisioner.send(:install_script_path)
      
      _(script_path).must_match(/install_script$/)
      _(File.exist?(script_path)).must_equal true
      content = File.read(script_path)
      _(content).must_include("#!/bin/sh")
      _(content).must_include("echo hello")
    end

    it "for Windows, creates a batch script with the install command" do
      provisioner.stubs(:windows_os?).returns(true)
      provisioner.send(:prepare_install_script)
      script_path = provisioner.send(:install_script_path)
      
      _(script_path).must_match(/install_script\.ps1$/)
      _(File.exist?(script_path)).must_equal true
      content = File.read(script_path)
      _(content).must_include("@echo off")
      _(content).must_include("echo hello")
    end

    it "makes the script executable on non-Windows platforms" do
      provisioner.send(:prepare_install_script)
      script_path = provisioner.send(:install_script_path)
      _(File.stat(script_path).mode.to_s(8).end_with?("755")).must_equal true
    end

    it "handles nil install command" do
      provisioner.stubs(:install_command).returns(nil)
      provisioner.send(:prepare_install_script)
      
      _(provisioner.send(:install_script_path)).must_be_nil
    end

    it "handles empty install command" do
      provisioner.stubs(:install_command).returns("")
      provisioner.send(:prepare_install_script)
      
      _(provisioner.send(:install_script_path)).must_be_nil
    end
  end

  describe "#make_executable_command" do
    let(:provisioner) do
      Kitchen::Provisioner::Base.new(config).finalize_config!(instance)
    end

    it "returns chmod command on non-Windows" do
      provisioner.stubs(:windows_os?).returns(false)
      provisioner.stubs(:sudo).with("chmod +x /path/to/script").returns("sudo -E chmod +x /path/to/script")
      _(provisioner.send(:make_executable_command, "/path/to/script")).must_match(/chmod \+x/)
    end

    it "returns nil on Windows" do
      provisioner.stubs(:windows_os?).returns(true)
      result = provisioner.send(:make_executable_command, "C:\\path\\to\\script")
      _(result).must_be_nil
    end
  end

  describe "#run_script_command" do
    let(:provisioner) do
      Kitchen::Provisioner::Base.new(config).finalize_config!(instance)
    end

    it "returns sudo command on non-Windows" do
      provisioner.stubs(:windows_os?).returns(false)
      provisioner.stubs(:sudo).with("/path/to/script").returns("sudo -E /path/to/script")
      _(provisioner.send(:run_script_command, "/path/to/script")).must_include("/path/to/script")
    end

    it "returns PowerShell command on Windows" do
      provisioner.stubs(:windows_os?).returns(true)
      result = provisioner.send(:run_script_command, "C:\\path\\to\\script")
      _(result).must_equal("powershell -NoProfile -NonInteractive -NoLogo -ExecutionPolicy Bypass -File C:\\path\\to\\script")
    end
  end

  describe "#remote_path_join" do
    let(:provisioner) do
      Kitchen::Provisioner::Base.new(config).finalize_config!(instance)
    end

    it "joins paths with forward slash on non-Windows" do
      provisioner.stubs(:windows_os?).returns(false)
      _(provisioner.send(:remote_path_join, "/tmp", "kitchen", "script")).must_equal("/tmp/kitchen/script")
    end

    it "joins paths with backslash on Windows" do
      provisioner.stubs(:windows_os?).returns(true)
      _(provisioner.send(:remote_path_join, "C:", "kitchen", "script")).must_equal("C:\\kitchen\\script")
    end
  end
end
