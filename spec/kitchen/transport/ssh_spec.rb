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

require "net/ssh/test"

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

      def entries(*args)
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

def depatch_io
  IO.class_exec do
    class << self
      alias_method :select, :select_for_real
    end
  end
end

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

module Net

  module SSH

    module Test

      class Channel

        def sends_request_pty
          pty_data = ["xterm", 80, 24, 640, 480, "\0"]

          script.events << Class.new(Net::SSH::Test::LocalPacket) do
            def types
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

  describe "default_config" do

    it "sets :port to 22 by default" do
      transport[:port].must_equal 22
    end

    it "sets :username to root by default" do
      transport[:username].must_equal "root"
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

      it "sets :keys_only to true if :ssh_key is set in state" do
        state[:ssh_key] = "ssh_key_from_config"
        config[:ssh_key] = false

        klass.expects(:new).with do |hash|
          hash[:keys_only] == true
        end

        make_connection
      end

      it "sets :keys to an array if :ssh_key is set in config" do
        config[:ssh_key] = "ssh_key_from_config"

        klass.expects(:new).with do |hash|
          hash[:keys] == ["ssh_key_from_config"]
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

        logged_output.string.lines.select { |l|
          l =~ debug_line_with("[SSH] reusing existing connection ")
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
          l =~ debug_line_with("[SSH] shutting previous connection ")
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

describe Kitchen::Transport::Ssh::Connection do

  include Net::SSH::Test
  # sadly, Net:SSH::Test includes a #connection method so we'll alias this one
  # before redefining it
  alias_method :net_ssh_connection, :connection

  let(:logged_output)   { StringIO.new }
  let(:logger)          { Logger.new(logged_output) }
  let(:conn)            { net_ssh_connection }

  let(:options) do
    { :logger => logger, :username => "me", :hostname => "foo", :port => 22 }
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
      Errno::EACCES, Errno::EADDRINUSE, Errno::ECONNREFUSED,
      Errno::ECONNRESET, Errno::ENETUNREACH, Errno::EHOSTUNREACH,
      Net::SSH::Disconnect, Net::SSH::AuthenticationFailed, Timeout::Error
    ].each do |klass|
      describe "raising #{klass}" do

        before do
          Net::SSH.stubs(:start).raises(klass)
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
            l =~ debug_line("[SSH] opening connection to me@foo<{:port=>22}>")
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
              "[SSH] connection failed, retrying in 7 seconds")
          }.size.must_equal 2
        end

        it "logs the last retry failures on warn" do
          begin
            connection.execute("nope")
          rescue # rubocop:disable Lint/HandleExceptions
            # the raise is not what is being tested here, rather its side-effect
          end

          logged_output.string.lines.select { |l|
            l =~ warn_line_with("[SSH] connection failed, terminating ")
          }.size.must_equal 1
        end
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
    end
  end

  describe "#login_command" do

    let(:login_command) { connection.login_command }
    let(:cmd)           { login_command.cmd_array.join(" ") }

    it "returns a LoginCommand" do
      login_command.must_be_instance_of Kitchen::LoginCommand
    end

    it "is an SSH command" do
      cmd.must_match %r{^ssh }
      cmd.must_match %r{ me@foo$}
    end

    it "sets the UserKnownHostsFile option" do
      cmd.must_match regexify(" -o UserKnownHostsFile=/dev/null ")
    end

    it "sets the StrictHostKeyChecking option" do
      cmd.must_match regexify(" -o StrictHostKeyChecking=no ")
    end

    it "won't set IdentitiesOnly option by default" do
      cmd.wont_match regexify(" -o IdentitiesOnly=")
    end

    it "sets the IdentiesOnly option if :keys option is given" do
      options[:keys] = ["yep"]

      cmd.must_match regexify(" -o IdentitiesOnly=yes ")
    end

    it "sets the LogLevel option to VERBOSE if logger is set to debug" do
      logger.level = ::Logger::DEBUG
      options[:logger] = logger

      cmd.must_match regexify(" -o LogLevel=VERBOSE ")
    end

    it "sets the LogLevel option to ERROR if logger is not set to debug" do
      logger.level = ::Logger::INFO
      options[:logger] = logger

      cmd.must_match regexify(" -o LogLevel=ERROR ")
    end

    it "won't set the ForwardAgent option by default" do
      cmd.wont_match regexify(" -o ForwardAgent=")
    end

    it "sets the ForwardAgent option to yes if truthy" do
      options[:forward_agent] = "yep"

      cmd.must_match regexify(" -o ForwardAgent=yes")
    end

    it "sets the ForwardAgent option to no if falsey" do
      options[:forward_agent] = false

      cmd.must_match regexify(" -o ForwardAgent=no")
    end

    it "won't add any SSH keys by default" do
      cmd.wont_match regexify(" -i ")
    end

    it "sets SSH keys options if given" do
      options[:keys] = %w[one two]

      cmd.must_match regexify(" -i one ")
      cmd.must_match regexify(" -i two ")
    end

    it "sets the port option to 22 by default" do
      cmd.must_match regexify(" -p 22 ")
    end

    it "sets the port option" do
      options[:port] = 1234

      cmd.must_match regexify(" -p 1234 ")
    end
  end

  describe "#shutdown" do

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
        connection.shutdown
      end

      logged_output.string.must_match debug_line(
        "[SSH] closing connection to me@foo<{:port=>22}>"
      )
    end

    it "only closes the connection once for multiple calls" do
      conn.expects(:close).once

      assert_scripted do
        connection.execute("doit")
        connection.shutdown
        connection.shutdown
        connection.shutdown
      end
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
          channel.gets_data("\0")
          channel.sends_data("C0755 1234 #{File.basename(src.path)}\n")
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

      it "logs upload progress to debug" do
        assert_scripted do
          connection.upload(src.path, "/tmp/remote")
        end

        logged_output.string.must_match debug_line(
          "[SSH] opening connection to me@foo<{:port=>22}>"
        )
        logged_output.string.must_match debug_line(
          "Uploaded #{src.path} (1234 bytes)"
        )
      end
    end

    describe "for a path" do
      before do
        @dir = Dir.mktmpdir("local")
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
          channel.sends_data("D0700 0 #{File.basename(@dir)}\n")
          channel.gets_data("\0")
          channel.sends_data("C0644 15 alpha\n")
          channel.gets_data("\0")
          channel.sends_data("alpha-contents\n")
          channel.sends_data("\0")
          channel.gets_data("\0")
          channel.sends_data("D0755 0 subdir\n")
          channel.gets_data("\0")
          channel.sends_data("C0555 14 beta\n")
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

      it "logs upload progress to debug" do
        with_sorted_dir_entries do
          assert_scripted { connection.upload(@dir, "/tmp/remote") }
        end

        logged_output.string.must_match debug_line(
          "[SSH] opening connection to me@foo<{:port=>22}>"
        )
        logged_output.string.must_match debug_line(
          "Uploaded #{@dir}/alpha (15 bytes)"
        )
        logged_output.string.must_match debug_line(
          "Uploaded #{@dir}/subdir/beta (14 bytes)"
        )
        logged_output.string.must_match debug_line(
          "Uploaded #{@dir}/zulu (14 bytes)"
        )
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

        logged_output.string.lines.select { |l|
          l =~ info_line_with(
            "Waiting for SSH service on foo:22, retrying in 3 seconds")
        }.size.must_equal((300 / 3) - 1)
        logged_output.string.lines.select { |l|
          l =~ debug_line_with("[SSH] connection failed ")
        }.size.must_equal((300 / 3) - 1)
        logged_output.string.lines.select { |l|
          l =~ warn_line_with("[SSH] connection failed, terminating ")
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

      before do
        story do |script|
          channel = script.opens_channel
          channel.sends_request_pty
          channel.sends_exec("")
          channel.gets_exit_status(0)
          channel.gets_close
          channel.sends_close
        end
      end

      it "executes an empty command string to ensure working" do
        assert_scripted { connection.wait_until_ready }
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
