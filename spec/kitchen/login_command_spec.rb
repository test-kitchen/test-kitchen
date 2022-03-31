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

require "kitchen/login_command"

describe Kitchen::LoginCommand do
  let(:cmd)   { "" }
  let(:argv)  { [] }
  let(:opts)  { {} }

  let(:login_command) { Kitchen::LoginCommand.new(cmd, argv, opts) }

  it "#command returns the command" do
    cmd << "one"

    _(login_command.command).must_equal "one"
  end

  it "#arguments defaults to an empty array" do
    _(Kitchen::LoginCommand.new("echo", nil).arguments).must_equal []
  end

  it "#arguments returns the command arguments" do
    argv.concat(["-o", "two"])

    _(login_command.arguments).must_equal ["-o", "two"]
  end

  it "#options defaults to an empty hash" do
    _(Kitchen::LoginCommand.new(cmd, argv).options).must_equal({})
  end

  it "#options returns the options hash from the constructor" do
    opts[:cake] = "yummy"

    _(login_command.options).must_equal(cake: "yummy")
  end

  it "#exec_args returns an array of arguments for Kernel.exec" do
    cmd << "alpha"

    _(login_command.exec_args).must_equal ["alpha", {}]

    argv.concat(["-o", "beta"])

    _(login_command.exec_args).must_equal ["alpha", "-o", "beta", {}]

    opts[:charlie] = "delta"

    _(login_command.exec_args).must_equal [
      "alpha", "-o", "beta", { charlie: "delta" }]
  end
end
