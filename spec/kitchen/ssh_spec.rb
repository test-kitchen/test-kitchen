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

require "kitchen/ssh"
require "tmpdir"
require "net/ssh/test"

describe Kitchen::SSH do
  include Net::SSH::Test

  let(:logged_output) { StringIO.new }
  let(:logger)        { Logger.new(logged_output) }
  let(:opts)          { {} }
  let(:ssh)           { Kitchen::SSH.new("foo", "me", opts) }
  let(:conn)          { Net::SSH::Test::Extensions::IO.with_test_extension { connection } }

  before do
    logger.level = Logger::DEBUG
    opts[:logger] = logger
    Net::SSH.stubs(:start).returns(conn)
  end

  describe "establishing a connection" do
    [
      Errno::EACCES, Errno::EADDRINUSE, Errno::ECONNREFUSED,
      Errno::ECONNRESET, Errno::ENETUNREACH, Errno::EHOSTUNREACH,
      Net::SSH::Disconnect, Net::SSH::AuthenticationFailed, Net::SSH::ConnectionTimeout
    ].each do |klass|
      describe "raising #{klass}" do
        before do
          Net::SSH.stubs(:start).raises(klass)
          opts[:ssh_retries] = 3
          ssh.stubs(:sleep)
        end

        it "reraises the #{klass} exception" do
          _ { ssh.exec("nope") }.must_raise klass
        end

        it "attempts to connect ':ssh_retries' times" do
          begin
            ssh.exec("nope")
          rescue # rubocop:disable Lint/HandleExceptions
          end

          _(logged_output.string.lines.count do |l|
            l =~ debug_line("[SSH] opening connection to me@foo:22<{:ssh_retries=>3}>")
          end).must_equal opts[:ssh_retries]
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

          _(logged_output.string.lines.count do |l|
            l =~ info_line_with("[SSH] connection failed, retrying ")
          end).must_equal 2
        end

        it "logs the last retry failures on warn" do
          begin
            ssh.exec("nope")
          rescue # rubocop:disable Lint/HandleExceptions
          end

          _(logged_output.string.lines.count do |l|
            l =~ warn_line_with("[SSH] connection failed, terminating ")
          end).must_equal 1
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

        _(logged_output.string).must_match debug_line(
          "[SSH] me@foo:22<{}> (doit)"
        )
      end

      it "logger displays establishing connection on debug" do
        assert_scripted { ssh.exec("doit") }

        _(logged_output.string).must_match debug_line(
          "[SSH] opening connection to me@foo:22<{}>"
        )
      end

      it "logger captures stdout" do
        assert_scripted { ssh.exec("doit") }

        _(logged_output.string).must_match(/^ok$/)
      end

      it "logger captures stderr" do
        assert_scripted { ssh.exec("doit") }

        _(logged_output.string).must_match(/^some stderr stuffs$/)
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

        _(logged_output.string).must_match debug_line(
          "[SSH] me@foo:22<{}> (doit)"
        )
      end

      it "logger displays establishing connection on debug" do
        begin
          assert_scripted { ssh.exec("doit") }
        rescue # rubocop:disable Lint/HandleExceptions
        end

        _(logged_output.string).must_match debug_line(
          "[SSH] opening connection to me@foo:22<{}>"
        )
      end

      it "logger captures stdout" do
        begin
          assert_scripted { ssh.exec("doit") }
        rescue # rubocop:disable Lint/HandleExceptions
        end

        _(logged_output.string).must_match(/^nope$/)
      end

      it "logger captures stderr" do
        begin
          assert_scripted { ssh.exec("doit") }
        rescue # rubocop:disable Lint/HandleExceptions
        end

        _(logged_output.string).must_match(/^youdead$/)
      end

      it "raises an SSHFailed exception" do
        err = _ { assert_scripted { ssh.exec("doit") } }.must_raise Kitchen::SSHFailed
        _(err.message).must_equal "SSH exited (42) for command: [doit]"
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
        ssh.upload!(src.path, "/tmp/remote")
      end
    end

    it "logs upload progress to debug" do
      assert_scripted do
        ssh.upload!(src.path, "/tmp/remote")
      end

      _(logged_output.string)
        .must_match debug_line("[SSH] opening connection to me@foo:22<{}>")

      _(logged_output.string)
        .must_match debug_line("Uploaded #{src.path} (1234 bytes)")
    end
  end

  describe "#upload_path!" do
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
        assert_scripted { ssh.upload_path!(@dir, "/tmp/remote") }
      end
    end

    it "logs upload progress to debug" do
      remote_base = "#{Dir.tmpdir}/#{File.basename(@dir)}"

      with_sorted_dir_entries do
        assert_scripted { ssh.upload_path!(@dir, "/tmp/remote") }
      end

      _(logged_output.string).must_match debug_line(
        "[SSH] opening connection to me@foo:22<{}>"
      )
      _(logged_output.string).must_match debug_line(
        "Uploaded #{remote_base}/alpha (15 bytes)"
      )
      _(logged_output.string).must_match debug_line(
        "Uploaded #{remote_base}/subdir/beta (14 bytes)"
      )
      _(logged_output.string).must_match debug_line(
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

      _(logged_output.string).must_match debug_line(
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

      Net::SSH::Test::Extensions::IO.with_test_extension do
        Kitchen::SSH.new("foo", "me", opts) do |ssh|
          ssh.exec("doit")
        end
      end
    end
  end

  describe "#login_command" do
    let(:login_command) { ssh.login_command }
    let(:args)          { login_command.arguments.join(" ") }

    it "returns a LoginCommand" do
      _(login_command).must_be_instance_of Kitchen::LoginCommand
    end

    it "is an SSH command" do
      _(login_command.command).must_equal "ssh"
      _(args).must_match(/ me@foo$/)
    end

    it "sets the UserKnownHostsFile option" do
      _(args).must_match regexify("-o UserKnownHostsFile=/dev/null ")
    end

    it "sets the StrictHostKeyChecking option" do
      _(args).must_match regexify(" -o StrictHostKeyChecking=no ")
    end

    it "won't set IdentitiesOnly option by default" do
      _(args).wont_match regexify(" -o IdentitiesOnly=")
    end

    it "sets the IdentiesOnly option if :keys option is given" do
      opts[:keys] = ["yep"]

      _(args).must_match regexify(" -o IdentitiesOnly=yes ")
    end

    it "sets the LogLevel option to VERBOSE if logger is set to debug" do
      logger.level = ::Logger::DEBUG
      opts[:logger] = logger

      _(args).must_match regexify(" -o LogLevel=VERBOSE ")
    end

    it "sets the LogLevel option to ERROR if logger is not set to debug" do
      logger.level = ::Logger::INFO
      opts[:logger] = logger

      _(args).must_match regexify(" -o LogLevel=ERROR ")
    end

    it "won't set the ForwardAgent option by default" do
      _(args).wont_match regexify(" -o ForwardAgent=")
    end

    it "sets the ForwardAgent option to yes if truthy" do
      opts[:forward_agent] = "yep"

      _(args).must_match regexify(" -o ForwardAgent=yes")
    end

    it "sets the ForwardAgent option to no if falsey" do
      opts[:forward_agent] = false

      _(args).must_match regexify(" -o ForwardAgent=no")
    end

    it "won't add any SSH keys by default" do
      _(args).wont_match regexify(" -i ")
    end

    it "sets SSH keys options if given" do
      opts[:keys] = %w{one two}

      _(args).must_match regexify(" -i one ")
      _(args).must_match regexify(" -i two ")
    end

    it "sets the port option to 22 by default" do
      _(args).must_match regexify(" -p 22 ")
    end

    it "sets the port option" do
      opts[:port] = 1234

      _(args).must_match regexify(" -p 1234 ")
    end
  end

  describe "#test_ssh" do
    let(:tcp_socket) { stub(select_for_read?: true, close: true) }

    before { ssh.stubs(:sleep) }

    it "returns a truthy value" do
      TCPSocket.stubs(:new).returns(tcp_socket)

      Net::SSH::Test::Extensions::IO.with_test_extension do
        result = ssh.send(:test_ssh)
        _(result).wont_equal nil
        _(result).wont_equal false
      end
    end

    it "closes socket when finished" do
      TCPSocket.stubs(:new).returns(tcp_socket)
      tcp_socket.expects(:close)

      Net::SSH::Test::Extensions::IO.with_test_extension { ssh.send(:test_ssh) }
    end

    [
      SocketError, Errno::ECONNREFUSED, Errno::EHOSTUNREACH,
      Errno::ENETUNREACH, IOError
    ].each do |klass|
      describe "when #{klass} is raised" do
        before { TCPSocket.stubs(:new).raises(klass) }

        it "returns false" do
          _(ssh.send(:test_ssh)).must_equal false
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

          _(ssh.send(:test_ssh)).must_equal false
        end
      end
    end
  end

  describe "#wait" do
    let(:not_ready) do
      stub(close: true)
    end

    let(:ready) do
      stub(close: true)
    end

    it "logs to info for each retry" do
      TCPSocket.stubs(:new).returns(not_ready, not_ready, ready)
      # IO.select returns nil if it his the 5 second timeout
      # http://ruby-doc.org/core-2.6.3/IO.html#method-c-select
      IO.stubs(:select).with([not_ready], nil, nil, 5).returns(nil)
      IO.stubs(:select).with([not_ready], nil, nil, 5).returns(nil)
      IO.stubs(:select).with([ready], nil, nil, 5).returns([[ready], [], []])
      ssh.wait

      _(logged_output.string.lines.count do |l|
        l =~ info_line_with("Waiting for foo:22...")
      end).must_equal 2
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
    /^D, .* : #{Regexp.escape(msg)}$/
  end

  def debug_line_with(msg)
    /^D, .* : #{Regexp.escape(msg)}/
  end

  def info_line_with(msg)
    /^I, .* : #{Regexp.escape(msg)}/
  end

  def warn_line_with(msg)
    /^W, .* : #{Regexp.escape(msg)}/
  end
end
