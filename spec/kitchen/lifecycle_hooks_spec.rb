#
# Author:: Noah Kantrowitz <noah@coderanger.net>
#
# Copyright (C) 2018, Noah Kantrowitz
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

require_relative "../spec_helper"

require "kitchen/errors"
require "kitchen/lifecycle_hooks"

describe Kitchen::LifecycleHooks do
  let(:suite) { mock("suite").tap { |i| i.stubs(name: "default") } }
  let(:platform_name) { "toaster-1.0" }
  let(:platform) { mock("platform").tap { |i| i.stubs(name: platform_name) } }
  let(:state_file) { mock("state_file").tap { |s| s.stubs(read: { hostname: "localhost" }) } }
  let(:connection) { mock("connection") }
  let(:transport) { mock("transport").tap { |t| t.stubs(:connection).with({ hostname: "localhost" }).returns(connection) } }
  let(:last_action) { :create }
  let(:instance) { mock("instance").tap { |i| i.stubs(name: "default-toaster-10", transport: transport, last_action: last_action, suite: suite, platform: platform, state_file: state_file) } }
  let(:kitchen_root) do
    if RUBY_PLATFORM.match?(/mswin|mingw|windows/)
      "#{ENV["SYSTEMDRIVE"]}/kitchen"
    else
      "/kitchen"
    end
  end
  let(:config) { { kitchen_root: kitchen_root } }
  let(:lifecycle_hooks) { Kitchen::LifecycleHooks.new(config, state_file).tap { |lh| lh.finalize_config!(instance) } }
  let(:standard_local_options) do
    {
      cwd: kitchen_root,
      environment: {
        "KITCHEN_INSTANCE_NAME" => "default-toaster-10",
        "KITCHEN_SUITE_NAME" => "default",
        "KITCHEN_PLATFORM_NAME" => "toaster-1.0",
        "KITCHEN_INSTANCE_HOSTNAME" => "localhost",
      },
    }
  end

  def run_lifecycle_hooks
    lifecycle_hooks.run_with_hooks(:create, state_file) {}
  end

  def expect_local_hook_generated_and_not_run(phase, hook, non_standard_local_opts: {})
    local_hook = Kitchen::LifecycleHook::Local.new(lifecycle_hooks, phase, hook)
    lifecycle_hooks.expects(:generate_hook).with(:create, hook).returns(local_hook)
    local_hook.expects(:run_command).never
    local_hook
  end

  def expect_remote_hook_generated_and_not_run(phase, hook)
    remote_hook = Kitchen::LifecycleHook::Remote.new(lifecycle_hooks, phase, hook)
    lifecycle_hooks.expects(:generate_hook).with(:create, hook).returns(remote_hook)
    remote_hook.expects(:run_command).never
    connection.expects(:execute).never
    remote_hook
  end

  def expect_local_hook_generated_and_run(phase, hook, non_standard_local_opts: {})
    local_hook = Kitchen::LifecycleHook::Local.new(lifecycle_hooks, phase, hook)
    lifecycle_hooks.expects(:generate_hook).with(:create, hook).returns(local_hook)
    expected_options = standard_local_options.merge(non_standard_local_opts)
    local_hook.expects(:run_command).with(hook[:local], expected_options)
    local_hook
  end

  def expect_remote_hook_generated_and_run(phase, hook)
    remote_hook = Kitchen::LifecycleHook::Remote.new(lifecycle_hooks, phase, hook)
    lifecycle_hooks.expects(:generate_hook).with(:create, hook).returns(remote_hook)
    remote_hook.expects(:run_command).never
    connection.expects(:execute).with(hook[:remote])
    remote_hook
  end

  it "runs a single local command" do
    local_command = "echo foo"
    config.update(post_create: [local_command])
    expect_local_hook_generated_and_run(:post, { local: local_command })
    run_lifecycle_hooks
  end

  it "runs multiple local commands" do
    local_command = "echo foo"
    local_hook = { local: "echo bar" }
    config.update(post_create: [local_command, local_hook])
    expect_local_hook_generated_and_run(:post, { local: local_command })
    expect_local_hook_generated_and_run(:post, local_hook)
    run_lifecycle_hooks
  end

  it "runs multiple local hooks" do
    config.update(pre_create: ["echo foo"], post_create: ["echo bar"])
    expect_local_hook_generated_and_run(:create, { local: "echo foo" })
    expect_local_hook_generated_and_run(:create, { local: "echo bar" })
    run_lifecycle_hooks
  end

  it "runs finally even if stage fails" do
    local_command = "echo foo"
    config.update(finally_create: [local_command])
    hook = expect_local_hook_generated_and_run(:finally, { local: local_command }) # rubocop: disable Lint/UselessAssignment
    begin
      lifecycle_hooks.run_with_hooks(:create, state_file) {
        raise Error
      }
    rescue
    end
  end

  it "runs a local command with a user option" do
    hook = { local: "echo foo", user: "bar" }
    config.update(post_create: [hook])
    expect_local_hook_generated_and_run(:create, hook, non_standard_local_opts: { user: "bar" })
    run_lifecycle_hooks
  end

  it "runs a local command with environment options" do
    hook = { local: "echo foo", environment: { FOO: "one", BAR: "two" } }
    config.update(post_create: [hook])
    command_opts = standard_local_options.dup
    command_opts[:environment]["FOO"] = "one"
    command_opts[:environment]["BAR"] = "two"
    expect_local_hook_generated_and_run(:create, hook, non_standard_local_opts: command_opts)
    run_lifecycle_hooks
  end

  it "runs a local command with a relative cwd option" do
    hook = { local: "echo foo", cwd: "test" }
    config.update(post_create: [hook])
    expect_local_hook_generated_and_run(:create, hook, non_standard_local_opts: { cwd: "#{kitchen_root}/test" })
    run_lifecycle_hooks
  end

  it "runs a local command with an absolute cwd option" do
    cwd = if RUBY_PLATFORM.match?(/mswin|mingw|windows/)
            "#{ENV["SYSTEMDRIVE"]}/test"
          else
            "/test"
          end
    hook = { local: "echo foo", cwd: cwd }
    config.update(post_create: [hook])
    expect_local_hook_generated_and_run(:create, hook, non_standard_local_opts: { cwd: cwd })
    run_lifecycle_hooks
  end

  it "runs a single remote command" do
    hook = { remote: "echo foo" }
    config.update(post_create: [hook])
    expect_remote_hook_generated_and_run(:create, hook)
    run_lifecycle_hooks
  end

  it "runs a multiple remote command" do
    hook1 = { remote: "echo foo" }
    hook2 = { remote: "echo bar" }
    config.update(post_create: [hook1, hook2])
    expect_remote_hook_generated_and_run(:create, hook1)
    expect_remote_hook_generated_and_run(:create, hook2)
    run_lifecycle_hooks
  end

  it "rejects unknown hook targets" do
    config.update(post_create: [{ banana: "echo foo" }])
    _ { run_lifecycle_hooks }.must_raise Kitchen::UserError
  end

  it "runs mixed local and remote commands" do
    local_command = "echo foo"
    local_hook = { local: "echo bar" }
    remote_hook = { remote: "echo baz" }
    config.update(post_create: [local_command, local_hook, remote_hook])
    expect_local_hook_generated_and_run(:create, { local: local_command })
    expect_local_hook_generated_and_run(:create, local_hook)
    expect_remote_hook_generated_and_run(:create, remote_hook)
    run_lifecycle_hooks
  end

  it "runs hooks that have been included by platform" do
    local_hook = { local: "echo bar", includes: platform_name }
    remote_hook = { remote: "echo baz", includes: platform_name }
    config.update(post_create: [local_hook, remote_hook])

    expect_local_hook_generated_and_run(:create, local_hook)
    expect_remote_hook_generated_and_run(:create, remote_hook)

    run_lifecycle_hooks
  end

  it "does not run hooks that have been excluded by platform" do
    local_hook = { local: "echo bar", excludes: platform_name }
    remote_hook = { remote: "echo baz", excludes: platform_name }
    config.update(post_create: [local_hook, remote_hook])

    expect_local_hook_generated_and_not_run(:create, local_hook)
    expect_remote_hook_generated_and_not_run(:create, remote_hook)

    run_lifecycle_hooks
  end

  it "does not run hooks that have NOT been included by platform" do
    local_hook = { local: "echo bar", includes: "other" }
    remote_hook = { remote: "echo baz", includes: "other" }
    config.update(post_create: [local_hook, remote_hook])

    expect_local_hook_generated_and_not_run(:create, local_hook)
    expect_remote_hook_generated_and_not_run(:create, remote_hook)

    run_lifecycle_hooks
  end

  describe "with no last_action" do
    let(:last_action) { nil }

    it "runs local commands" do
      hook = { local: "echo foo" }
      config.update(post_create: [hook])
      expect_local_hook_generated_and_run(:create, hook)
      run_lifecycle_hooks
    end

    it "fails on remote commands" do
      hook = { remote: "echo foo" }
      config.update(post_create: [hook])
      remote_lifecycle_hook = Kitchen::LifecycleHook::Remote.new(lifecycle_hooks, :create, hook)
      remote_lifecycle_hook.expects(:run_command).never
      _ { run_lifecycle_hooks }.must_raise Kitchen::UserError
    end

    it "ignores skippable remote commands" do
      hook = { remote: "echo foo", skippable: true }
      config.update(post_create: [hook])
      remote_lifecycle_hook = Kitchen::LifecycleHook::Remote.new(lifecycle_hooks, :create, hook)
      remote_lifecycle_hook.expects(:run_command).never
      run_lifecycle_hooks
    end
  end
end
