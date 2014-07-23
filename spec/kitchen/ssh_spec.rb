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

require "net/ssh/test"

require "kitchen/ssh"

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

describe Kitchen::SSH do

  include Net::SSH::Test

  let(:logged_output) { StringIO.new }
  let(:logger)        { Logger.new(logged_output) }
  let(:opts)          { Hash.new }
  let(:ssh)           { Kitchen::SSH.new("foo", "me", opts) }
  let(:conn)          { connection }

  before do
    repatch_io
    logger.level = Logger::DEBUG
    opts[:logger] = logger
    Net::SSH.stubs(:start).returns(conn)
  end

  after do
    depatch_io
  end

  describe "establishing a connection" do

    [
      Errno::EACCES, Errno::EADDRINUSE, Errno::ECONNREFUSED,
      Errno::ECONNRESET, Errno::ENETUNREACH, Errno::EHOSTUNREACH,
      Net::SSH::Disconnect
    ].each do |klass|
      describe "raising #{klass}" do

        before do
          Net::SSH.stubs(:start).raises(klass)
          ssh.stubs(:sleep)
        end

        it "reraises the #{klass} exception" do
          proc { ssh.exec("nope") }.must_raise klass
        end

        it "attempts to connect 3 times" do
          begin
            ssh.exec("nope")
          rescue # rubocop:disable Lint/HandleExceptions
          end

          logged_output.string.lines.select { |l|
            l =~ debug_line("[SSH] opening connection to me@foo:22<{}>")
          }.size.must_equal 3
        end

        it "sleeps for 1 second between retries" do
          ssh.unstub(:sleep)
          ssh.expects(:sleep).with(1).twice

          begin
            ssh.exec("nope")
          rescue # rubocop:disable Lint/HandleExceptions
          end
        end

        it "logs the first 2 retry failures on info" do
          begin
            ssh.exec("nope")
          rescue # rubocop:disable Lint/HandleExceptions
          end

          logged_output.string.lines.select { |l|
            l =~ info_line_with("[SSH] connection failed, retrying ")
          }.size.must_equal 2
        end

        it "logs the last retry failures on warn" do
          begin
            ssh.exec("nope")
          rescue # rubocop:disable Lint/HandleExceptions
          end

          logged_output.string.lines.select { |l|
            l =~ warn_line_with("[SSH] connection failed, terminating ")
          }.size.must_equal 1
        end
      end
    end
  end

  describe "#exec" do

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
        assert_scripted { ssh.exec("doit") }

        logged_output.string.must_match debug_line(
          "[SSH] me@foo:22<{}> (doit)"
        )
      end

      it "logger displays establishing connection on debug" do
        assert_scripted { ssh.exec("doit") }

        logged_output.string.must_match debug_line(
          "[SSH] opening connection to me@foo:22<{}>"
        )
      end

      it "logger captures stdout" do
        assert_scripted { ssh.exec("doit") }

        logged_output.string.must_match(/^ok$/)
      end

      it "logger captures stderr" do
        assert_scripted { ssh.exec("doit") }

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
          assert_scripted { ssh.exec("doit") }
        rescue # rubocop:disable Lint/HandleExceptions
        end

        logged_output.string.must_match debug_line(
          "[SSH] me@foo:22<{}> (doit)"
        )
      end

      it "logger displays establishing connection on debug" do
        begin
          assert_scripted { ssh.exec("doit") }
        rescue # rubocop:disable Lint/HandleExceptions
        end

        logged_output.string.must_match debug_line(
          "[SSH] opening connection to me@foo:22<{}>"
        )
      end

      it "logger captures stdout" do
        begin
          assert_scripted { ssh.exec("doit") }
        rescue # rubocop:disable Lint/HandleExceptions
        end

        logged_output.string.must_match(/^nope$/)
      end

      it "logger captures stderr" do
        begin
          assert_scripted { ssh.exec("doit") }
        rescue # rubocop:disable Lint/HandleExceptions
        end

        logged_output.string.must_match(/^youdead$/)
      end

      it "raises an SSHFailed exception" do
        err = proc { ssh.exec("doit") }.must_raise Kitchen::SSHFailed
        err.message.must_equal "SSH exited (42) for command: [doit]"
      end
    end
  end

  describe "#upload!" do

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
        ssh.upload!(src.path, "/tmp/remote")
      end
    end

    it "logs upload progress to debug" do
      assert_scripted do
        ssh.upload!(src.path, "/tmp/remote")
      end

      logged_output.string.must_match debug_line(
        "[SSH] opening connection to me@foo:22<{}>"
      )
      logged_output.string.must_match debug_line(
        "Uploaded #{src.path} (1234 bytes)"
      )
    end
  end

  describe "#upload_path!" do

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
        assert_scripted { ssh.upload_path!(@dir, "/tmp/remote") }
      end
    end

    it "logs upload progress to debug" do
      remote_base = "/tmp/#{File.basename(@dir)}"

      with_sorted_dir_entries do
        assert_scripted { ssh.upload_path!(@dir, "/tmp/remote") }
      end

      logged_output.string.must_match debug_line(
        "[SSH] opening connection to me@foo:22<{}>"
      )
      logged_output.string.must_match debug_line(
        "Uploaded #{remote_base}/alpha (15 bytes)"
      )
      logged_output.string.must_match debug_line(
        "Uploaded #{remote_base}/subdir/beta (14 bytes)"
      )
      logged_output.string.must_match debug_line(
        "Uploaded #{remote_base}/zulu (14 bytes)"
      )
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
      conn.expects(:shutdown!)

      assert_scripted do
        ssh.exec("doit")
        ssh.shutdown
      end

      logged_output.string.must_match debug_line(
        "[SSH] closing connection to me@foo:22<{}>"
      )
    end

    it "only closes the connection once for multiple calls" do
      conn.expects(:shutdown!).once

      assert_scripted do
        ssh.exec("doit")
        ssh.shutdown
        ssh.shutdown
        ssh.shutdown
      end
    end
  end

  describe "block form" do

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

    it "shuts down the connection when block closes" do
      conn.expects(:shutdown!)

      Kitchen::SSH.new("foo", "me", opts) do |ssh|
        ssh.exec("doit")
      end
    end
  end

  describe "#login_command" do

    let(:login_command) { ssh.login_command }
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
      opts[:keys] = ["yep"]

      cmd.must_match regexify(" -o IdentitiesOnly=yes ")
    end

    it "sets the LogLevel option to VERBOSE if logger is set to debug" do
      logger.level = ::Logger::DEBUG
      opts[:logger] = logger

      cmd.must_match regexify(" -o LogLevel=VERBOSE ")
    end

    it "sets the LogLevel option to ERROR if logger is not set to debug" do
      logger.level = ::Logger::INFO
      opts[:logger] = logger

      cmd.must_match regexify(" -o LogLevel=ERROR ")
    end

    it "won't set the ForwardAgent option by default" do
      cmd.wont_match regexify(" -o ForwardAgent=")
    end

    it "sets the ForwardAgent option to yes if truthy" do
      opts[:forward_agent] = "yep"

      cmd.must_match regexify(" -o ForwardAgent=yes")
    end

    it "sets the ForwardAgent option to no if falsey" do
      opts[:forward_agent] = false

      cmd.must_match regexify(" -o ForwardAgent=no")
    end

    it "won't add any SSH keys by default" do
      cmd.wont_match regexify(" -i ")
    end

    it "sets SSH keys options if given" do
      opts[:keys] = %w[one two]

      cmd.must_match regexify(" -i one ")
      cmd.must_match regexify(" -i two ")
    end

    it "sets the port option to 22 by default" do
      cmd.must_match regexify(" -p 22 ")
    end

    it "sets the port option" do
      opts[:port] = 1234

      cmd.must_match regexify(" -p 1234 ")
    end
  end

  describe "#test_ssh" do

    let(:tcp_socket) { stub(:select_for_read? => true, :close => true) }

    before { ssh.stubs(:sleep) }

    it "returns a truthy value" do
      TCPSocket.stubs(:new).returns(tcp_socket)

      result = ssh.send(:test_ssh)
      result.wont_equal nil
      result.wont_equal false
    end

    it "closes socket when finished" do
      TCPSocket.stubs(:new).returns(tcp_socket)
      tcp_socket.expects(:close)

      ssh.send(:test_ssh)
    end

    [
      SocketError, Errno::ECONNREFUSED, Errno::EHOSTUNREACH,
      Errno::ENETUNREACH, IOError
    ].each do |klass|
      describe "when #{klass} is raised" do

        before { TCPSocket.stubs(:new).raises(klass) }

        it "returns false" do
          ssh.send(:test_ssh).must_equal false
        end

        it "sleeps for 2 seconds" do
          ssh.expects(:sleep).with(2)

          ssh.send(:test_ssh)
        end
      end
    end

    [
      Errno::EPERM, Errno::ETIMEDOUT
    ].each do |klass|
      describe "when #{klass} is raised" do

        it "returns false when #{klass} is raised" do
          TCPSocket.stubs(:new).raises(klass)

          ssh.send(:test_ssh).must_equal false
        end
      end
    end
  end

  describe "#wait" do

    let(:not_ready) do
      stub(:select_for_read? => false, :idle! => true, :close => true)
    end

    let(:ready) do
      stub(:select_for_read? => true, :close => true)
    end

    it "logs to info for each retry" do
      TCPSocket.stubs(:new).returns(not_ready, not_ready, ready)
      ssh.wait

      logged_output.string.lines.select { |l|
        l =~ info_line_with("Waiting for foo:22...")
      }.size.must_equal 2
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

  def regexify(string)
    Regexp.new(Regexp.escape(string))
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

  def warn_line_with(msg)
    %r{^W, .* : #{Regexp.escape(msg)}}
  end
end
