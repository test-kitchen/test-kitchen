#
# Copyright:: (C) 2026
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

require_relative "../../spec_helper"

require "json"
require "logger"
require "rbconfig"
require "shellwords"
require "stringio"
require "tempfile"

require "kitchen/provisioner"
require "kitchen/provisioner/external"

describe Kitchen::Provisioner::External do
  let(:logged_output) { StringIO.new }
  let(:logger)        { Logger.new(logged_output) }
  let(:platform)      { stub(name: "ubuntu", os_type: "unix", shell_type: "bourne") }
  let(:suite)         { stub(name: "default") }
  let(:driver)        { stub(name: "exec") }
  let(:transport_name) { "exec" }
  let(:transport)     { stub(name: transport_name) }
  let(:verifier)      { stub(name: "inspec") }
  let(:state)         { {} }

  let(:instance) do
    stub(
      name: "default-ubuntu",
      to_str: "default-ubuntu",
      logger: logger,
      suite: suite,
      platform: platform,
      driver: driver,
      transport: transport,
      verifier: verifier
    )
  end

  let(:fixture_path) do
    File.expand_path("../../fixtures/external_provider/fake_provider.rb", __dir__)
  end

  let(:request_log) { Tempfile.new("fake-provider-requests") }

  let(:config) do
    {
      command: "#{RbConfig.ruby} #{Shellwords.escape(fixture_path)} success",
      provider: "fake",
      kitchen_root: "/rooty",
      test_base_path: "/basist",
      pass_env: ["FAKE_EXTERNAL_PROVIDER_REQUEST_LOG"],
    }
  end

  let(:provisioner) do
    Kitchen::Provisioner::External.new(config).finalize_config!(instance)
  end

  before do
    ENV["FAKE_EXTERNAL_PROVIDER_REQUEST_LOG"] = request_log.path
  end

  after do
    ENV.delete("FAKE_EXTERNAL_PROVIDER_REQUEST_LOG")
    request_log.close!
  end

  it "provisioner api_version is 2" do
    _(provisioner.diagnose_plugin[:api_version]).must_equal 2
  end

  it "plugin_version is set to Kitchen::VERSION" do
    _(provisioner.diagnose_plugin[:version]).must_equal Kitchen::VERSION
  end

  it "can be loaded as the external provisioner plugin" do
    Kitchen::Plugin.stubs(:require).returns(true)

    loaded = Kitchen::Provisioner.for_plugin("external", command: "kitchen-provider-fake")

    _(loaded).must_be_kind_of Kitchen::Provisioner::External
  end

  it "runs the provider, logs events, and persists provider state" do
    provisioner.call(state)

    _(logged_output.string).must_include "installing fake provider"
    _(logged_output.string).must_include "halfway through fake run"
    _(state[:providers]["fake"]).must_equal("instance_id" => "abc-123")
  end

  it "sends validate and run request envelopes to the provider" do
    provisioner.call(state)

    requests = request_log.tap(&:rewind).read.lines.map { |line| JSON.parse(line) }
    operations = requests.map { |request| request["operation"] }

    _(operations).must_equal [nil, "validate", "run"]
    _(requests.fetch(1)["protocol_version"]).must_equal "1.0"
    _(requests.fetch(1)["components"]["transport"]["type"]).must_equal "exec"
    _(requests.fetch(2)["state"]["provider"]).must_equal({})
  end

  it "describes existing ssh transport without copying secrets into JSON" do
    config[:command] = "#{RbConfig.ruby} #{Shellwords.escape(fixture_path)} all_transports"
    state[:hostname] = "192.0.2.10"
    state[:username] = "ubuntu"
    state[:port] = 2222
    state[:password] = "ssh-password"
    transport.stubs(:name).returns("ssh")

    provisioner.call(state)

    requests = request_log.tap(&:rewind).read.lines.map { |line| JSON.parse(line) }
    transport_request = requests.fetch(1).fetch("components").fetch("transport")

    _(transport_request["type"]).must_equal "ssh"
    _(transport_request["target"]).must_equal(
      "kind" => "machine",
      "hostname" => "192.0.2.10",
      "platform" => "ubuntu"
    )
    _(transport_request["config"]["username"]).must_equal "ubuntu"
    _(transport_request["config"]["port"]).must_equal 2222
    _(request_log.tap(&:rewind).read).wont_include "ssh-password"
  end

  it "raises ActionFailed when provider validation fails" do
    config[:command] = "#{RbConfig.ruby} #{Shellwords.escape(fixture_path)} validation_error"

    error = _ { provisioner.call(state) }.must_raise Kitchen::ActionFailed

    _(error.message).must_include "suite is not valid for fake provider"
  end

  it "raises ActionFailed for provider-reported converge failure" do
    config[:command] = "#{RbConfig.ruby} #{Shellwords.escape(fixture_path)} converge_failure"

    error = _ { provisioner.call(state) }.must_raise Kitchen::ActionFailed

    _(error.message).must_include "fake converge failed"
  end

  it "raises ActionFailed for unsupported protocol versions" do
    config[:command] = "#{RbConfig.ruby} #{Shellwords.escape(fixture_path)} unsupported_protocol"

    error = _ { provisioner.call(state) }.must_raise Kitchen::ActionFailed

    _(error.message).must_include "Unsupported external provider protocol version"
  end

  it "raises ActionFailed when run output is malformed" do
    config[:command] = "#{RbConfig.ruby} #{Shellwords.escape(fixture_path)} malformed_json"

    error = _ { provisioner.call(state) }.must_raise Kitchen::ActionFailed

    _(error.message).must_include "malformed external provider event"
  end

  it "raises ActionFailed when run output has no final result" do
    config[:command] = "#{RbConfig.ruby} #{Shellwords.escape(fixture_path)} missing_result"

    error = _ { provisioner.call(state) }.must_raise Kitchen::ActionFailed

    _(error.message).must_include "did not emit a final result"
  end

  it "raises ActionFailed when the provider process exits non-zero" do
    config[:command] = "#{RbConfig.ruby} #{Shellwords.escape(fixture_path)} non_zero"

    error = _ { provisioner.call(state) }.must_raise Kitchen::ActionFailed

    _(error.message).must_include "provider process exploded"
  end

  it "redacts allowlisted environment values from logs and errors" do
    config[:command] = "#{RbConfig.ruby} #{Shellwords.escape(fixture_path)} secret_echo"
    config[:pass_env] = ["TK_FAKE_SECRET"]
    ENV["TK_FAKE_SECRET"] = "super-secret-value"

    error = _ { provisioner.call(state) }.must_raise Kitchen::ActionFailed

    _(logged_output.string).wont_include "super-secret-value"
    _(error.message).wont_include "super-secret-value"
    _(logged_output.string).must_include "******"
    _(error.message).must_include "******"
  ensure
    ENV.delete("TK_FAKE_SECRET")
  end

  it "does not include allowlisted environment values in JSON requests" do
    config[:pass_env] = ["TK_FAKE_SECRET"]
    ENV["TK_FAKE_SECRET"] = "super-secret-value"

    provisioner.call(state)

    request_log.rewind
    _(request_log.read).wont_include "super-secret-value"
  ensure
    ENV.delete("TK_FAKE_SECRET")
  end
end
