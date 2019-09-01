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
  let(:suite) { mock("suite").tap { |i| i.stubs(name: "default") } }
  let(:platform) { mock("platform").tap { |i| i.stubs(name: "toaster-1.0") } }
  let(:state_file) { mock("state_file").tap { |s| s.stubs(read: { hostname: "localhost" }) } }
  let(:connection) { mock("connection") }
  let(:transport) { mock("transport").tap { |t| t.stubs(:connection).with({ hostname: "localhost" }).returns(connection) } }
  let(:last_action) { :create }
  let(:instance) { mock("instance").tap { |i| i.stubs(name: "default-toaster-10", transport: transport, last_action: last_action, suite: suite, platform: platform) } }
  let(:config) { { kitchen_root: "/kitchen" } }
  let(:lifecycle_hooks) { Kitchen::LifecycleHooks.new(config).tap { |lh| lh.finalize_config!(instance) } }

  def run_lifecycle_hooks
    lifecycle_hooks.run_with_hooks(:create, state_file) {}
  end

  # Pull this out because it's used in a bunch of tests.
  STANDARD_LOCAL_OPTIONS = {
    cwd: "/kitchen",
    environment: {
      "KITCHEN_INSTANCE_NAME" => "default-toaster-10",
      "KITCHEN_SUITE_NAME" => "default",
      "KITCHEN_PLATFORM_NAME" => "toaster-1.0",
      "KITCHEN_INSTANCE_HOSTNAME" => "localhost",
    },
  }.freeze

  it "runs a single local command" do
    config.update(post_create: ["echo foo"])
    lifecycle_hooks.expects(:run_command).with("echo foo", STANDARD_LOCAL_OPTIONS)
    run_lifecycle_hooks
  end

  it "runs multiple local commands" do
    config.update(post_create: ["echo foo", { local: "echo bar" }])
    lifecycle_hooks.expects(:run_command).with("echo foo", STANDARD_LOCAL_OPTIONS)
    lifecycle_hooks.expects(:run_command).with("echo bar", STANDARD_LOCAL_OPTIONS)
    run_lifecycle_hooks
  end

  it "runs multiple local hooks" do
    config.update(pre_create: ["echo foo"], post_create: ["echo bar"])
    lifecycle_hooks.expects(:run_command).with("echo foo", STANDARD_LOCAL_OPTIONS)
    lifecycle_hooks.expects(:run_command).with("echo bar", STANDARD_LOCAL_OPTIONS)
    run_lifecycle_hooks
  end

  it "runs a local command with a user option" do
    config.update(post_create: [{ local: "echo foo", user: "bar" }])
    lifecycle_hooks.expects(:run_command).with("echo foo", {
      cwd: "/kitchen",
      user: "bar",
      environment: {
        "KITCHEN_INSTANCE_NAME" => "default-toaster-10",
        "KITCHEN_SUITE_NAME" => "default",
        "KITCHEN_PLATFORM_NAME" => "toaster-1.0",
        "KITCHEN_INSTANCE_HOSTNAME" => "localhost",
      },
    })
    run_lifecycle_hooks
  end

  it "runs a local command with environment options" do
    config.update(post_create: [{ local: "echo foo", environment: { FOO: "one", BAR: "two" } }])
    lifecycle_hooks.expects(:run_command).with("echo foo", {
      cwd: "/kitchen",
      environment: {
        "FOO" => "one",
        "BAR" => "two",
        "KITCHEN_INSTANCE_NAME" => "default-toaster-10",
        "KITCHEN_SUITE_NAME" => "default",
        "KITCHEN_PLATFORM_NAME" => "toaster-1.0",
        "KITCHEN_INSTANCE_HOSTNAME" => "localhost",
      },
    })
    run_lifecycle_hooks
  end

  it "runs a local command with a relative cwd option" do
    config.update(post_create: [{ local: "echo foo", cwd: "test" }])
    lifecycle_hooks.expects(:run_command).with("echo foo", {
      cwd: os_safe_root_path("/kitchen/test"),
      environment: {
        "KITCHEN_INSTANCE_NAME" => "default-toaster-10",
        "KITCHEN_SUITE_NAME" => "default",
        "KITCHEN_PLATFORM_NAME" => "toaster-1.0",
        "KITCHEN_INSTANCE_HOSTNAME" => "localhost",
      },
    })
    run_lifecycle_hooks
  end

  it "runs a local command with an absolute cwd option" do
    config.update(post_create: [{ local: "echo foo", cwd: "/test" }])
    lifecycle_hooks.expects(:run_command).with("echo foo", {
      cwd: os_safe_root_path("/test"),
      environment: {
        "KITCHEN_INSTANCE_NAME" => "default-toaster-10",
        "KITCHEN_SUITE_NAME" => "default",
        "KITCHEN_PLATFORM_NAME" => "toaster-1.0",
        "KITCHEN_INSTANCE_HOSTNAME" => "localhost",
      },
    })
    run_lifecycle_hooks
  end

  it "runs a single remote command" do
    config.update(post_create: [{ remote: "echo foo" }])
    lifecycle_hooks.expects(:run_command).never
    connection.expects(:execute).with("echo foo")
    run_lifecycle_hooks
  end

  it "runs a multiple remote command" do
    config.update(post_create: [{ remote: "echo foo" }, { remote: "echo bar" }])
    lifecycle_hooks.expects(:run_command).never
    connection.expects(:execute).with("echo foo")
    connection.expects(:execute).with("echo bar")
    run_lifecycle_hooks
  end

  it "rejects unknown hook targets" do
    config.update(post_create: [{ banana: "echo foo" }])
    lifecycle_hooks.expects(:run_command).never
    proc { run_lifecycle_hooks }.must_raise Kitchen::UserError
  end

  it "runs mixed local and remote commands" do
    config.update(post_create: ["echo foo", { local: "echo bar" }, { remote: "echo baz" }])
    lifecycle_hooks.expects(:run_command).with("echo foo", STANDARD_LOCAL_OPTIONS)
    lifecycle_hooks.expects(:run_command).with("echo bar", STANDARD_LOCAL_OPTIONS)
    connection.expects(:execute).with("echo baz")
    run_lifecycle_hooks
  end

  describe "with no last_action" do
    let(:last_action) { nil }

    it "runs local commands" do
      config.update(post_create: [{ local: "echo foo" }])
      lifecycle_hooks.expects(:run_command).with("echo foo", STANDARD_LOCAL_OPTIONS)
      run_lifecycle_hooks
    end

    it "fails on remote commands" do
      config.update(post_create: [{ remote: "echo foo" }])
      lifecycle_hooks.expects(:run_command).never
      proc { run_lifecycle_hooks }.must_raise Kitchen::UserError
    end

    it "ignores skippable remote commands" do
      config.update(post_create: [{ remote: "echo foo", skippable: true }])
      lifecycle_hooks.expects(:run_command).never
      run_lifecycle_hooks
    end
  end
end
