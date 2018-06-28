# -*- encoding: utf-8 -*-
#
# Author:: Noah Kantrowitz <noah@coderanger.net>
#
# Copyright (C) 2018, Noah Kantrowitz
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
require "kitchen/lifecycle_hooks"

describe Kitchen::LifecycleHooks do
  let(:state_file) { mock("state_file").tap { |s| s.stubs(read: {})} }
  let(:connection) { mock("connection") }
  let(:transport) { mock("transport").tap { |t| t.stubs(:connection).with({}).returns(connection) } }
  let(:instance) { mock("instance").tap { |i| i.stubs(transport: transport) } }
  let(:config) { {} }
  let(:lifecycle_hooks) { Kitchen::LifecycleHooks.new(config).tap { |lh| lh.finalize_config!(instance) } }

  def run_lifecycle_hooks
    lifecycle_hooks.run_with_hooks(:create, state_file) { }
  end

  it "runs a single local command" do
    config.update(pre_create: ["echo foo"])
    lifecycle_hooks.expects(:run_command).with("echo foo", {})
    run_lifecycle_hooks
  end

  it "runs multiple local commands" do
    config.update(pre_create: ["echo foo", {local: "echo bar"}])
    lifecycle_hooks.expects(:run_command).with("echo foo", {})
    lifecycle_hooks.expects(:run_command).with("echo bar", {})
    run_lifecycle_hooks
  end

  it "runs multiple local hooks" do
    config.update(pre_create: ["echo foo"], post_create: ["echo bar"])
    lifecycle_hooks.expects(:run_command).with("echo foo", {})
    lifecycle_hooks.expects(:run_command).with("echo bar", {})
    run_lifecycle_hooks
  end

  it "runs a local command with options" do
    config.update(pre_create: [{local: "echo foo", user: "bar"}])
    lifecycle_hooks.expects(:run_command).with("echo foo", {user: "bar"})
    run_lifecycle_hooks
  end

  it "runs a single remote command" do
    config.update(pre_create: [{remote: "echo foo"}])
    lifecycle_hooks.expects(:run_command).never
    connection.expects(:execute).with("echo foo")
    run_lifecycle_hooks
  end

  it "rejects unknown hook targets" do
    config.update(pre_create: [{banana: "echo foo"}])
    lifecycle_hooks.expects(:run_command).never
    proc { run_lifecycle_hooks }.must_raise Kitchen::Errors::User
  end

  it "runs mixed local and remote commands" do
    config.update(pre_create: ["echo foo", {local: "echo bar"}, {remote: "echo baz"}])
    lifecycle_hooks.expects(:run_command).with("echo foo", {})
    lifecycle_hooks.expects(:run_command).with("echo bar", {})
    connection.expects(:execute).with("echo baz")
    run_lifecycle_hooks
  end
end
