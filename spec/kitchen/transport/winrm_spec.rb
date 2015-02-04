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

require "kitchen/transport/winrm"

describe Kitchen::Transport::Winrm do

  let(:logged_output) { StringIO.new }
  let(:logger)        { Logger.new(logged_output) }
  let(:config)        { Hash.new }
  let(:state)         { Hash.new }

  let(:instance) do
    stub(:name => "coolbeans", :logger => logger, :to_str => "instance")
  end

  let(:transport) do
    Kitchen::Transport::Winrm.new(config).finalize_config!(instance)
  end

  describe "default_config" do

    it "sets :port to 5985 by default" do
      transport[:port].must_equal 5985
    end

    it "sets :username to .\\administrator by default" do
      transport[:username].must_equal ".\\administrator"
    end

    it "sets :password to nil by default" do
      transport[:password].must_equal nil
    end

    it "sets a default :endpoint_template value" do
      transport[:endpoint_template].
        must_equal "http://%{hostname}:%{port}/wsman"
    end

    it "sets :connection_retries to 5 by default" do
      transport[:connection_retries].must_equal 5
    end

    it "sets :connection_retry_sleep to 1 by default" do
      transport[:connection_retry_sleep].must_equal 1
    end

    it "sets :max_wait_until_ready to 600 by default" do
      transport[:max_wait_until_ready].must_equal 600
    end
  end

  describe "#connection" do

    let(:klass) { Kitchen::Transport::Winrm::Connection }

    # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    def self.common_connection_specs
      before do
        config[:hostname] = "here"
      end

      it "returns a Kitchen::Transport::Winrm::Connection object" do
        transport.connection(state).must_be_kind_of klass
      end

      it "sets the :logger to the transport's logger" do
        klass.expects(:new).with do |hash|
          hash[:logger] == logger
        end

        make_connection
      end

      it "sets the :winrm_transport to :plaintext" do
        klass.expects(:new).with do |hash|
          hash[:winrm_transport] == :plaintext
        end

        make_connection
      end

      it "sets the :disable_sspi to true" do
        klass.expects(:new).with do |hash|
          hash[:disable_sspi] == true
        end

        make_connection
      end

      it "sets the :basic_auth_only to true" do
        klass.expects(:new).with do |hash|
          hash[:basic_auth_only] == true
        end

        make_connection
      end

      it "sets :endpoint from data in config" do
        config[:hostname] = "host_from_config"
        config[:port] = "port_from_config"

        klass.expects(:new).with do |hash|
          hash[:endpoint] == "http://host_from_config:port_from_config/wsman"
        end

        make_connection
      end

      it "sets :endpoint from data in state over config data" do
        state[:hostname] = "host_from_state"
        config[:hostname] = "host_from_config"
        state[:port] = "port_from_state"
        config[:port] = "port_from_config"

        klass.expects(:new).with do |hash|
          hash[:endpoint] == "http://host_from_state:port_from_state/wsman"
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
          hash[:pass] == "pass_from_config"
        end

        make_connection
      end

      it "sets :pass from :password in state over config data" do
        state[:password] = "pass_from_state"
        config[:password] = "pass_from_config"

        klass.expects(:new).with do |hash|
          hash[:pass] == "pass_from_state"
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

      it "returns the same connection when called again with same state" do
        first_connection  = make_connection(state)
        second_connection = make_connection(state)

        first_connection.object_id.must_equal second_connection.object_id
      end

      it "logs a debug message when the connection is reused" do
        make_connection(state)
        make_connection(state)

        logged_output.string.lines.select { |l|
          l =~ debug_line_with("[WinRM] reusing existing connection ")
        }.size.must_equal 1
      end

      it "returns a new connection when called again if state differs" do
        first_connection  = make_connection(state)
        second_connection = make_connection(state.merge(:port => 9000))

        first_connection.object_id.wont_equal second_connection.object_id
      end

      it "closes first connection when a second is created" do
        first_connection = make_connection(state)
        first_connection.expects(:shutdown)

        make_connection(state.merge(:port => 9000))
      end

      it "logs a debug message a second connection is created" do
        make_connection(state)
        make_connection(state.merge(:port => 9000))

        logged_output.string.lines.select { |l|
          l =~ debug_line_with("[WinRM] shutting previous connection ")
        }.size.must_equal 1
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

  def debug_line_with(msg)
    %r{^D, .* : #{Regexp.escape(msg)}}
  end
end

describe Kitchen::Transport::Winrm::Connection do

  let(:logged_output)   { StringIO.new }
  let(:logger)          { Logger.new(logged_output) }

  let(:options) do
    { :logger => logger, :user => "me", :pass => "haha",
      :endpoint => "http://foo:5985/wsman", :winrm_transport => :plaintext }
  end

  let(:info) do
    copts = { :user => "me", :pass => "haha" }
    "plaintext::http://foo:5985/wsman<#{copts}>"
  end

  let(:winrm_session) do
    s = mock("winrm_session")
    s.responds_like_instance_of(::WinRM::WinRMWebService)
    s
  end

  let(:connection) do
    Kitchen::Transport::Winrm::Connection.new(options)
  end

  before do
    logger.level = Logger::DEBUG
    ::WinRM::WinRMWebService.stubs(:new).
      with("http://foo:5985/wsman", :plaintext, :user => "me", :pass => "haha").
      returns(winrm_session)
  end

  describe "#execute" do

    describe "for a successful command" do

      let(:response) do
        {
          :data => [{ :stdout => "ok\r\n" }],
          :exitcode => 0
        }
      end

      before do
        winrm_session.expects(:run_powershell_script).
          with("doit").yields("ok\n", nil).returns(response)
      end

      it "logger displays command on debug" do
        connection.execute("doit")

        logged_output.string.must_match debug_line(
          "[WinRM] #{info} (doit)")
      end

      it "logger displays establishing connection on debug" do
        connection.execute("doit")

        logged_output.string.must_match debug_line(
          "[WinRM] opening connection to #{info}"
        )
      end

      it "logger captures stdout" do
        connection.execute("doit")

        logged_output.string.must_match(/^ok$/)
      end
    end

    describe "for a failed command" do

      let(:response) do
        {
          :data => [
            { :stderr => "#< CLIXML\r\n" },
            { :stderr => "<Objs Version=\"1.1.0.1\" xmlns=\"http://schemas." },
            { :stderr => "microsoft.com/powershell/2004/04\"><S S=\"Error\">" },
            { :stderr => "doit : The term 'doit' is not recognized as the " },
            { :stderr => "name of a cmdlet, function, _x000D__x000A_</S>" },
            { :stderr => "<S S=\"Error\">script file, or operable program. " },
            { :stderr => "Check the spelling of" },
            { :stderr => "the name, or if a path _x000D__x000A_</S><S S=\"E" },
            { :stderr => "rror\">was included, verify that the path is corr" },
            { :stderr => "ect and try again._x000D__x000A_</S><S S=\"Error" },
            { :stderr => "\">At line:1 char:1_x000D__x000A_</S><S S=\"Error" },
            { :stderr => "\">+ doit_x000D__x000A_</S><S S=\"Error\">+ ~~~~_" },
            { :stderr => "x000D__x000A_</S><S S=\"Error\">    + CategoryInf" },
            { :stderr => "o          : ObjectNotFound: (doit:String) [], Co" },
            { :stderr => "mmandNotFoun _x000D__x000A_</S><S S=\"Error\">   " },
            { :stderr => "dException_x000D__x000A_</S><S S=\"Error\">    + " },
            { :stderr => "FullyQualifiedErrorId : CommandNotFoundException_" },
            { :stderr => "x000D__x000A_</S><S S=\"Error\"> _x000D__x000A_</" },
            { :stderr => "S></Objs>" }
          ],
          :exitcode => 1
        }
      end

      before do
        winrm_session.expects(:run_powershell_script).
          with("doit").yields("nope\n", nil).returns(response)
      end

      # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      def self.common_failed_command_specs
        it "logger displays command on debug" do
          begin
            connection.execute("doit")
          rescue # rubocop:disable Lint/HandleExceptions
            # the raise is not what is being tested here, rather its side-effect
          end

          logged_output.string.must_match debug_line(
            "[WinRM] #{info} (doit)"
          )
        end

        it "logger displays establishing connection on debug" do
          begin
            connection.execute("doit")
          rescue # rubocop:disable Lint/HandleExceptions
            # the raise is not what is being tested here, rather its side-effect
          end

          logged_output.string.must_match debug_line(
            "[WinRM] opening connection to #{info}"
          )
        end

        it "logger captures stdout" do
          begin
            connection.execute("doit")
          rescue # rubocop:disable Lint/HandleExceptions
            # the raise is not what is being tested here, rather its side-effect
          end

          logged_output.string.must_match(/^nope$/)
        end

        it "stderr is printed on logger warn level" do
          begin
            connection.execute("doit")
          rescue # rubocop:disable Lint/HandleExceptions
            # the raise is not what is being tested here, rather its side-effect
          end

          message = <<'MSG'.chomp!
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
            logged_output.string.must_match warn_line(line.chomp)
          end
        end
      end
      # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

      describe "when a non-zero exit code is returned" do

        common_failed_command_specs

        it "raises a WinrmFailed exception" do
          err = proc {
            connection.execute("doit")
          }.must_raise Kitchen::Transport::WinrmFailed
          err.message.must_equal "WinRM exited (1) for command: [doit]"
        end
      end

      describe "when a zero exit code is returned but with buffered stderr" do

        before do
          response[:exitcode] = 0
        end

        common_failed_command_specs

        it "raises a WinrmFailed exception" do
          err = proc {
            connection.execute("doit")
          }.must_raise Kitchen::Transport::WinrmFailed
          err.message.must_equal "WinRM exited (0) but contained " \
            "a STDERR stream for command: [doit]"
        end
      end
    end

    [
      Errno::EACCES, Errno::EADDRINUSE, Errno::ECONNREFUSED,
      Errno::ECONNRESET, Errno::ENETUNREACH, Errno::EHOSTUNREACH,
      ::WinRM::WinRMHTTPTransportError, ::WinRM::WinRMAuthorizationError,
      HTTPClient::KeepAliveDisconnected
    ].each do |klass|
      describe "raising #{klass}" do

        before do
          k = if klass == ::WinRM::WinRMHTTPTransportError
            # this exception takes 2 args in its constructor, which is not stock
            klass.new("dang", 200)
          else
            klass
          end

          winrm_session.stubs(:run_powershell_script).raises(k)
          options[:connection_retries] = 3
          options[:connection_retry_sleep] = 7
          connection.stubs(:sleep)
        end

        it "reraises the #{klass} exception" do
          proc { connection.execute("nope") }.must_raise klass
        end

        it "attempts to connect :connection_retries times" do
          begin
            connection.execute("nope")
          rescue # rubocop:disable Lint/HandleExceptions
            # the raise is not what is being tested here, rather its side-effect
          end

          logged_output.string.lines.select { |l|
            l =~ debug_line("[WinRM] opening connection to #{info}")
          }.size.must_equal 3
        end

        it "sleeps for :connection_retry_sleep seconds between retries" do
          connection.unstub(:sleep)
          connection.expects(:sleep).with(7).twice

          begin
            connection.execute("nope")
          rescue # rubocop:disable Lint/HandleExceptions
            # the raise is not what is being tested here, rather its side-effect
          end
        end

        it "logs the first 2 retry failures on info" do
          begin
            connection.execute("nope")
          rescue # rubocop:disable Lint/HandleExceptions
            # the raise is not what is being tested here, rather its side-effect
          end

          logged_output.string.lines.select { |l|
            l =~ info_line_with(
              "[WinRM] connection failed, retrying in 7 seconds")
          }.size.must_equal 2
        end

        it "logs the last retry failures on warn" do
          begin
            connection.execute("nope")
          rescue # rubocop:disable Lint/HandleExceptions
            # the raise is not what is being tested here, rather its side-effect
          end

          logged_output.string.lines.select { |l|
            l =~ warn_line_with("[WinRM] connection failed, terminating ")
          }.size.must_equal 1
        end
      end
    end
  end

  describe "#wait_until_ready" do

    before do
      options[:max_wait_until_ready] = 300
      connection.stubs(:sleep)
    end

    describe "when failing to connect" do

      before do
        winrm_session.stubs(:run_powershell_script).raises(Errno::ECONNREFUSED)
      end

      it "attempts to connect :max_wait_until_ready / 3 times if failing" do
        begin
          connection.wait_until_ready
        rescue # rubocop:disable Lint/HandleExceptions
          # the raise is not what is being tested here, rather its side-effect
        end

        logged_output.string.lines.select { |l|
          l =~ info_line_with(
            "Waiting for WinRM service on http://foo:5985/wsman, retrying in 3 seconds")
        }.size.must_equal((300 / 3) - 1)
        logged_output.string.lines.select { |l|
          l =~ debug_line_with("[WinRM] connection failed ")
        }.size.must_equal((300 / 3) - 1)
        logged_output.string.lines.select { |l|
          l =~ warn_line_with("[WinRM] connection failed, terminating ")
        }.size.must_equal 1
      end

      it "sleeps for 3 seconds between retries" do
        connection.unstub(:sleep)
        connection.expects(:sleep).with(3).times((300 / 3) - 1)

        begin
          connection.wait_until_ready
        rescue # rubocop:disable Lint/HandleExceptions
          # the raise is not what is being tested here, rather its side-effect
        end
      end
    end

    describe "when connection is successful" do

      let(:response) do
        {
          :data => [{ :stdout => "[WinRM] Established\r\n" }],
          :exitcode => 0
        }
      end

      before do
        winrm_session.expects(:run_powershell_script).
          with("Write-Host '[WinRM] Established\n'").returns(response)
      end

      it "executes an empty command string to ensure working" do
        connection.wait_until_ready
      end
    end

    describe "when connection suceeds but command fails, sad panda" do

      let(:response) do
        {
          :data => [{ :stderr => "Ah crap.\r\n" }],
          :exitcode => 42
        }
      end

      before do
        winrm_session.expects(:run_powershell_script).
          with("Write-Host '[WinRM] Established\n'").returns(response)
      end

      it "executes an empty command string to ensure working" do
        err = proc {
          connection.wait_until_ready
        }.must_raise Kitchen::Transport::WinrmFailed
        err.message.must_equal "WinRM exited (42) for command: " \
          "[Write-Host '[WinRM] Established\n']"
      end

      it "stderr is printed on logger warn level" do
        begin
          connection.wait_until_ready
        rescue # rubocop:disable Lint/HandleExceptions
          # the raise is not what is being tested here, rather its side-effect
        end

        logged_output.string.must_match warn_line("Ah crap.\n")
      end
    end
  end

  def debug_line(msg)
    %r{^D, .* : #{Regexp.escape(msg)}$}
  end

  def debug_line_with(msg)
    %r{^D, .* : #{Regexp.escape(msg)}}
  end

  def info_line_with(msg)
    %r{^I, .* : #{Regexp.escape(msg)}}
  end

  def warn_line(msg)
    %r{^W, .* : #{Regexp.escape(msg)}$}
  end

  def warn_line_with(msg)
    %r{^W, .* : #{Regexp.escape(msg)}}
  end
end
