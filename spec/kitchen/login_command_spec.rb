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

require "kitchen/login_command"

describe Kitchen::LoginCommand do

  let(:argv) { Array.new }
  let(:opts) { Hash.new }

  let(:cmd) { Kitchen::LoginCommand.new(argv, opts) }

  it "#cmd_array defaults to an empty array" do
    Kitchen::LoginCommand.new(nil, opts).cmd_array.must_equal []
  end

  it "#cmd_array returns the command array from the constructor" do
    argv.concat(["one", "-o", "two"])

    cmd.cmd_array.must_equal ["one", "-o", "two"]
  end

  it "#options defaults to an empty hash" do
    Kitchen::LoginCommand.new(argv, nil).options.must_equal {}
  end

  it "#options returns the options hash from the constructor" do
    opts[:cake] = "yummy"

    cmd.options.must_equal(:cake => "yummy")
  end
end
