# -*- encoding: utf-8 -*-
#
# Author:: SAWANOBORI Yukihiko (<sawanoboriyu@higanworks.com>)
#
# Copyright (C) 2015, HiganWorks LLC
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

require "logger"
require "stringio"

require "kitchen/verifier/shell"
require "kitchen/transport/ssh"

describe Kitchen::Verifier::Shell do
  let(:logged_output) { StringIO.new }
  let(:logger)        { Logger.new(logged_output) }
  let(:platform)      { stub(os_type: nil, shell_type: nil, name: "coolbeans") }
  let(:suite)         { stub(name: "fries") }
  let(:state)         { Hash.new }

  let(:config) do
    { test_base_path: "/basist", kitchen_root: "/rooty" }
  end

  let(:instance) do
    stub(
      name: [suite.name, platform.name].join("-"),
      to_str: "instance",
      logger: logger,
      suite: suite,
      platform: platform
    )
  end

  let(:verifier) do
    Kitchen::Verifier::Shell.new(config).finalize_config!(instance)
  end

  it "verifier api_version is 1" do
    verifier.diagnose_plugin[:api_version].must_equal 1
  end

  it "plugin_version is set to Kitchen::VERSION" do
    verifier.diagnose_plugin[:version].must_equal Kitchen::VERSION
  end

  describe "configuration" do
    it "sets :sleep to 0 by default" do
      verifier[:sleep].must_equal 0
    end

    it "sets :command to 'true' by default" do
      verifier[:command].must_equal "true"
    end

    it "sets :remote_exec to 'false' by default" do
      verifier[:remote_exec].must_equal false
    end

    it "sets :sudo to 'false' by default" do
      verifier[:sudo].must_equal false
    end

    it "sets :live_stream to stdout by default" do
      verifier[:live_stream].must_equal $stdout
    end
  end

  describe "#call" do
    it "states are set to environment" do
      state[:hostname] = "testhost"
      state[:server_id] = "i-xxxxxx"
      state[:port] = 22

      verifier.call(state)
      new_env = verifier.send :merged_environment
      new_env["KITCHEN_HOSTNAME"].must_equal "testhost"
      new_env["KITCHEN_SERVER_ID"].must_equal "i-xxxxxx"
      new_env["KITCHEN_PORT"].must_equal "22"
      new_env["KITCHEN_INSTANCE"].must_equal "fries-coolbeans"
      new_env["KITCHEN_PLATFORM"].must_equal "coolbeans"
      new_env["KITCHEN_SUITE"].must_equal "fries"
    end

    it "calls sleep if :sleep value is greater than 0" do
      config[:sleep] = 3
      verifier.expects(:sleep).with(1).returns(true).at_least(3)

      verifier.call(state)
    end

    describe "#shell_out" do
      it "includes all environment sources" do
        config[:environment] = { FOO: "bar" }
        config[:shellout_opts] = { environment: { FOOBAR: "foobar" } }

        verifier.call(state)
        new_env = verifier.send(:shellout_opts)[:environment]
        new_env["KITCHEN_INSTANCE"].must_equal "fries-coolbeans"
        new_env[:FOO].must_equal "bar"
        new_env[:FOOBAR].must_equal "foobar"

        command = verifier.send :build_command, verifier[:command]
        command.must_match(/^TEST_KITCHEN="1";/)
      end

      describe "#build_command" do
        it "is called when running locally" do
          verifier.expects(:build_command).with(verifier[:command]).returns(verifier[:command])
          verifier.call(state)
        end

        it "calls sudo when configured" do
          config[:sudo] = true
          command = verifier.send(:build_command, verifier[:command]).tr("\n", ";")
          command.must_match(/sudo -E.+#{verifier[:command]}/)
        end

        it "honors sudo_command when configured" do
          config[:sudo] = true
          config[:sudo_command] = "sudo -i"
          command = verifier.send(:build_command, verifier[:command]).tr("\n", ";")
          command.must_match(/sudo -i.+#{verifier[:command]}/)
        end

        it "adds command_prefix when configured" do
          config[:command_prefix] = "env FOO=bar"
          command = verifier.send(:build_command, verifier[:command]).tr("\n", ";")
          command.must_match(/env FOO=bar.+#{verifier[:command]}/)
        end

        it "adds proxy settings when configured" do
          config[:http_proxy] = "http"
          config[:https_proxy] = "https"
          config[:ftp_proxy] = "ftp"
          command = verifier.send(:build_command, verifier[:command])
          command.must_match(/^HTTP_PROXY="http";/)
          command.must_match(/^HTTPS_PROXY="https";/)
          command.must_match(/^FTP_PROXY="ftp";/)
        end
      end

      it "raises ActionFailed if set false to :command" do
        config[:command] = "false"

        proc { verifier.call(state) }.must_raise Kitchen::ActionFailed
      end

      it "logs a converge event to INFO" do
        verifier.call(state)

        logged_output.string.must_match(/^.+ INFO .+ \[Shell\] Verify on .+$/)
      end
    end

    describe "remote_exec" do
      let(:transport) do
        t = mock("transport")
        t.responds_like_instance_of(Kitchen::Transport::Ssh)
        t
      end

      let(:connection) do
        c = mock("transport_connection")
        c.responds_like_instance_of(Kitchen::Transport::Ssh::Connection)
        c
      end

      let(:instance) do
        stub(
          name: [suite.name, platform.name].join("-"),
          to_str: "instance",
          logger: logger,
          platform: platform,
          suite: suite,
          transport: transport
        )
      end

      before do
        transport.stubs(:connection).yields(connection)
        connection.stubs(:execute)
        connection.stubs(:upload)

        config[:remote_exec] = true
      end

      it "uploads common helper files" do
        config[:test_base_path] = Dir.mktmpdir("shell_spec")
        helper_file = "#{config[:test_base_path]}/helpers/foo-helper.sh"

        FileUtils.mkdir_p File.dirname(helper_file)
        File.write helper_file, "foo"

        verifier.create_sandbox
        File.read(File.join(verifier.sandbox_path, "foo-helper.sh")).must_equal "foo"
        FileUtils.rm_rf config[:test_base_path]
      end

      it "uploads suite files" do
        config[:test_base_path] = Dir.mktmpdir("shell_spec")
        suite_file = "#{config[:test_base_path]}/fries/foo-script.sh"

        FileUtils.mkdir_p File.dirname(suite_file)
        File.write suite_file, "foobar"

        verifier.create_sandbox
        File.read(File.join(verifier.sandbox_path, "foo-script.sh")).must_equal "foobar"
        FileUtils.rm_rf config[:test_base_path]
      end

      it "calls #build_command when running remotely" do
        verifier.expects(:build_command).with(verifier[:command]).returns(verifier[:command])
        verifier.call(state)
      end

      it "execute command onto instance." do
        transport.expects(:connection).with(state).yields(connection)
        connection.expects(:execute).with(regexp_matches(/#{verifier[:command]}/))
        verifier.call(state)
      end

      it "changes directory if there are sandbox files" do
        config[:root_path] = "/tmp/verifier"
        config[:test_base_path] = Dir.mktmpdir("shell_spec")
        suite_file = "#{config[:test_base_path]}/fries/foo-script.sh"

        FileUtils.mkdir_p File.dirname(suite_file)
        File.write suite_file, "foobar"

        connection.expects(:execute).with(regexp_matches(/cd #{config[:root_path]}\n/))
        verifier.call(state)
        FileUtils.rm_rf config[:test_base_path]
      end

      it "does not change directory if the sandbox is empty" do
        config[:root_path] = "/tmp/verifier"
        connection.expects(:execute).with(Not(regexp_matches(/cd #{config[:root_path]}\n/)))
        verifier.call(state)
      end

      it "includes all environment sources" do
        config[:environment] = { FOO: 'it\'s "escaped"!' }

        verifier.call(state)
        command = verifier.send :remote_command
        command.must_match(/^TEST_KITCHEN="1";/)
        command.must_match(/^KITCHEN_INSTANCE="fries-coolbeans";/)
        command.must_match(/^FOO="it's \\"escaped\\"!";/)
      end

      it "raises ActionFailed if set false to :command" do
        config[:command] = "false"
        connection.stubs(:execute).raises(Kitchen::Transport::TransportFailed, "'false' exited with code (1)")

        proc { verifier.call(state) }.must_raise Kitchen::ActionFailed
      end

      describe "with a windows remote" do

        let(:platform) { stub(os_type: "windows", shell_type: "powershell", name: "coolbeans") }

        it "ignores the sudo option when set" do
          config[:sudo] = true
          config[:sudo_command] = "sudo"

          connection.expects(:execute).with(Not(regexp_matches(/#{config[:sudo_command]}/)))
          verifier.call(state)
        end

        it "quotes environment properly for powershell" do
          config[:environment] = { FOO: 'it\'s "escaped"!' }

          connection.expects(:execute).with(regexp_matches(/\$env:FOO = "it's ""escaped""!"/))
          verifier.call(state)
        end

      end
    end
  end
end
