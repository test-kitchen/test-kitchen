# -*- encoding: utf-8 -*-
#
# Author:: Fletcher (<fnichol@nichol.ca>)
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

require_relative "../../../spec_helper"

require "kitchen"
require "kitchen/transport/winrm/command_executor"

require "securerandom"
require "winrm"

describe Kitchen::Transport::Winrm::CommandExecutor do

  let(:logged_output)   { StringIO.new }
  let(:logger)          { Logger.new(logged_output) }
  let(:shell_id)        { "shell-123" }

  let(:executor) do
    Kitchen::Transport::Winrm::CommandExecutor.new(service, logger)
  end

  let(:service) do
    s = mock("winrm_service")
    s.responds_like_instance_of(WinRM::WinRMWebService)
    s
  end

  let(:version_output) do
    o = WinRM::Output.new
    o[:exitcode] = 0
    o[:data].concat([{ :stdout => "6.3.9600.0\r\n" }])
    o
  end

  before do
    service.stubs(:open_shell).returns(shell_id)

    stub_powershell_script(shell_id,
      "[environment]::OSVersion.Version.tostring()", version_output)
  end

  describe "#close" do

    it "calls service#close_shell" do
      executor.open
      service.expects(:close_shell).with(shell_id)

      executor.close
    end

    it "only calls service#close_shell once for multiple calls" do
      executor.open
      service.expects(:close_shell).with(shell_id).once

      executor.close
      executor.close
      executor.close
    end
  end

  describe "#open" do

    it "calls service#open_shell" do
      service.expects(:open_shell).returns(shell_id)

      executor.open
    end

    it "returns a shell id as a string" do
      executor.open.must_equal shell_id
    end

    describe "for modern windows distributions" do

      let(:version_output) do
        o = WinRM::Output.new
        o[:exitcode] = 0
        o[:data].concat([{ :stdout => "6.3.9600.0\r\n" }])
        o
      end

      it "sets #max_commands to 1500 - 2" do
        executor.max_commands.must_equal nil
        executor.open

        executor.max_commands.must_equal(1500 - 2)
      end
    end

    describe "for older/legacy windows distributions" do

      let(:version_output) do
        o = WinRM::Output.new
        o[:exitcode] = 0
        o[:data].concat([{ :stdout => "6.1.8500.0\r\n" }])
        o
      end

      it "sets #max_commands to 15 - 2" do
        executor.max_commands.must_equal nil
        executor.open

        executor.max_commands.must_equal(15 - 2)
      end
    end
  end

  describe "#run_cmd" do

    describe "when #open has not been previously called" do

      it "raises a WinRMError error" do
        err = proc { executor.run_cmd("nope") }.must_raise WinRM::WinRMError
        err.message.must_equal "#{executor.class}#open must be called " \
          "before any run methods are invoked"
      end
    end

    describe "when #open has been previously called" do

      let(:command_id) { "command-123" }

      let(:echo_output) do
        o = WinRM::Output.new
        o[:exitcode] = 0
        o[:data].concat([
          { :stdout => "Hello\r\n" },
          { :stderr => "Psst\r\n" }
        ])
        o
      end

      before do
        stub_cmd(shell_id, "echo", ["Hello"], echo_output, command_id)

        executor.open
      end

      it "calls service#run_command" do
        service.expects(:run_command).with(shell_id, "echo", ["Hello"])

        executor.run_cmd("echo", ["Hello"])
      end

      it "calls service#get_command_output to get results" do
        service.expects(:get_command_output).with(shell_id, command_id)

        executor.run_cmd("echo", ["Hello"])
      end

      it "calls service#get_command_output with a block to get results" do
        blk = proc { |_, _| "something" }
        service.expects(:get_command_output).with(shell_id, command_id, &blk)

        executor.run_cmd("echo", ["Hello"], &blk)
      end

      it "returns an Output object hash" do
        executor.run_cmd("echo", ["Hello"]).must_equal echo_output
      end

      it "runs the block  in #get_command_output when given" do
        io_out = StringIO.new
        io_err = StringIO.new

        output = executor.run_cmd("echo", ["Hello"]) do |stdout, stderr|
          io_out << stdout if stdout
          io_err << stderr if stderr
        end

        io_out.string.must_equal "Hello\r\n"
        io_err.string.must_equal "Psst\r\n"
        output.must_equal echo_output
      end
    end

    describe "when called many times over time" do

      # use a "old" version of windows with lower max_commands threshold
      # to trigger quicker shell recyles
      let(:version_output) do
        o = WinRM::Output.new
        o[:exitcode] = 0
        o[:data].concat([{ :stdout => "6.1.8500.0\r\n" }])
        o
      end

      let(:echo_output) do
        o = WinRM::Output.new
        o[:exitcode] = 0
        o[:data].concat([{ :stdout => "Hello\r\n" }])
        o
      end

      before do
        service.stubs(:open_shell).returns("s1", "s2")
        service.stubs(:close_shell)
        service.stubs(:run_command).yields("command-xxx")
        service.stubs(:get_command_output).returns(echo_output)
        stub_powershell_script("s1",
          "[environment]::OSVersion.Version.tostring()", version_output)
      end

      it "resets the shell when #max_commands threshold is tripped" do
        iterations = 35
        reset_times = iterations / (15 - 2)

        service.expects(:close_shell).times(reset_times)
        executor.open
        iterations.times { executor.run_cmd("echo", ["Hello"]) }

        logged_output.string.lines.select { |l|
          l =~ debug_line_with("[#{executor.class}] Resetting WinRM shell")
        }.size.must_equal reset_times
      end
    end
  end

  describe "#run_powershell_script" do

    describe "when #open has not been previously called" do

      it "raises a WinRMError error" do
        err = proc {
          executor.run_powershell_script("nope")
        }.must_raise WinRM::WinRMError
        err.message.must_equal "#{executor.class}#open must be called " \
          "before any run methods are invoked"
      end
    end

    describe "when #open has been previously called" do

      let(:command_id) { "command-123" }

      let(:echo_output) do
        o = WinRM::Output.new
        o[:exitcode] = 0
        o[:data].concat([
          { :stdout => "Hello\r\n" },
          { :stderr => "Psst\r\n" }
        ])
        o
      end

      before do
        stub_powershell_script(shell_id, "echo Hello", echo_output, command_id)

        executor.open
      end

      it "calls service#run_command" do
        service.expects(:run_command).with(
          shell_id,
          "powershell",
          ["-encodedCommand", WinRM::PowershellScript.new("echo Hello").encoded]
        )

        executor.run_powershell_script("echo Hello")
      end

      it "calls service#get_command_output to get results" do
        service.expects(:get_command_output).with(shell_id, command_id)

        executor.run_powershell_script("echo Hello")
      end

      it "calls service#get_command_output with a block to get results" do
        blk = proc { |_, _| "something" }
        service.expects(:get_command_output).with(shell_id, command_id, &blk)

        executor.run_powershell_script("echo Hello", &blk)
      end

      it "returns an Output object hash" do
        executor.run_powershell_script("echo Hello").must_equal echo_output
      end

      it "runs the block  in #get_command_output when given" do
        io_out = StringIO.new
        io_err = StringIO.new

        output = executor.run_powershell_script("echo Hello") do |stdout, stderr|
          io_out << stdout if stdout
          io_err << stderr if stderr
        end

        io_out.string.must_equal "Hello\r\n"
        io_err.string.must_equal "Psst\r\n"
        output.must_equal echo_output
      end
    end

    describe "when called many times over time" do

      # use a "old" version of windows with lower max_commands threshold
      # to trigger quicker shell recyles
      let(:version_output) do
        o = WinRM::Output.new
        o[:exitcode] = 0
        o[:data].concat([{ :stdout => "6.1.8500.0\r\n" }])
        o
      end

      let(:echo_output) do
        o = WinRM::Output.new
        o[:exitcode] = 0
        o[:data].concat([{ :stdout => "Hello\r\n" }])
        o
      end

      before do
        service.stubs(:open_shell).returns("s1", "s2")
        service.stubs(:close_shell)
        service.stubs(:run_command).yields("command-xxx")
        service.stubs(:get_command_output).returns(echo_output)
        stub_powershell_script("s1",
          "[environment]::OSVersion.Version.tostring()", version_output)
      end

      it "resets the shell when #max_commands threshold is tripped" do
        iterations = 35
        reset_times = iterations / (15 - 2)

        service.expects(:close_shell).times(reset_times)
        executor.open
        iterations.times { executor.run_powershell_script("echo Hello") }

        logged_output.string.lines.select { |l|
          l =~ debug_line_with("[#{executor.class}] Resetting WinRM shell")
        }.size.must_equal reset_times
      end
    end
  end

  def debug_line_with(msg)
    %r{^D, .* : #{Regexp.escape(msg)}}
  end

  # rubocop:disable Metrics/ParameterLists
  def stub_cmd(shell_id, cmd, args, output, command_id = nil, &block)
    command_id ||= SecureRandom.uuid

    service.stubs(:run_command).with(shell_id, cmd, args).yields(command_id)
    service.stubs(:get_command_output).with(shell_id, command_id, &block).
      yields(output.stdout, output.stderr).returns(output)
  end

  def stub_powershell_script(shell_id, script, output, command_id = nil)
    stub_cmd(
      shell_id,
      "powershell",
      ["-encodedCommand", WinRM::PowershellScript.new(script).encoded],
      output,
      command_id
    )
  end
  # rubocop:enable Metrics/ParameterLists
end
