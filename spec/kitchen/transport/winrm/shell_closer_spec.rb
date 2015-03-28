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
require "kitchen/transport/winrm/shell_closer"
require "winrm"

describe Kitchen::Transport::Winrm::ShellCloser do

  let(:klass) { Kitchen::Transport::Winrm::ShellCloser }

  let(:closer) do
    c = klass.new("info", false, %W[arg1 arg2])
    c.shell_id = "shell-123"
    c
  end

  let(:service) do
    s = mock
    s.stubs(:close_shell)
    s
  end

  it "#for creates a new instance for a shell_id with a copy of the data" do
    closer
    new_obj = mock
    new_obj.expects(:shell_id=).with("shell")
    klass.expects(:new).with("info", false, %W[arg1 arg2]).returns(new_obj)

    closer.for("shell")
  end

  it "#call creates a WinRM::WinRMWebService and closes the shell_id" do
    service.expects(:close_shell).with("shell-123")
    ::WinRM::WinRMWebService.expects(:new).with("arg1", "arg2").returns(service)

    closer.call
  end

  it "#call logs on debug, if set" do
    ::WinRM::WinRMWebService.stubs(:new).returns(service)
    closer = klass.new("info", true, %W[arg1 arg2])
    closer.shell_id = "shell-123"
    stdout = capture_stdout { closer.call }

    stdout.must_match Regexp.new(Regexp.escape(
      "D      [CommandExecutor] closing remote shell shell-123 on info"))
    stdout.must_match Regexp.new(Regexp.escape(
      "D      [CommandExecutor] remote shell shell-123 closed"))
  end

  it "#call prints out an exception if one is raised" do
    ::WinRM::WinRMWebService.stubs(:new).raises "oops"
    closer = klass.new("info", true, %W[arg1 arg2])
    closer.shell_id = "shell-123"
    stdout = capture_stdout { closer.call }

    stdout.must_match Regexp.new(Regexp.escape(
      "D      Exception: #<RuntimeError: oops>"))
  end

  def capture_stdout
    stdout_orig = $stdout
    $stdout = StringIO.new
    yield
    $stdout.string
  ensure
    $stdout = stdout_orig
  end
end
