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

require_relative "../spec_helper"

require "kitchen/errors"
require "kitchen/shell_out"
require "kitchen/util"

module Kitchen
  class Shelly
    include Kitchen::ShellOut

    attr_reader :logs

    def debug(msg)
      @logs ||= []
      @logs << msg
    end

    def logger
      "alogger"
    end
  end
end

describe Kitchen::ShellOut do
  let(:command) do
    stub(
      run_command: true,
      error!: true,
      stdout: "",
      execution_time: 123
    )
  end

  let(:subject) { Kitchen::Shelly.new }

  describe "#run_command" do
    let(:opts) do
      { live_stream: "alogger", timeout: 60_000 }
    end

    before do
      Mixlib::ShellOut.stubs(:new).returns(command)
    end

    it "builds a Mixlib::ShellOut object with default options" do
      Mixlib::ShellOut.unstub(:new)
      Mixlib::ShellOut.expects(:new).with("yoyo", opts).returns(command)

      subject.run_command("yoyo")
    end

    [:timeout, :cwd, :environment].each do |attr|
      it "builds a Mixlib::ShellOut object with a custom #{attr}" do
        opts[attr] = "custom"

        Mixlib::ShellOut.unstub(:new)
        Mixlib::ShellOut.expects(:new).with("yoyo", opts).returns(command)

        subject.run_command("yoyo", attr => "custom")
      end
    end

    it "returns the command's standard out" do
      command.stubs(:stdout).returns("sweetness")

      subject.run_command("icecream").must_equal "sweetness"
    end

    it "raises a ShellCommandFailed if the command does not cleanly exit" do
      command.stubs(:error!)
             .raises(Mixlib::ShellOut::ShellCommandFailed, "boom bad")

      err = proc { subject.run_command("boom") }
            .must_raise Kitchen::ShellOut::ShellCommandFailed
      err.message.must_equal "boom bad"
    end

    it "raises a Kitchen::Errror tagged exception for unknown exceptions" do
      command.stubs(:error!).raises(IOError, "boom bad")

      err = proc { subject.run_command("boom") }.must_raise IOError
      err.must_be_kind_of Kitchen::Error
      err.message.must_equal "boom bad"
    end

    it "prepends with sudo if :use_sudo is truthy" do
      Mixlib::ShellOut.unstub(:new)
      Mixlib::ShellOut.expects(:new).with("sudo -E yo", opts).returns(command)

      subject.run_command("yo", use_sudo: true)
    end

    it "prepends with custom :sudo_command if :use_sudo is truthy" do
      Mixlib::ShellOut.unstub(:new)
      Mixlib::ShellOut.expects(:new).with("wat yo", opts).returns(command)

      subject.run_command("yo", use_sudo: true, sudo_command: "wat")
    end

    it "logs a debug BEGIN message" do
      subject.run_command("echo whoopa\ndoopa\ndo")

      subject.logs.first
             .must_equal "[local command] BEGIN (echo whoopa\ndoopa\ndo)"
    end

    it "logs a debug BEGIN message with custom log subject" do
      subject.run_command("tenac", log_subject: "thed")

      subject.logs.first.must_equal "[thed command] BEGIN (tenac)"
    end

    it "truncates the debug BEGIN command if it spans multiple lines" do
    end

    it "logs a debug END message" do
      subject.run_command("echo whoopa doopa")

      subject.logs.last.must_equal "[local command] END (2m3.00s)"
    end

    it "logs a debug END message with custom log subject" do
      subject.run_command("tenac", log_subject: "thed")

      subject.logs.last.must_equal "[thed command] END (2m3.00s)"
    end
  end
end
