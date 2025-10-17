#
# Author:: Matt Wrock (<matt@mattwrock.com>)
#
# Copyright (C) 2014, Matt Wrock
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

require "kitchen/transport/winrm"
require "winrm"
require "winrm-fs"
require "winrm-elevated"

module Kitchen
  module Transport
    class WinRMConnectionDummy < Kitchen::Transport::Winrm::Connection
      attr_reader :saved_command, :remote_path, :local_path

      def upload(locals, remote)
        @saved_command = File.read(locals)
        @local_path = locals
        @remote_path = remote
      end
    end
  end
end

describe Kitchen::Transport::Winrm do
  before do
    RbConfig::CONFIG.stubs(:[]).with("host_os").returns("blah")
  end

  let(:logged_output) { StringIO.new }
  let(:logger)        { Logger.new(logged_output) }
  let(:config)        { {} }
  let(:state)         { {} }
  let(:options)       { { logger: logger } }

  let(:connection) do
    Kitchen::Transport::Winrm::Connection.new(options)
  end

  let(:instance) do
    stub(name: "coolbeans", logger: logger, to_str: "instance")
  end

  let(:transport) do
    t = Kitchen::Transport::Winrm.new(config)
    # :load_winrm_s! is not cross-platform safe
    # and gets initialized too early in the pipeline
    t.stubs(:load_winrm_s!)
    t.finalize_config!(instance)
  end

  it "provisioner api_version is 1" do
    _(transport.diagnose_plugin[:api_version]).must_equal 1
  end

  it "plugin_version is set to Kitchen::VERSION" do
    _(transport.diagnose_plugin[:version]).must_equal Kitchen::VERSION
  end

  describe "default_config" do
    it "sets :scheme to http by default" do
      _(transport[:scheme]).must_equal "http"
    end

    it "sets :port to 5985 by default" do
      _(transport[:port]).must_equal 5985
    end

    it "sets :username to administrator by default" do
      _(transport[:username]).must_equal "administrator"
    end

    it "sets :password to nil by default" do
      _(transport[:password]).must_be_nil
    end

    it "sets :rdp_port to 3389 by default" do
      _(transport[:rdp_port]).must_equal 3389
    end

    it "sets :connection_retries to 5 by default" do
      _(transport[:connection_retries]).must_equal 5
    end

    it "sets :connection_retry_sleep to 1 by default" do
      _(transport[:connection_retry_sleep]).must_equal 1
    end

    it "sets :max_wait_until_ready to 600 by default" do
      _(transport[:max_wait_until_ready]).must_equal 600
    end

    it "sets :winrm_transport to :negotiate" do
      _(transport[:winrm_transport]).must_equal :negotiate
    end

    it "sets :elevated to false" do
      _(transport[:elevated]).must_equal false
    end
  end

  describe "#connection" do
    let(:klass) { Kitchen::Transport::Winrm::Connection }

    # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    def self.common_connection_specs
      before do
        config[:hostname] = "here"
        config[:kitchen_root] = "/i/am/root"
        config[:password] = "password"
      end

      it "returns a Kitchen::Transport::Winrm::Connection object" do
        _(transport.connection(state)).must_be_kind_of klass
      end

      it "sets :instance_name to the instance's name" do
        klass.expects(:new).with do |hash|
          hash[:instance_name] == "coolbeans"
        end

        make_connection
      end
      it "sets :kitchen_root to the transport's kitchen_root" do
        klass.expects(:new).with do |hash|
          hash[:kitchen_root] == "/i/am/root"
        end

        make_connection
      end

      it "sets the :logger to the transport's logger" do
        klass.expects(:new).with do |hash|
          hash[:logger] == logger
        end

        make_connection
      end

      it "sets the :winrm_transport to :negotiate" do
        klass.expects(:new).with do |hash|
          hash[:transport] == :negotiate
        end

        make_connection
      end

      it "sets the :disable_sspi to false" do
        klass.expects(:new).with do |hash|
          hash[:disable_sspi] == false
        end

        make_connection
      end

      it "sets :endpoint when hostname is an IPv6 address" do
        config[:hostname] = "caec:cec6:c4ef:bb7b:1a78:d055:216d:3a78"

        klass.expects(:new).with do |hash|
          hash[:endpoint] == "http://[caec:cec6:c4ef:bb7b:1a78:d055:216d:3a78]:5985/wsman"
        end

        make_connection
      end

      it "sets :endpoint from data in config" do
        config[:hostname] = "host-from-config"
        config[:port] = "42"
        config[:winrm_transport] = "ssl"

        klass.expects(:new).with do |hash|
          hash[:endpoint] == "https://host-from-config:42/wsman"
        end

        make_connection
      end

      it "sets :endpoint from data in state over config data" do
        state[:hostname] = "host-from-state"
        config[:hostname] = "host-from-config"
        state[:port] = "42"
        config[:port] = "43"
        config[:winrm_transport] = "ssl"

        klass.expects(:new).with do |hash|
          hash[:endpoint] == "https://host-from-state:42/wsman"
        end

        make_connection
      end

      it "sets :user from :username in config" do
        config[:username] = "user_from_config"

        klass.expects(:new).with do |hash|
          hash[:user] == "user_from_config"
        end

        make_connection
      end

      it "sets :user from :username in state over config data" do
        state[:username] = "user_from_state"
        config[:username] = "user_from_config"

        klass.expects(:new).with do |hash|
          hash[:user] == "user_from_state"
        end

        make_connection
      end

      it "sets :pass from :password in config" do
        config[:password] = "pass_from_config"

        klass.expects(:new).with do |hash|
          hash[:password] == "pass_from_config"
        end

        make_connection
      end

      it "sets :pass from :password in state over config data" do
        state[:password] = "pass_from_state"
        config[:password] = "pass_from_config"

        klass.expects(:new).with do |hash|
          hash[:password] == "pass_from_state"
        end

        make_connection
      end

      it "sets :rdp_port from config" do
        config[:rdp_port] = "rdp_from_config"

        klass.expects(:new).with do |hash|
          hash[:rdp_port] == "rdp_from_config"
        end

        make_connection
      end

      it "sets :rdp_port from state over config data" do
        state[:rdp_port] = "rdp_from_state"
        config[:rdp_port] = "rdp_from_config"

        klass.expects(:new).with do |hash|
          hash[:rdp_port] == "rdp_from_state"
        end

        make_connection
      end

      it "sets :connection_retries from config" do
        config[:connection_retries] = "retries_from_config"

        klass.expects(:new).with do |hash|
          hash[:connection_retries] == "retries_from_config"
        end

        make_connection
      end

      it "sets :connection_retries from state over config data" do
        state[:connection_retries] = "retries_from_state"
        config[:connection_retries] = "retries_from_config"

        klass.expects(:new).with do |hash|
          hash[:connection_retries] == "retries_from_state"
        end

        make_connection
      end

      it "sets :connection_retry_sleep from config" do
        config[:connection_retry_sleep] = "sleep_from_config"

        klass.expects(:new).with do |hash|
          hash[:connection_retry_sleep] == "sleep_from_config"
        end

        make_connection
      end

      it "sets :connection_retry_sleep from state over config data" do
        state[:connection_retry_sleep] = "sleep_from_state"
        config[:connection_retry_sleep] = "sleep_from_config"

        klass.expects(:new).with do |hash|
          hash[:connection_retry_sleep] == "sleep_from_state"
        end

        make_connection
      end

      it "sets :max_wait_until_ready from config" do
        config[:max_wait_until_ready] = "max_from_config"

        klass.expects(:new).with do |hash|
          hash[:max_wait_until_ready] == "max_from_config"
        end

        make_connection
      end

      it "sets :max_wait_until_ready from state over config data" do
        state[:max_wait_until_ready] = "max_from_state"
        config[:max_wait_until_ready] = "max_from_config"

        klass.expects(:new).with do |hash|
          hash[:max_wait_until_ready] == "max_from_state"
        end

        make_connection
      end

      it "sets :winrm_transport from config data" do
        config[:winrm_transport] = "ssl"

        klass.expects(:new).with do |hash|
          hash[:transport] == :ssl
        end

        make_connection
      end

      it "sets elevated_username from user by default" do
        config[:username] = "user"

        klass.expects(:new).with do |hash|
          hash[:elevated_username] == "user"
        end

        make_connection
      end

      it "sets elevated_username from overridden elevated_username" do
        config[:username] = "user"
        config[:elevated_username] = "elevated_user"

        klass.expects(:new).with do |hash|
          hash[:elevated_username] == "elevated_user"
        end

        make_connection
      end

      it "sets elevated_password from user by default" do
        config[:password] = "pass"

        klass.expects(:new).with do |hash|
          hash[:elevated_password] == "pass"
        end

        make_connection
      end

      it "sets elevated_password from overridden elevated_password" do
        config[:password] = "pass"
        config[:elevated_password] = "elevated_pass"

        klass.expects(:new).with do |hash|
          hash[:elevated_password] == "elevated_pass"
        end

        make_connection
      end

      it "sets elevated_password to nil if overridden elevated_password is nil" do
        config[:password] = "pass"
        config[:elevated_password] = nil

        klass.expects(:new).with do |hash|
          hash[:elevated_password].nil?
        end

        make_connection
      end

      describe "when negotiate is set in config" do
        before do
          config[:winrm_transport] = "negotiate"
        end

        it "sets :winrm_transport to negotiate" do
          klass.expects(:new).with do |hash|
            hash[:transport] == :negotiate &&
              hash[:disable_sspi] == false &&
              hash[:basic_auth_only] == false
          end

          make_connection
        end
      end

      it "returns the same connection when called again with same state" do
        first_connection  = make_connection(state)
        second_connection = make_connection(state)

        _(first_connection.object_id).must_equal second_connection.object_id
      end

      it "logs a debug message when the connection is reused" do
        make_connection(state)
        make_connection(state)

        _(logged_output.string.lines.count do |l|
          l =~ debug_line_with("[WinRM] reusing existing connection ")
        end).must_equal 1
      end

      it "returns a new connection when called again if state differs" do
        first_connection  = make_connection(state)
        second_connection = make_connection(state.merge(port: 9000))

        _(first_connection.object_id).wont_equal second_connection.object_id
      end

      it "closes first connection when a second is created" do
        first_connection = make_connection(state)
        first_connection.expects(:close)

        make_connection(state.merge(port: 9000))
      end

      it "logs a debug message a second connection is created" do
        make_connection(state)
        make_connection(state.merge(port: 9000))

        _(logged_output.string.lines.count do |l|
          l =~ debug_line_with("[WinRM] shutting previous connection ")
        end).must_equal 1
      end
    end
    # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

    describe "called without a block" do
      def make_connection(s = state)
        transport.connection(s)
      end

      common_connection_specs
    end

    describe "called with a block" do
      def make_connection(s = state)
        transport.connection(s) do |conn|
          conn
        end
      end

      common_connection_specs
    end
  end

  describe "#connection_options" do
    let(:data) do
      {
        kitchen_root: "path_to_kitchen",
        username: "Administrator",
        password: "bogus",
        rdp_port: 3389,
        connection_retries: 3,
        connection_retry_sleep: 1,
        operation_timeout: 60,
        receive_timeout: 70,
        max_wait_until_ready: 680,
        winrm_transport: :ssl,
        elevated: true,
        elevated_username: "SYSTEM",
        elevated_password: nil,
        scheme: "https",
        hostname: "myhost",
        port: 5986,
      }
    end
    let(:opts) do
      {
        user: "whatever",
        password: "whatever",
      }
    end
    let(:additional_opts) do
      {
        client_cert: "my_cert_path",
        client_key: "my_key_path",
      }
    end

    describe "when transport_type is :ssl and the client cert and key options are present" do
      before { transport.stubs(:additional_transport_args).returns(additional_opts) }

      it "removes the user and password keys in order to try to use certificate authentication" do
        final_opts = transport.send(:connection_options, data)
        assert_equal true, final_opts.key?(:client_cert)
        assert_equal true, final_opts.key?(:client_key)
        assert_equal false, final_opts.key?(:user)
        assert_equal false, final_opts.key?(:password)
      end
    end
  end

  describe "#additional_transport_args" do
    let(:opts) do
      {
        disable_sspi: false,
        basic_auth_only: false,
      }
    end
    let(:data) do
      {
        client_cert: "dummy",
        client_key: "dummy",
      }
    end

    describe "when transport type is :ssl" do
      let(:transport_type) { :ssl }

      describe "when :client_cert and :client_key are provided" do
        it "adds the :client_cert and :client_key into additional opts" do
          opts = transport.send(:additional_transport_args, data, transport_type)
          assert_equal true, opts.key?(:client_cert)
          assert_equal true, opts.key?(:client_key)
        end

        it "has the expected number of key value pairs" do
          opts = transport.send(:additional_transport_args, data, transport_type)
          assert_equal 5, opts.size
        end
      end

      describe "when :client_cert or :client_key are not provided" do
        let(:data) { {} }

        it "has the expected number of key value pairs" do
          opts = transport.send(:additional_transport_args, data, transport_type)
          assert_equal 3, opts.size
        end
      end

      describe "when :no_ssl_peer_verification is not provided explicitly" do
        it "sets it to true" do
          opts = transport.send(:additional_transport_args, data, transport_type)
          assert_equal true, opts[:no_ssl_peer_verification]
        end
      end

      describe "when :no_ssl_peer_verification is provided" do
        it "sets it to the given value" do
          data[:no_ssl_peer_verification] = false
          opts = transport.send(:additional_transport_args, data, transport_type)
          assert_equal false, opts[:no_ssl_peer_verification]
        end
      end

      it "sets the other values as expected" do
        opts = transport.send(:additional_transport_args, data, transport_type)
        assert_equal false, opts[:disable_sspi]
        assert_equal false, opts[:basic_auth_only]
      end
    end

    describe "when transport type is :negotiate" do
      let(:transport_type) { :negotiate }

      it "sets the values as expected" do
        opts = transport.send(:additional_transport_args, data, transport_type)
        assert_equal true, opts[:no_ssl_peer_verification]
        assert_equal false, opts[:disable_sspi]
        assert_equal false, opts[:basic_auth_only]
        assert_equal 3, opts.size
      end
    end

    describe "when transport type is :plaintext" do
      let(:transport_type) { :plaintext }

      it "sets the values as expected" do
        opts = transport.send(:additional_transport_args, data, transport_type)
        assert_equal true, opts[:disable_sspi]
        assert_equal true, opts[:basic_auth_only]
        assert_equal 2, opts.size
      end
    end
  end

  describe "#retry?" do
    let(:exception) { Kitchen::Transport::TransportFailed.new("failure message", 35) }

    it "raises an exception when multiple retryable exit codes are passed as a String" do
      _ { connection.retry?(2, 2, "35 1", exception) }
        .must_raise("undefined method `flatten' for \"35 1\":String")
    end

    it "returns true when the retryable exit codes are formatted in a nested array" do
      _(connection.retry?(1, 2, [[35, 1]], exception)).must_equal true
      _(connection.retry?(2, 2, [[35, 1]], exception)).must_equal true
    end

    describe "when exception is anything other than Kitchen::Transport::TransportFailed" do
      let(:exception) { RuntimeError.new("failure message") }

      it "returns false when the exception is anything other than Kitchen::Transport::TransportFailed" do
        _(connection.retry?(1, 2, [35, 1], exception)).must_equal false
        _(connection.retry?(2, 2, [35, 1], exception)).must_equal false
      end
    end

    describe "when exception is WinRM::WinRMHTTPTransportError" do
      let(:exception) { WinRM::WinRMHTTPTransportError.new("failure message", 400) }

      describe "when status code is 400" do
        let(:exception) { WinRM::WinRMHTTPTransportError.new("failure message", 400) }

        it "returns true" do
          _(connection.retry?(1, 2, [35, 1], exception)).must_equal true
        end
      end

      describe "when status code is 401" do
        let(:exception) { WinRM::WinRMHTTPTransportError.new("failure message", 401) }

        it "returns false" do
          _(connection.retry?(1, 2, [35, 1], exception)).must_equal false
        end
      end

      describe "when status code is 500" do
        let(:exception) { WinRM::WinRMHTTPTransportError.new("failure message", 500) }

        it "returns true" do
          _(connection.retry?(1, 2, [35, 1], exception)).must_equal true
        end
      end
    end

    describe "when exception is WinRM::WinRMWSManFault" do
      let(:exception) { WinRM::WinRMWSManFault.new("failure message", 42) }

      it "returns true" do
        _(connection.retry?(1, 2, [35, 1], exception)).must_equal true
      end
    end

    it "returns false when the maximum retries have been exceeded" do
      _(connection.retry?(3, 2, [35, 1], exception)).must_equal false
    end
  end

  describe "#load_needed_dependencies" do
    describe "winrm-elevated" do
      let(:transport) { Kitchen::Transport::Winrm.new(config) }

      before do
        transport.stubs(:require).with("winrm")
        transport.stubs(:require).with("winrm-fs")
      end

      describe "elevated is false" do
        it "does not require winrm-elevated" do
          transport.expects(:require).with("winrm-elevated").never
          transport.finalize_config!(instance)
        end
      end

      describe "elevated is true" do
        before { config[:elevated] = true }

        it "does requires winrm-elevated" do
          transport.expects(:require).with("winrm-elevated")
          transport.finalize_config!(instance)
        end
      end
    end

    describe "winrm-fs" do
      before do
        # force loading of winrm-fs to get the version constant
        require "winrm-fs"
      end

      it "logs a message to debug that code will be loaded" do
        transport

        _(logged_output.string).must_match debug_line_with(
          "winrm-fs requested, loading winrm-fs gem"
        )
      end

      it "logs a message to debug when library is initially loaded" do
        transport = Kitchen::Transport::Winrm.new(config)
        transport.stubs(:require).with("winrm", anything)
        transport.stubs(:require).with("winrm-fs").returns(true)
        transport.finalize_config!(instance)

        _(logged_output.string).must_match(
          /winrm-fs is loaded/
        )
      end

      it "logs a message to debug when library is previously loaded" do
        transport = Kitchen::Transport::Winrm.new(config)
        transport.stubs(:require).with("winrm", anything)
        transport.stubs(:require).with("winrm-fs").returns(false)
        transport.finalize_config!(instance)

        _(logged_output.string).must_match(
          /winrm-fs was already loaded/
        )
      end

      it "logs a message to fatal when libraries cannot be loaded" do
        transport = Kitchen::Transport::Winrm.new(config)
        transport.stubs(:require).with("winrm", anything)
        transport.stubs(:require).with("winrm-fs")
          .raises(LoadError, "uh oh")
        begin
          transport.finalize_config!(instance)
        rescue # rubocop:disable Lint/HandleExceptions
          # we are interested in the log output, not this exception
        end

        _(logged_output.string).must_match fatal_line_with(
          "The `winrm-fs` gem is missing and must be installed"
        )
      end

      it "raises a UserError when libraries cannot be loaded" do
        transport = Kitchen::Transport::Winrm.new(config)
        transport.stubs(:require).with("winrm", anything)
        transport.stubs(:require).with("winrm-fs")
          .raises(LoadError, "uh oh")

        err = _ { transport.finalize_config!(instance) }
          .must_raise Kitchen::UserError

        _(err.message).must_match(/^Could not load or activate winrm-fs\. /)
      end
    end

    describe "winrm" do
      it "logs a message to debug that code will be loaded" do
        transport = Kitchen::Transport::Winrm.new(config)
        transport.stubs(:require).with("winrm-fs", anything)
        transport.stubs(:require)
        transport.finalize_config!(instance)

        _(logged_output.string).must_match debug_line_with(
          "winrm requested, loading winrm gem"
        )
      end

      it "logs a message to debug when library is initially loaded" do
        transport = Kitchen::Transport::Winrm.new(config)
        transport.stubs(:require).with("winrm-fs", anything)
        transport.stubs(:require).returns(true)

        transport.finalize_config!(instance)

        _(logged_output.string).must_match(
          /winrm is loaded/
        )
      end

      it "logs a message to debug when library is previously loaded" do
        transport = Kitchen::Transport::Winrm.new(config)
        transport.stubs(:require).with("winrm-fs", anything)
        transport.stubs(:require).returns(false)

        transport.finalize_config!(instance)

        _(logged_output.string).must_match(
          /winrm was already loaded/
        )
      end

      it "logs a message to fatal when libraries cannot be loaded" do
        transport = Kitchen::Transport::Winrm.new(config)
        transport.stubs(:require).with("winrm-fs", anything)
        transport.stubs(:require).raises(LoadError, "uh oh")
        begin
          transport.finalize_config!(instance)
        rescue # rubocop:disable Lint/HandleExceptions
          # we are interested in the log output, not this exception
        end

        _(logged_output.string).must_match fatal_line_with(
          "The `winrm` gem is missing and must be installed"
        )
      end

      it "raises a UserError when libraries cannot be loaded" do
        transport = Kitchen::Transport::Winrm.new(config)
        transport.stubs(:require).with("winrm-fs", anything)
        transport.stubs(:require).raises(LoadError, "uh oh")

        err = _ { transport.finalize_config!(instance) }
          .must_raise Kitchen::UserError

        _(err.message).must_match(/^Could not load or activate winrm\. /)
      end
    end
  end

  def debug_line_with(msg)
    /^D, .* : #{Regexp.escape(msg)}/
  end

  def fatal_line_with(msg)
    /^F, .* : #{Regexp.escape(msg)}/
  end
end

describe Kitchen::Transport::Winrm::Connection do
  let(:logged_output)   { StringIO.new }
  let(:logger)          { Logger.new(logged_output) }

  let(:options) do
    { logger: logger, user: "me", password: "haha",
      endpoint: "http://foo:5985/wsman", winrm_transport: :plaintext,
      kitchen_root: "/i/am/root", instance_name: "coolbeans",
      rdp_port: "rdpyeah" }
  end

  let(:info) do
    copts = {
      user: "me",
      password: "haha",
      endpoint: "http://foo:5985/wsman",
      winrm_transport: :plaintext,
    }
    "<#{copts}>"
  end

  let(:winrm_session) do
    s = mock("winrm_session")
    s.responds_like_instance_of(::WinRM::Connection)
    s
  end

  let(:executor) do
    s = mock("command_executor")
    s.responds_like_instance_of(WinRM::Shells::Powershell)
    s
  end

  let(:transporter) do
    t = mock("file_transporter")
    t.responds_like_instance_of(WinRM::FS::Core::FileTransporter)
    t
  end

  let(:elevated_runner) do
    r = mock("elevated_runner")
    r.responds_like_instance_of(WinRM::Shells::Elevated)
    r
  end

  let(:connection) do
    Kitchen::Transport::Winrm::Connection.new(options)
  end

  before do
    WinRM::Connection.stubs(:new).returns(winrm_session)
    winrm_session.stubs(:logger=)
    logger.level = Logger::DEBUG
  end

  describe "#close" do
    let(:response) do
      o = WinRM::Output.new
      o.exitcode = 0
      o << { stdout: "ok\r\n" }
      o
    end

    before do
      transporter.stubs(:upload)
      elevated_runner.stubs(:run).returns(response)
      winrm_session.stubs(:shell).with(:powershell).returns(executor)
      executor.stubs(:close)
      elevated_runner.stubs(:close)
      executor.stubs(:run)
        .with("doit").yields("ok\n", nil).returns(response)
      executor.stubs(:run)
        .with("$env:temp").yields("ok\n", nil).returns(response)
    end

    it "only closes the shell once for multiple calls" do
      executor.expects(:close).once

      connection.execute("doit")
      connection.close
      connection.close
      connection.close
    end

    it "clears the file_transporter executor" do
      WinRM::FS::Core::FileTransporter.expects(:new).returns(transporter).twice

      connection.upload("local", "remote")
      connection.close
      connection.upload("local", "remote")
    end

    # TODO: Re-enable this test when we can figure out how to stub out
    # it "clears the elevated_runner executor" do
    #   options[:elevated] = true
    #   elevated_runner.stubs(:username=)
    #   elevated_runner.stubs(:password=)
    #   elevated_runner.expects(:close).once
    #   winrm_session.expects(:shell).with(:elevated).returns(elevated_runner).twice

    #   connection.execute("doit")
    #   connection.close
    #   connection.execute("doit")
    # end
  end

  describe "#execute" do
    before do
      winrm_session.stubs(:shell).with(:powershell).returns(executor)
    end

    describe "for a successful command" do
      let(:response) do
        o = WinRM::Output.new
        o.exitcode = 0
        o << { stdout: "ok\r\n" }
        o << { stderr: "congrats\r\n" }
        o
      end

      before do
        executor.expects(:run)
          .with("doit").yields("ok\n", nil).returns(response)
        executor.expects(:close).once
      end

      it "logger displays command on debug" do
        connection.execute("doit")

        string_to_mask = "[WinRM] #{info} (doit)"
        masked_string = Kitchen::Util.mask_values(string_to_mask, %w{password ssh_http_proxy_password})

        _(logged_output.string).must_match debug_line(
          masked_string
        )
      end

      it "logger captures stdout" do
        connection.execute("doit")

        _(logged_output.string).must_match(/^ok$/)
      end

      it "logger captures stderr on warn if logger is at debug level" do
        logger.level = Logger::DEBUG
        connection.execute("doit")

        _(logged_output.string).must_match warn_line("congrats")
      end

      it "logger does not log stderr on warn if logger is below debug level" do
        logger.level = Logger::INFO
        connection.execute("doit")

        _(logged_output.string).wont_match warn_line("congrats")
      end
    end

    describe "elevated command" do
      let(:response) do
        o = WinRM::Output.new
        o.exitcode = 0
        o << { stdout: "ok\r\n" }
        o << { stderr: "congrats\r\n" }
        o
      end
      let(:env_temp_response) do
        o = WinRM::Output.new
        o.exitcode = 0
        o << { stdout: "temp_dir" }
        o
      end
      let(:elevated_runner) do
        r = mock("elevated_runner")
        r.responds_like_instance_of(WinRM::Shells::Elevated)
        r
      end

      before do
        options[:elevated] = true
        winrm_session.stubs(:shell).with(:elevated).returns(elevated_runner)
        executor.expects(:close).once
        elevated_runner.expects(:close).once
      end

      describe "elevated user is not login user" do
        before do
          options[:elevated_username] = "username"
          options[:elevated_password] = "password"
          executor.expects(:run)
            .with("$env:temp").returns(env_temp_response)
          elevated_runner.expects(:run)
            .with(
              "$env:temp='temp_dir';doit"
            ).yields("ok\n", nil).returns(response)
          elevated_runner.expects(:username=).with("username")
          elevated_runner.expects(:password=).with("password")
        end

        it "logger captures stdout" do
          connection.execute("doit")

          _(logged_output.string).must_match(/^ok$/)
        end
      end

      describe "elevated user is login user" do
        before do
          options[:elevated_username] = options[:user]
          options[:elevated_password] = options[:password]
          executor.expects(:run)
            .with("$env:temp").returns(env_temp_response)
          elevated_runner.expects(:run)
            .with(
              "$env:temp='temp_dir';doit"
            ).yields("ok\n", nil).returns(response)
          elevated_runner.expects(:username=).with(options[:user])
          elevated_runner.expects(:password=).with(options[:password])
        end

        it "logger captures stdout" do
          connection.execute("doit")

          _(logged_output.string).must_match(/^ok$/)
        end
      end
    end

    describe "for a failed command" do
      let(:response) do
        o = WinRM::Output.new
        o.exitcode = 1
        o << { stderr: "#< CLIXML\r\n" }
        o << { stderr: '<Objs Version="1.1.0.1" xmlns="http://schemas.' }
        o << { stderr: 'microsoft.com/powershell/2004/04"><S S="Error">' }
        o << { stderr: "doit : The term 'doit' is not recognized as the " }
        o << { stderr: "name of a cmdlet, function, _x000D__x000A_</S>" }
        o << { stderr: '<S S="Error">script file, or operable program. ' }
        o << { stderr: "Check the spelling of" }
        o << { stderr: 'the name, or if a path _x000D__x000A_</S><S S="E' }
        o << { stderr: 'rror">was included, verify that the path is corr' }
        o << { stderr: 'ect and try again._x000D__x000A_</S><S S="Error' }
        o << { stderr: '">At line:1 char:1_x000D__x000A_</S><S S="Error' }
        o << { stderr: '">+ doit_x000D__x000A_</S><S S="Error">+ ~~~~_' }
        o << { stderr: 'x000D__x000A_</S><S S="Error">    + CategoryInf' }
        o << { stderr: "o          : ObjectNotFound: (doit:String) [], Co" }
        o << { stderr: 'mmandNotFoun _x000D__x000A_</S><S S="Error">   ' }
        o << { stderr: 'dException_x000D__x000A_</S><S S="Error">    + ' }
        o << { stderr: "FullyQualifiedErrorId : CommandNotFoundException_" }
        o << { stderr: 'x000D__x000A_</S><S S="Error"> _x000D__x000A_</' }
        o << { stderr: "S></Objs>" }
        o
      end

      before do
        executor.expects(:run)
          .with("doit").yields("nope\n", nil).returns(response)
        executor.expects(:close).once
      end

      # rubocop:disable Metrics/MethodLength
      def self.common_failed_command_specs # rubocop:disable Metrics/AbcSize
        it "logger displays command on debug" do
          begin
            connection.execute("doit")
          rescue # rubocop:disable Lint/HandleExceptions
            # the raise is not what is being tested here, rather its side-effect
          end

          string_to_mask = "[WinRM] #{info} (doit)"
          masked_string = Kitchen::Util.mask_values(string_to_mask, %w{password ssh_http_proxy_password})

          _(logged_output.string).must_match debug_line(
            masked_string
          )
        end

        it "logger captures stdout" do
          begin
            connection.execute("doit")
          rescue # rubocop:disable Lint/HandleExceptions
            # the raise is not what is being tested here, rather its side-effect
          end

          _(logged_output.string).must_match(/^nope$/)
        end

        it "stderr is printed on logger warn level" do
          begin
            connection.execute("doit")
          rescue # rubocop:disable Lint/HandleExceptions
            # the raise is not what is being tested here, rather its side-effect
          end

          message = <<~'MSG'.chomp!
            doit : The term 'doit' is not recognized as the name of a cmdlet, function,
            script file, or operable program. Check the spelling ofthe name, or if a path
            was included, verify that the path is correct and try again.
            At line:1 char:1
            + doit
            + ~~~~
                + CategoryInfo          : ObjectNotFound: (doit:String) [], CommandNotFoun
               dException
                + FullyQualifiedErrorId : CommandNotFoundException
          MSG

          message.lines.each do |line|
            _(logged_output.string).must_match warn_line(line.chomp)
          end
        end
      end
      # rubocop:enable Metrics/MethodLength

      describe "when a non-zero exit code is returned" do
        common_failed_command_specs

        it "raises a WinrmFailed exception" do
          err = _ { connection.execute("doit") }
            .must_raise Kitchen::Transport::WinrmFailed

          _(err.message).must_equal "WinRM exited (1) for command: [doit]"
        end

        it "raises WinrmFailed exception with the exit code of the failure" do
          connection.execute("doit")
        rescue Kitchen::Transport::WinrmFailed => e
          _(e.exit_code).must_equal 1
        end
      end
    end

    describe "for a nil command" do
      it "does not log on debug" do
        executor.expects(:open).never
        connection.execute(nil)

        _(logged_output.string).must_equal ""
      end
    end

    [
      Errno::EACCES, Errno::EADDRINUSE, Errno::ECONNREFUSED,
      Errno::ECONNRESET, Errno::ENETUNREACH, Errno::EHOSTUNREACH,
      ::WinRM::WinRMHTTPTransportError, ::WinRM::WinRMAuthorizationError,
      HTTPClient::KeepAliveDisconnected, HTTPClient::ConnectTimeoutError
    ].each do |klass|
      describe "raising #{klass}" do
        before do
          k = if klass == ::WinRM::WinRMHTTPTransportError
                # this exception takes 2 args in its constructor, which is not stock
                klass.new("dang", 200)
              else
                klass
              end

          options[:connection_retries] = 3
          options[:connection_retry_sleep] = 7
          winrm_session.stubs(:shell).with(:powershell).raises(k)
        end

        it "reraises the #{klass} exception" do
          _ { connection.execute("nope") }.must_raise klass
        end
      end
    end
  end

  describe "#login_command" do
    let(:login_command) { connection.login_command }
    let(:args)          { login_command.arguments.join(" ") }
    let(:exec_args)     { login_command.exec_args }

    let(:rdp_doc) do
      File.join(File.join(options[:kitchen_root], ".kitchen", "coolbeans.rdp"))
    end

    describe "for Mac-based workstations" do
      before do
        RbConfig::CONFIG.stubs(:[]).with("host_os").returns("darwin14")
      end

      it "returns a LoginCommand" do
        with_fake_fs do
          FileUtils.mkdir_p(File.dirname(rdp_doc))
          _(login_command).must_be_instance_of Kitchen::LoginCommand
        end
      end

      it "creates an rdp document" do
        actual = nil
        with_fake_fs do
          FileUtils.mkdir_p(File.dirname(rdp_doc))
          login_command
          actual = File.read(rdp_doc)
        end

        _(actual).must_equal Kitchen::Util.outdent!(<<-RDP)
          drivestoredirect:s:*
          full address:s:foo:rdpyeah
          prompt for credentials:i:1
          username:s:me
        RDP
      end

      it "prints the rdp document on debug" do
        with_fake_fs do
          FileUtils.mkdir_p(File.dirname(rdp_doc))
          login_command
        end

        expected = Kitchen::Util.outdent!(<<-OUTPUT)
          Creating RDP document for coolbeans (/i/am/root/.kitchen/coolbeans.rdp)
          ------------
          drivestoredirect:s:*
          full address:s:foo:rdpyeah
          prompt for credentials:i:1
          username:s:me
          ------------
        OUTPUT
        _(debug_output(logged_output.string)).must_match expected
      end

      it "returns a LoginCommand which calls open on the rdp document" do
        actual = nil
        with_fake_fs do
          FileUtils.mkdir_p(File.dirname(rdp_doc))
          actual = login_command
        end

        _(actual.exec_args).must_equal ["open", rdp_doc, {}]
      end
    end

    describe "for Windows-based workstations" do
      before do
        RbConfig::CONFIG.stubs(:[]).with("host_os").returns("mingw32")
      end

      it "returns a LoginCommand" do
        with_fake_fs do
          FileUtils.mkdir_p(File.dirname(rdp_doc))
          _(login_command).must_be_instance_of Kitchen::LoginCommand
        end
      end

      it "creates an rdp document" do
        actual = nil
        with_fake_fs do
          FileUtils.mkdir_p(File.dirname(rdp_doc))
          login_command
          actual = File.read(rdp_doc)
        end

        _(actual).must_equal Kitchen::Util.outdent!(<<-RDP)
          full address:s:foo:rdpyeah
          prompt for credentials:i:1
          username:s:me
        RDP
      end

      it "prints the rdp document on debug" do
        with_fake_fs do
          FileUtils.mkdir_p(File.dirname(rdp_doc))
          login_command
        end

        expected = Kitchen::Util.outdent!(<<-OUTPUT)
          Creating RDP document for coolbeans (/i/am/root/.kitchen/coolbeans.rdp)
          ------------
          full address:s:foo:rdpyeah
          prompt for credentials:i:1
          username:s:me
          ------------
        OUTPUT
        _(debug_output(logged_output.string)).must_match expected
      end

      it "returns a LoginCommand which calls mstsc on the rdp document" do
        actual = nil
        with_fake_fs do
          FileUtils.mkdir_p(File.dirname(rdp_doc))
          actual = login_command
        end

        _(actual.exec_args).must_equal ["mstsc", rdp_doc, {}]
      end
    end

    describe "for Linux-based workstations" do
      before do
        RbConfig::CONFIG.stubs(:[]).with("host_os").returns("linux-gnu")
        Kitchen::Util.stubs(:command_exists?).returns("/usr/bin/xfreerdp")
      end

      it "returns a LoginCommand" do
        _(login_command).must_be_instance_of Kitchen::LoginCommand
      end

      it "is an xfreerdp command" do
        _(login_command.command).must_equal "/usr/bin/xfreerdp"
        _(args).must_match(%r{ /cert-tofu$})
      end

      it "sets the user" do
        _(args).must_match regexify("/u:me ")
      end

      it "sets the pass if given" do
        _(args).must_match regexify(" /p:haha ")
      end

      it "won't set the pass if not given" do
        options.delete(:password)

        _(args).wont_match regexify(" /p:haha ")
      end

      describe "xfreerdp binary not found in path" do
        before do
          RbConfig::CONFIG.stubs(:[]).with("host_os").returns("linux-gnu")
          Kitchen::Util.stubs(:command_exists?).returns(false)
        end

        it "raises an WinrmFailed error" do
          err = _ { login_command }.must_raise Kitchen::Transport::WinrmFailed
          _(err.message).must_equal "xfreerdp binary not found. Please install freerdp2-x11 on Debian-based systems or freerdp on Redhat-based systems."
        end
      end
    end

    describe "for unknown workstation platforms" do
      before do
        RbConfig::CONFIG.stubs(:[]).with("host_os").returns("cray")
      end

      it "raises an ActionFailed error" do
        err = _ { login_command }.must_raise Kitchen::ActionFailed
        _(err.message).must_equal "Remote login not supported in " \
          "Kitchen::Transport::Winrm::Connection from host OS 'cray'."
      end
    end
  end

  describe "#upload" do
    before do
      winrm_session.stubs(:shell).with(:powershell).returns(executor)

      WinRM::FS::Core::FileTransporter.stubs(:new)
        .with(executor).returns(transporter)
      transporter.stubs(:upload)
    end

    def self.common_specs_for_upload # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      it "builds a Winrm::FileTransporter" do
        WinRM::FS::Core::FileTransporter.unstub(:new)

        WinRM::FS::Core::FileTransporter.expects(:new)
          .with(executor).returns(transporter)

        upload
      end

      it "reuses the Winrm::FileTransporter" do
        WinRM::FS::Core::FileTransporter.unstub(:new)

        WinRM::FS::Core::FileTransporter.expects(:new)
          .with(executor).returns(transporter).once

        upload
        upload
        upload
      end
    end

    describe "for a file" do
      def upload # execute every time, not lazily once
        connection.upload("/tmp/file.txt", 'C:\\dest')
      end

      common_specs_for_upload
    end

    describe "for a collection of files" do
      def upload # execute every time, not lazily once
        connection.upload(%w{/tmp/file1.txt /tmp/file2.txt}, 'C:\\dest')
      end

      common_specs_for_upload
    end
  end

  describe "#wait_until_ready" do
    before do
      winrm_session.stubs(:shell).with(:powershell).returns(executor)
      options[:max_wait_until_ready] = 300
    end

    describe "when connection is successful" do
      let(:response) do
        o = WinRM::Output.new
        o.exitcode = 0
        o << { stdout: "[WinRM] Established\r\n" }
        o
      end

      before do
        executor.expects(:run)
          .with("Write-Host '[WinRM] Established\n'").returns(response)
        executor.expects(:close).once
      end

      it "executes an empty command string to ensure working" do
        connection.wait_until_ready
      end
    end

    describe "when connection succeeds but command fails, sad panda" do
      let(:response) do
        o = WinRM::Output.new
        o.exitcode = 42
        o << { stderr: "Ah crap.\r\n" }
        o
      end

      before do
        executor.expects(:run)
          .with("Write-Host '[WinRM] Established\n'").returns(response)
        executor.expects(:close).once
      end

      it "executes an empty command string to ensure working" do
        err = _ { connection.wait_until_ready }
          .must_raise Kitchen::Transport::WinrmFailed

        _(err.message).must_equal "WinRM exited (42) for command: " \
          "[Write-Host '[WinRM] Established\n']"
      end

      it "stderr is printed on logger warn level" do
        begin
          connection.wait_until_ready
        rescue # rubocop:disable Lint/HandleExceptions
          # the raise is not what is being tested here, rather its side-effect
        end

        _(logged_output.string).must_match warn_line("Ah crap.\n")
      end
    end

    describe "when connection is over HTTPS" do
      before do
        executor.expects(:run)
          .with("Write-Host '[WinRM] Established\n'").raises(OpenSSL::SSL::SSLError)
        executor.expects(:close)
      end

      it "fails with SSL error" do
        _ { connection.wait_until_ready }.must_raise OpenSSL::SSL::SSLError
      end
    end

    describe "when connection is over HTTPS and there are retries" do
      before do
        executor.expects(:run).times(2)
          .with("Write-Host '[WinRM] Established\n'").raises(OpenSSL::SSL::SSLError)
        executor.expects(:close).times(2)
        options[:connection_retries] = 1
        options[:connection_retry_sleep] = 1
      end

      it "fails with SSL error" do
        _ { connection.wait_until_ready }.must_raise OpenSSL::SSL::SSLError
      end
    end
  end

  def debug_output(output)
    regexp = /^D, .* DEBUG -- : /
    output.lines.grep(/^D, .* DEBUG -- : /).map { |l| l.sub(regexp, "") }.join
  end

  def debug_line(msg)
    /^D, .* : #{Regexp.escape(msg)}$/
  end

  def debug_line_with(msg)
    /^D, .* : #{Regexp.escape(msg)}/
  end

  def info_line(msg)
    /^I, .* : #{Regexp.escape(msg)}$/
  end

  def info_line_with(msg)
    /^I, .* : #{Regexp.escape(msg)}/
  end

  def regexify(string)
    Regexp.new(Regexp.escape(string))
  end

  def warn_line(msg)
    /^W, .* : #{Regexp.escape(msg)}$/
  end

  def warn_line_with(msg)
    /^W, .* : #{Regexp.escape(msg)}/
  end
end
