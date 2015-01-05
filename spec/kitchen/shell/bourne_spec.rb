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
require "kitchen/shell/bourne"

describe Kitchen::Shell::Bourne do

  let(:config) { Hash.new }

  let(:shell) do
    Kitchen::Shell::Bourne.new(config)
  end

  describe "set_env" do

    let(:env) { shell.set_env("my_var", "this is my value") }

    it "sets the value given to the variable" do
      env.must_equal(
        <<-CMD.gsub(/^ {10}/, "")
          my_var="this is my value"
          export my_var
        CMD
      )
    end
  end

  describe "sudo" do
    let(:cmd) { shell.sudo("fix --all") }

    it "uses sudo when configured" do
      config[:sudo] = true

      cmd.must_equal "sudo -E fix --all"
    end

    it "does not use sudo when not configured" do
      config[:sudo] = false

      cmd.must_equal "fix --all"
    end
  end

  describe "wrap_command" do

    it "returns a false if command is nil" do
      shell.wrap_command(nil).must_equal("sh -c '\nfalse\n'")
    end

    it "uses bourne shell" do
      shell.wrap_command("yoyo").must_equal("sh -c '\nyoyo\n'")
    end

    it "returns a true if command string is empty" do
      shell.wrap_command("").must_equal("sh -c '\ntrue\n'")
    end

    it "handles a command string with a trailing newline" do
      shell.wrap_command("yep\n").must_equal("sh -c '\nyep\n'")
    end
  end
end
