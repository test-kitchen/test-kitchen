# -*- encoding: utf-8 -*-
#
# Author:: Fletcher Nichol (<fnichol@nichol.ca>)
#
# Copyright (C) 2015, Fletcher Nichol
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

require "kitchen/transport/ssh"

# Hack to sort results in `Dir.entries` only within the yielded block, to limit
# the "behavior pollution" to other code. This was needed for Net::SCP, as
# recursive directory upload doesn't sort the file and directory upload
# candidates which leads to different results based on the underlying
# filesystem (i.e. lexically sorted, inode insertion, mtime/atime, total
# randomness, etc.)
#
# See: https://github.com/net-ssh/net-scp/blob/a24948/lib/net/scp/upload.rb#L52

def with_sorted_dir_entries
  Dir.class_exec do
    class << self
      alias_method :__entries__, :entries unless method_defined?(:__entries__)

      def entries(*args) # rubocop:disable Lint/NestedMethodDefinition
        send(:__entries__, *args).sort
      end
    end
  end

  yield

  Dir.class_exec do
    class << self
      alias_method :entries, :__entries__
    end
  end
end

# Terrible hack to deal with Net::SSH:Test::Extensions which monkey patches
# `IO.select` with a version for testing Net::SSH code. Unfortunetly this
# impacts other code, so we'll "un-patch" this after each spec and "re-patch"
# it before the next one.
require "net/ssh/test"
def depatch_io
  IO.class_exec do
    class << self
      alias_method :select, :select_for_real
    end
  end
end
# We need to immediately call depatch so that `IO.select` is in a good state
# _right now_.  The require immediately monkeypatches it and we only want
# it monkey patched inside each ssh test
depatch_io

def repatch_io
  IO.class_exec do
    class << self
      alias_method :select, :select_for_test
    end
  end
end

# Major hack-and-a-half to add basic `Channel#request_pty` support to
# Net::SSH's testing framework. The `Net::SSH::Test::LocalPacket` does not
# recognize the `"pty-req"` request type, so bombs out whenever this channel
# request is sent.
#
# This "make-work" fix adds a method (`#sends_request_pty`) which works just
# like `#sends_exec` expcept that it enqueues a patched subclass of
# `LocalPacket` which can deal with the `"pty-req"` type.
#
# An upstream patch to Net::SSH will be required to retire this yak shave ;)
require "net/ssh/test/channel"
module Net

  module SSH

    module Test

      class Channel

        def sends_request_pty
          pty_data = ["xterm", 80, 24, 640, 480, "\0"]

          script.events << Class.new(Net::SSH::Test::LocalPacket) do
            def types # rubocop:disable Lint/NestedMethodDefinition
              if @type == 98 && @data[1] == "pty-req"
                @types ||= [
                  :long, :string, :bool, :string,
                  :long, :long, :long, :long, :string
                ]
              else
                super
              end
            end
          end.new(:channel_request, remote_id, "pty-req", false, *pty_data)
        end
      end
    end
  end
end

describe Kitchen::Transport::Ssh do

  let(:logged_output) { StringIO.new }
  let(:logger)        { Logger.new(logged_output) }
  let(:config)        { Hash.new }
  let(:state)         { Hash.new }

  let(:instance) do
    stub(:name => "coolbeans", :logger => logger, :to_str => "instance")
  end

  let(:transport) do
    Kitchen::Transport::Ssh.new(config).finalize_config!(instance)
  end

  it "provisioner api_version is 1" do
    transport.diagnose_plugin[:api_version].must_equal 1
  end

  it "plugin_version is set to Kitchen::VERSION" do
    transport.diagnose_plugin[:version].must_equal Kitchen::VERSION
  end

  describe "default_config" do

    it "sets :port to 22 by default" do
      transport[:port].must_equal 22
    end

    it "sets :username to root by default" do
      transport[:username].must_equal "root"
    end

    it "sets :compression to true by default" do
      transport[:compression].must_equal false
    end

    it "sets :compression to false if set to none" do
      config[:compression] = "none"

      transport[:compression].must_equal false
    end

    it "sets :compression to zlib@openssh.com if set to zlib" do
      config[:compression] = "zlib"

      transport[:compression].must_equal "zlib@openssh.com"
    end

    it "sets :compression_level to 6 by default" do
      transport[:compression_level].must_equal 0
    end

    it "sets :compression_level to 6 if :compression is set to true" do
      config[:compression] = true

      transport[:compression_level].must_equal 6
    end

    it "sets :keepalive to true by default" do
      transport[:keepalive].must_equal true
    end

    it "sets :keepalive_interval to 60 by default" do
      transport[:keepalive_interval].must_equal 60
    end

    it "sets :connection_timeout to 15 by default" do
      transport[:connection_timeout].must_equal 15
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

    it "sets :ssh_key to nil by default" do
      transport[:ssh_key].must_equal nil
    end

    it "expands :ssh_path path if set" do
      config[:kitchen_root] = "/rooty"
      config[:ssh_key] = "my_key"

      transport[:ssh_key].must_equal os_safe_root_path("/rooty/my_key")
    end

    it "sets :max_ssh_sessions to 9 by default" do
      transport[:max_ssh_sessions].must_equal 9
    end
  end

  describe "#connection" do

    let(:klass) { Kitchen::Transport::Ssh::Connection }

    # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    def self.common_connection_specs
      it "returns a Kitchen::Transport::Ssh::Connection object" do
        transport.connection(state).must_be_kind_of klass
      end

      it "sets the :logger to the transport's logger" do
        klass.expects(:new).with do |hash|
          hash[:logger] == logger
        end

        make_connection
      end

      it "sets the :user_known_hosts_file to /dev/null" do
        klass.expects(:new).with do |hash|
          hash[:user_known_hosts_file] == "/dev/null"
        end

        make_connection
      end

      it "sets the :paranoid flag to false" do
        klass.expects(:new).with do |hash|
          hash[:paranoid] == false
        end

        make_connection
      end

      it "sets :hostname from config" do
        config[:hostname] = "host_from_config"

        klass.expects(:new).with do |hash|
          hash[:hostname] == "host_from_config"
        end

        make_connection
      end

      it "sets :hostname from state over config data" do
        state[:hostname] = "host_from_state"
        config[:hostname] = "host_from_config"

        klass.expects(:new).with do |hash|
          hash[:hostname] == "host_from_state"
        end

        make_connection
      end

      it "sets :port from config" do
        config[:port] = "port_from_config"

        klass.expects(:new).with do |hash|
          hash[:port] == "port_from_config"
        end

        make_connection
      end

      it "sets :port from state over config data" do
        state[:port] = "port_from_state"
        config[:port] = "port_from_config"

        klass.expects(:new).with do |hash|
          hash[:port] == "port_from_state"
        end

        make_connection
      end

      it "sets :username from config" do
        config[:username] = "user_from_config"

        klass.expects(:new).with do |hash|
          hash[:username] == "user_from_config"
        end

        make_connection
      end

      it "sets :username from state over config data" do
        state[:username] = "user_from_state"
        config[:username] = "user_from_config"

        klass.expects(:new).with do |hash|
          hash[:username] == "user_from_state"
        end

        make_connection
      end

      it "sets :compression from config" do
        config[:compression] = "none"

        klass.expects(:new).with do |hash|
          hash[:compression] == false
        end

        make_connection
      end

      it "sets :compression from state over config data" do
        state[:compression] = "none"
        config[:compression] = "zlib"

        klass.expects(:new).with do |hash|
          hash[:compression] == "none"
        end

        make_connection
      end

      it "sets :compression_level from config" do
        config[:compression_level] = 9999

        klass.expects(:new).with do |hash|
          hash[:compression_level] == 9999
        end

        make_connection
      end

      it "sets :compression_level from state over config data" do
        state[:compression_level] = 9999
        config[:compression_level] = 1111

        klass.expects(:new).with do |hash|
          hash[:compression_level] == 9999
        end

        make_connection
      end

      it "sets :timeout from :connection_timeout in config" do
        config[:connection_timeout] = "timeout_from_config"

        klass.expects(:new).with do |hash|
          hash[:timeout] == "timeout_from_config"
        end

        make_connection
      end

      it "sets :timeout from :connection_timeout in state over config data" do
        state[:connection_timeout] = "timeout_from_state"
        config[:connection_timeout] = "timeout_from_config"

        klass.expects(:new).with do |hash|
          hash[:timeout] == "timeout_from_state"
        end

        make_connection
      end

      it "sets :keepalive from config" do
        config[:keepalive] = "keepalive_from_config"

        klass.expects(:new).with do |hash|
          hash[:keepalive] == "keepalive_from_config"
        end

        make_connection
      end

      it "sets :keepalive from state over config data" do
        state[:keepalive] = "keepalive_from_state"
        config[:keepalive] = "keepalive_from_config"

        klass.expects(:new).with do |hash|
          hash[:keepalive] == "keepalive_from_state"
        end

        make_connection
      end

      it "sets :keepalive_interval from config" do
        config[:keepalive_interval] = "interval_from_config"

        klass.expects(:new).with do |hash|
          hash[:keepalive_interval] == "interval_from_config"
        end

        make_connection
      end

      it "sets :keepalive_interval from state over config data" do
        state[:keepalive_interval] = "interval_from_state"
        config[:keepalive_interval] = "interval_from_config"

        klass.expects(:new).with do |hash|
          hash[:keepalive_interval] == "interval_from_state"
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

      it "sets :keys_only to true if :ssh_key is set in config" do
        config[:ssh_key] = "ssh_key_from_config"

        klass.expects(:new).with do |hash|
          hash[:keys_only] == true
        end

        make_connection
      end

      it "sets :auth_methods to only publickey if :ssh_key is set in config" do
        config[:ssh_key] = "ssh_key_from_config"

        klass.expects(:new).with do |hash|
          hash[:auth_methods] == ["publickey"]
        end

        make_connection
      end

      it "sets :keys_only to true if :ssh_key is set in state" do
        state[:ssh_key] = "ssh_key_from_config"
        config[:ssh_key] = false

        klass.expects(:new).with do |hash|
          hash[:keys_only] == true
        end

        make_connection
      end

      it "sets :keys to an array if :ssh_key is set in config" do
        config[:kitchen_root] = "/r"
        config[:ssh_key] = "ssh_key_from_config"

        klass.expects(:new).with do |hash|
          hash[:keys] == [os_safe_root_path("/r/ssh_key_from_config")]
        end

        make_connection
      end

      it "sets :keys to an array if :ssh_key is set in state" do
        state[:ssh_key] = "ssh_key_from_state"
        config[:ssh_key] = "ssh_key_from_config"

        klass.expects(:new).with do |hash|
          hash[:keys] == ["ssh_key_from_state"]
        end

        make_connection
      end

      it "does not set :keys_only if :ssh_key is set in config but password is set" do
        config[:ssh_key] = "ssh_key_from_config"
        config[:password] = "password"

        klass.expects(:new).with do |hash|
          hash[:keys_only].nil?
        end

        make_connection
      end

      it "does not set :auth_methods if :ssh_key is set in config but password is set" do
        config[:ssh_key] = "ssh_key_from_config"
        config[:password] = "password"

        klass.expects(:new).with do |hash|
          hash[:auth_methods].nil?
        end

        make_connection
      end

      it "does not set :keys_only if :ssh_key is set in state but password is set" do
        state[:ssh_key] = "ssh_key_from_config"
        config[:ssh_key] = false
        config[:password] = "password"

        klass.expects(:new).with do |hash|
          hash[:keys_only].nil?
        end

        make_connection
      end

      it "does not set :keys to an array if :ssh_key is set in config but password is set" do
        config[:kitchen_root] = "/r"
        config[:ssh_key] = "ssh_key_from_config"
        config[:password] = "password"

        klass.expects(:new).with do |hash|
          hash[:keys].nil?
        end

        make_connection
      end

      it "does not set :keys to an array if :ssh_key is set in state but password is set" do
        state[:ssh_key] = "ssh_key_from_state"
        config[:ssh_key] = "ssh_key_from_config"
        config[:password] = "password"

        klass.expects(:new).with do |hash|
          hash[:keys].nil?
        end

        make_connection
      end

      it "passes in :password if set in config" do
        config[:password] = "password_from_config"

        klass.expects(:new).with do |hash|
          hash[:password] == "password_from_config"
        end

        make_connection
      end

      it "passes in :password from state over config data" do
        state[:password] = "password_from_state"
        config[:password] = "password_from_config"

        klass.expects(:new).with do |hash|
          hash[:password] == "password_from_state"
        end

        make_connection
      end

      it "passes in :forward_agent if set in config" do
        config[:forward_agent] = "forward_agent_from_config"

        klass.expects(:new).with do |hash|
          hash[:forward_agent] == "forward_agent_from_config"
        end

        make_connection
      end

      it "passes in :forward_agent from state over config data" do
        state[:forward_agent] = "forward_agent_from_state"
        config[:forward_agent] = "forward_agent_from_config"

        klass.expects(:new).with do |hash|
          hash[:forward_agent] == "forward_agent_from_state"
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

        logged_output.string.lines.count { |l|
          l =~ debug_line_with("[SSH] reusing existing connection ")
        }.must_equal 1
      end

      it "returns a new connection when called again if state differs" do
        first_connection  = make_connection(state)
        second_connection = make_connection(state.merge(:port => 9000))

        first_connection.object_id.wont_equal second_connection.object_id
      end

      it "closes first connection when a second is created" do
        first_connection = make_connection(state)
        first_connection.expects(:close)

        make_connection(state.merge(:port => 9000))
      end

      it "logs a debug message a second connection is created" do
        make_connection(state)
        make_connection(state.merge(:port => 9000))

        logged_output.string.lines.count { |l|
          l =~ debug_line_with("[SSH] shutting previous connection ")
        }.must_equal 1
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

describe Kitchen::Transport::Ssh::Connection do

  include Net::SSH::Test
  # sadly, Net:SSH::Test includes a #connection method so we'll alias this one
  # before redefining it
  alias_method :net_ssh_connection, :connection

  let(:logged_output)   { StringIO.new }
  let(:logger)          { Logger.new(logged_output) }
  let(:conn)            { net_ssh_connection }

  let(:options) do
    {
      :logger => logger,
      :username => "me",
      :hostname => "foo",
      :port => 22,
      :max_ssh_sessions => 9
    }
  end

  let(:connection) do
    Kitchen::Transport::Ssh::Connection.new(options)
  end

  before do
    repatch_io
    logger.level = Logger::DEBUG
    Net::SSH.stubs(:start).returns(conn)
  end

  after do
    depatch_io
  end

  describe "establishing a connection" do

    [
      Errno::EACCES, Errno::EADDRINUSE, Errno::ECONNREFUSED, Errno::ETIMEDOUT,
      Errno::ECONNRESET, Errno::ENETUNREACH, Errno::EHOSTUNREACH,
      Net::SSH::Disconnect, Net::SSH::AuthenticationFailed, Net::SSH::ConnectionTimeout,
      Timeout::Error
    ].each do |klass|
      describe "raising #{klass}" do

        before do
          Net::SSH.stubs(:start).raises(klass)
          options[:connection_retries] = 3
          options[:connection_retry_sleep] = 7
          connection.stubs(:sleep)
        end

        it "raises an SshFailed exception" do
          e = proc {
            connection.execute("nope")
          }.must_raise Kitchen::Transport::SshFailed
          e.message.must_match regexify("SSH session could not be established")
        end

        it "attempts to connect :connection_retries times" do
          begin
            connection.execute("nope")
          rescue # rubocop:disable Lint/HandleExceptions
            # the raise is not what is being tested here, rather its side-effect
          end

          logged_output.string.lines.count { |l|
            l =~ debug_line("[SSH] opening connection to me@foo<{:port=>22}>")
          }.must_equal 3
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

          logged_output.string.lines.count { |l|
            l =~ info_line_with(
              "[SSH] connection failed, retrying in 7 seconds")
          }.must_equal 2
        end

        it "logs the last retry failures on warn" do
          begin
            connection.execute("nope")
          rescue # rubocop:disable Lint/HandleExceptions
            # the raise is not what is being tested here, rather its side-effect
          end

          logged_output.string.lines.count { |l|
            l =~ warn_line_with("[SSH] connection failed, terminating ")
          }.must_equal 1
        end
      end
    end
  end

  describe "#close" do

    before do
      story do |script|
        channel = script.opens_channel
        channel.sends_request_pty
        channel.sends_exec("doit")
        channel.gets_data("ok\n")
        channel.gets_exit_status(0)
        channel.gets_close
        channel.sends_close
      end
    end

    it "logger displays closing connection on debug" do
      conn.expects(:close)

      assert_scripted do
        connection.execute("doit")
        connection.close
      end

      logged_output.string.must_match debug_line(
        "[SSH] closing connection to me@foo<{:port=>22}>"
      )
    end

    it "only closes the connection once for multiple calls" do
      conn.expects(:close).once

      assert_scripted do
        connection.execute("doit")
        connection.close
        connection.close
        connection.close
      end
    end
  end

  describe "#execute" do

    describe "for a successful command" do

      before do
        story do |script|
          channel = script.opens_channel
          channel.sends_request_pty
          channel.sends_exec("doit")
          channel.gets_data("ok\n")
          channel.gets_extended_data("some stderr stuffs\n")
          channel.gets_exit_status(0)
          channel.gets_close
          channel.sends_close
        end
      end

      it "logger displays command on debug" do
        assert_scripted { connection.execute("doit") }

        logged_output.string.must_match debug_line(
          "[SSH] me@foo<{:port=>22}> (doit)"
        )
      end

      it "logger displays establishing connection on debug" do
        assert_scripted { connection.execute("doit") }

        logged_output.string.must_match debug_line(
          "[SSH] opening connection to me@foo<{:port=>22}>"
        )
      end

      it "logger captures stdout" do
        assert_scripted { connection.execute("doit") }

        logged_output.string.must_match(/^ok$/)
      end

      it "logger captures stderr" do
        assert_scripted { connection.execute("doit") }

        logged_output.string.must_match(/^some stderr stuffs$/)
      end
    end

    describe "for a failed command" do

      before do
        story do |script|
          channel = script.opens_channel
          channel.sends_request_pty
          channel.sends_exec("doit")
          channel.gets_data("nope\n")
          channel.gets_extended_data("youdead\n")
          channel.gets_exit_status(42)
          channel.gets_close
          channel.sends_close
        end
      end

      it "logger displays command on debug" do
        begin
          assert_scripted { connection.execute("doit") }
        rescue # rubocop:disable Lint/HandleExceptions
          # the raise is not what is being tested here, rather its side-effect
        end

        logged_output.string.must_match debug_line(
          "[SSH] me@foo<{:port=>22}> (doit)"
        )
      end

      it "logger displays establishing connection on debug" do
        begin
          assert_scripted { connection.execute("doit") }
        rescue # rubocop:disable Lint/HandleExceptions
          # the raise is not what is being tested here, rather its side-effect
        end

        logged_output.string.must_match debug_line(
          "[SSH] opening connection to me@foo<{:port=>22}>"
        )
      end

      it "logger captures stdout" do
        begin
          assert_scripted { connection.execute("doit") }
        rescue # rubocop:disable Lint/HandleExceptions
          # the raise is not what is being tested here, rather its side-effect
        end

        logged_output.string.must_match(/^nope$/)
      end

      it "logger captures stderr" do
        begin
          assert_scripted { connection.execute("doit") }
        rescue # rubocop:disable Lint/HandleExceptions
          # the raise is not what is being tested here, rather its side-effect
        end

        logged_output.string.must_match(/^youdead$/)
      end

      it "raises an SshFailed exception" do
        err = proc {
          connection.execute("doit")
        }.must_raise Kitchen::Transport::SshFailed
        err.message.must_equal "SSH exited (42) for command: [doit]"
      end

      it "returns the exit code with an SshFailed exception" do
        begin
          connection.execute("doit")
        rescue Kitchen::Transport::SshFailed => e
          e.exit_code.must_equal 42
        end
      end
    end

    describe "for an interrupted command" do

      let(:conn) { mock("session") }

      before do
        Net::SSH.stubs(:start).returns(conn)
      end

      it "raises SshFailed when an SSH exception is raised" do
        conn.stubs(:open_channel).raises(Net::SSH::Exception)

        e = proc {
          connection.execute("nope")
        }.must_raise Kitchen::Transport::SshFailed
        e.message.must_match regexify("SSH command failed")
      end
    end

    describe "for a nil command" do

      it "does not log on debug" do
        connection.execute(nil)

        logged_output.string.must_equal ""
      end
    end
  end

  describe "#login_command" do

    let(:login_command) { connection.login_command }
    let(:args)          { login_command.arguments.join(" ") }

    it "returns a LoginCommand" do
      login_command.must_be_instance_of Kitchen::LoginCommand
    end

    it "is an SSH command" do
      login_command.command.must_equal "ssh"
      args.must_match %r{ me@foo$}
    end

    it "sets the UserKnownHostsFile option" do
      args.must_match regexify("-o UserKnownHostsFile=/dev/null ")
    end

    it "sets the StrictHostKeyChecking option" do
      args.must_match regexify(" -o StrictHostKeyChecking=no ")
    end

    it "won't set IdentitiesOnly option by default" do
      args.wont_match regexify(" -o IdentitiesOnly=")
    end

    it "sets the IdentiesOnly option if :keys option is given" do
      options[:keys] = ["yep"]

      args.must_match regexify(" -o IdentitiesOnly=yes ")
    end

    it "sets the LogLevel option to VERBOSE if logger is set to debug" do
      logger.level = ::Logger::DEBUG
      options[:logger] = logger

      args.must_match regexify(" -o LogLevel=VERBOSE ")
    end

    it "sets the LogLevel option to ERROR if logger is not set to debug" do
      logger.level = ::Logger::INFO
      options[:logger] = logger

      args.must_match regexify(" -o LogLevel=ERROR ")
    end

    it "won't set the ForwardAgent option by default" do
      args.wont_match regexify(" -o ForwardAgent=")
    end

    it "sets the ForwardAgent option to yes if truthy" do
      options[:forward_agent] = "yep"

      args.must_match regexify(" -o ForwardAgent=yes")
    end

    it "sets the ForwardAgent option to no if falsey" do
      options[:forward_agent] = false

      args.must_match regexify(" -o ForwardAgent=no")
    end

    it "won't add any SSH keys by default" do
      args.wont_match regexify(" -i ")
    end

    it "sets SSH keys options if given" do
      options[:keys] = %w[one two]

      args.must_match regexify(" -i one ")
      args.must_match regexify(" -i two ")
    end

    it "sets the port option to 22 by default" do
      args.must_match regexify(" -p 22 ")
    end

    it "sets the port option" do
      options[:port] = 1234

      args.must_match regexify(" -p 1234 ")
    end
  end

  describe "#upload" do

    describe "for a file" do

      let(:content) { "a" * 1234 }

      let(:src) do
        file = Tempfile.new("file")
        file.write("a" * 1234)
        file.close
        FileUtils.chmod(0755, file.path)
        file
      end

      before do
        expect_scp_session("-t /tmp/remote") do |channel|
          file_mode = running_tests_on_windows? ? 0644 : 0755
          channel.gets_data("\0")
          channel.sends_data("C#{padded_octal_string(file_mode)} 1234 #{File.basename(src.path)}\n")
          channel.gets_data("\0")
          channel.sends_data("a" * 1234)
          channel.sends_data("\0")
          channel.gets_data("\0")
        end
      end

      after do
        src.unlink
      end

      it "uploads a file to remote over scp" do
        assert_scripted do
          connection.upload(src.path, "/tmp/remote")
        end
      end
    end

    describe "for a path" do
      before do
        @dir = Dir.mktmpdir("local")

        # Since File.chmod is a NOOP on Windows
        @tmp_dir_mode = running_tests_on_windows? ? 0755 : 0700
        @alpha_file_mode = running_tests_on_windows? ? 0644 : 0644
        @beta_file_mode = running_tests_on_windows? ? 0444 : 0555

        FileUtils.chmod(0700, @dir)
        File.open("#{@dir}/alpha", "wb") { |f| f.write("alpha-contents\n") }
        FileUtils.chmod(0644, "#{@dir}/alpha")
        FileUtils.mkdir_p("#{@dir}/subdir")
        FileUtils.chmod(0755, "#{@dir}/subdir")
        File.open("#{@dir}/subdir/beta", "wb") { |f| f.write("beta-contents\n") }
        FileUtils.chmod(0555, "#{@dir}/subdir/beta")
        File.open("#{@dir}/zulu", "wb") { |f| f.write("zulu-contents\n") }
        FileUtils.chmod(0444, "#{@dir}/zulu")

        expect_scp_session("-t -r /tmp/remote") do |channel|
          channel.gets_data("\0")
          channel.sends_data("D#{padded_octal_string(@tmp_dir_mode)} 0 #{File.basename(@dir)}\n")
          channel.gets_data("\0")
          channel.sends_data("C#{padded_octal_string(@alpha_file_mode)} 15 alpha\n")
          channel.gets_data("\0")
          channel.sends_data("alpha-contents\n")
          channel.sends_data("\0")
          channel.gets_data("\0")
          channel.sends_data("D0755 0 subdir\n")
          channel.gets_data("\0")
          channel.sends_data("C#{padded_octal_string(@beta_file_mode)} 14 beta\n")
          channel.gets_data("\0")
          channel.sends_data("beta-contents\n")
          channel.sends_data("\0")
          channel.gets_data("\0")
          channel.sends_data("E\n")
          channel.gets_data("\0")
          channel.sends_data("C0444 14 zulu\n")
          channel.gets_data("\0")
          channel.sends_data("zulu-contents\n")
          channel.sends_data("\0")
          channel.gets_data("\0")
          channel.sends_data("E\n")
          channel.gets_data("\0")
        end
      end

      after do
        FileUtils.remove_entry_secure(@dir)
      end

      it "uploads a file to remote over scp" do
        with_sorted_dir_entries do
          assert_scripted { connection.upload(@dir, "/tmp/remote") }
        end
      end
    end

    describe "for a failed upload" do

      let(:conn) { mock("session") }

      before do
        Net::SSH.stubs(:start).returns(conn)
      end

      it "raises SshFailed when an SSH exception is raised" do
        conn.stubs(:scp).raises(Net::SSH::Exception)

        e = proc {
          connection.upload("nope", "fail")
        }.must_raise Kitchen::Transport::SshFailed
        e.message.must_match regexify("SCP upload failed")
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
        Net::SSH.stubs(:start).raises(Errno::ECONNREFUSED)
      end

      it "attempts to connect :max_wait_until_ready / 3 times if failing" do
        begin
          connection.wait_until_ready
        rescue # rubocop:disable Lint/HandleExceptions
          # the raise is not what is being tested here, rather its side-effect
        end

        logged_output.string.lines.count { |l|
          l =~ info_line_with(
            "Waiting for SSH service on foo:22, retrying in 3 seconds")
        }.must_equal((300 / 3) - 1)
        logged_output.string.lines.count { |l|
          l =~ debug_line_with("[SSH] connection failed ")
        }.must_equal((300 / 3) - 1)
        logged_output.string.lines.count { |l|
          l =~ warn_line_with("[SSH] connection failed, terminating ")
        }.must_equal 1
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

      before do
        story do |script|
          channel = script.opens_channel
          channel.sends_request_pty
          channel.sends_exec("echo '[SSH] Established'")
          channel.gets_data("[SSH] Established\n")
          channel.gets_exit_status(0)
          channel.gets_close
          channel.sends_close
        end
      end

      it "executes an ping command string to ensure working" do
        assert_scripted { connection.wait_until_ready }
      end

      it "logger captures stdout" do
        assert_scripted { connection.wait_until_ready }

        logged_output.string.must_match(/^\[SSH\] Established$/)
      end
    end
  end

  def expect_scp_session(args)
    story do |script|
      channel = script.opens_channel
      channel.sends_exec("scp #{args}")
      yield channel if block_given?
      channel.sends_eof
      channel.gets_exit_status(0)
      channel.gets_eof
      channel.gets_close
      channel.sends_close
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

  def regexify(string)
    Regexp.new(Regexp.escape(string))
  end

  def warn_line_with(msg)
    %r{^W, .* : #{Regexp.escape(msg)}}
  end
end
