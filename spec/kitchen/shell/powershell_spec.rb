# -*- encoding: utf-8 -*-
#
# Author:: Matt Wrock (<matt@mattwrock.com>)
#
# Copyright (C) 2014, Matt Wrock
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
require "kitchen/shell/base"
require "kitchen/shell/powershell"

describe Kitchen::Shell::Powershell do

  let(:config) { Hash.new }

  let(:shell) do
    Kitchen::Shell::Powershell.new(config)
  end

  describe "default_ruby_bin" do
    it "returns the chef omnibus bin" do
      shell.default_ruby_bin.must_equal("$env:systemdrive\\opscode\\chef\\embedded\\bin")
    end
  end

  describe "default_busser_bin" do
    it "returns the busser bin from the given rootwith a .bat extension" do
      shell.default_busser_bin("/b").must_equal("/b/gems/bin/busser.bat")
    end
  end

  describe "name" do
    it "returns the shell name" do
      shell.name.must_equal("Powershell")
    end
  end

  describe "busser_setup" do

    it "checks if busser is installed" do
      shell.busser_setup("", "", "").must_match regexify(
        %{if ((gem list busser -i) -eq \"false\")}, :partial_line)
    end

    it "installs the latest busser gem by default" do
      shell.busser_setup("", "", "busser --no-rdoc --no-ri").must_match regexify(
        %{gem install busser --no-rdoc --no-ri}, :partial_line)
    end

    it "copies the reby executable to the busser bin" do
      shell.busser_setup("/r", "/b", "").must_match regexify(
        %{Copy-Item /r/ruby.exe /b/gems/bin},
        :partial_line)
    end
  end

  describe "set_env" do

    let(:env) { shell.set_env("my_var", "this is my value") }

    it "sets the value given to the variable" do
      env.must_equal(
        <<-CMD.gsub(/^ {10}/, "")
          $env:my_var="this is my value"
        CMD
      )
    end
  end

  describe "sudo" do
    let(:cmd) { shell.sudo("invoke-fix -all") }

    it "passes thru when configured" do
      config[:sudo] = true

      cmd.must_equal "invoke-fix -all"
    end

    it "passes thru when not configured" do
      config[:sudo] = false

      cmd.must_equal "invoke-fix -all"
    end
  end

  describe "wrap_command" do

    it "returns a false if command is nil" do
      shell.wrap_command(nil).must_equal("false")
    end

    it "passes thru the command" do
      shell.wrap_command("yoyo").must_equal("yoyo")
    end

    it "returns a true if command string is empty" do
      shell.wrap_command("").must_equal("true")
    end
  end

  def regexify(str, line = :whole_line)
    r = Regexp.escape(str)
    r = "^\s*#{r}$" if line == :whole_line
    Regexp.new(r)
  end
end
