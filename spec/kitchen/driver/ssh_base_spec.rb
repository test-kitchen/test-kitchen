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

require_relative "../../spec_helper"

require "kitchen"
require "kitchen/transport/ssh"
require "kitchen/verifier/busser"

module Kitchen

  module Driver

    class BackCompat < Kitchen::Driver::SSHBase

      def use_run_remote(state, command)
        connection = Kitchen::SSH.new(*build_ssh_args(state))
        run_remote(command, connection)
      end

      def use_transfer_path(state, locals, remote)
        connection = Kitchen::SSH.new(*build_ssh_args(state))
        transfer_path(locals, remote, connection)
      end
    end

    class SpeedyCompat < Kitchen::Driver::SSHBase
    end

    class DodgyCompat < Kitchen::Driver::SSHBase

      no_parallel_for :converge
    end

    class SlowCompat < Kitchen::Driver::SSHBase

      no_parallel_for :create, :destroy
      no_parallel_for :verify
    end
  end
end

describe Kitchen::Driver::SSHBase do

  let(:logged_output) { StringIO.new }
  let(:logger)        { Logger.new(logged_output) }
  let(:config)        { Hash.new }
  let(:state)         { Hash.new }

  let(:verifier) do
    v = mock("busser")
    v.responds_like_instance_of(Kitchen::Verifier::Busser)
    v.stubs(:install_command).returns("install")
    v.stubs(:init_command).returns("init")
    v.stubs(:prepare_command).returns("prepare")
    v.stubs(:run_command).returns("run")
    v.stubs(:create_sandbox).returns(true)
    v.stubs(:cleanup_sandbox).returns(true)
    v.stubs(:sandbox_path).returns("/tmp/sandbox")
    v.stubs(:[]).with(:root_path).returns("/tmp/verifier")
    v
  end

  let(:provisioner) do
    stub(
      :install_command  => "install",
      :init_command     => "init",
      :prepare_command  => "prepare",
      :run_command      => "run",
      :create_sandbox   => true,
      :cleanup_sandbox  => true,
      :sandbox_path     => "/tmp/sandbox"
    )
  end

  let(:transport) do
    t = mock("transport")
    t.responds_like_instance_of(Kitchen::Transport::Base)
    t
  end

  let(:instance) do
    stub(
      :name         => "coolbeans",
      :logger       => logger,
      :verifier     => verifier,
      :provisioner  => provisioner,
      :transport    => transport,
      :to_str       => "instance"
    )
  end

  let(:driver) do
    Kitchen::Driver::SSHBase.new(config).finalize_config!(instance)
  end

  it "plugin_version is not set" do
    driver.diagnose_plugin[:version].must_equal nil
  end

  describe "configuration" do

    it ":sudo defaults to true" do
      driver[:sudo].must_equal true
    end

    it ":port defaults to 22" do
      driver[:port].must_equal 22
    end
  end

  it "#create raises a ClientError" do
    proc { driver.create(state) }.must_raise Kitchen::ClientError
  end

  it "#destroy raises a ClientError" do
    proc { driver.destroy(state) }.must_raise Kitchen::ClientError
  end

  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
  def self.constructs_an_ssh_connection
    describe "constructs an SSH connection" do

      it "with hostname set from state" do
        transport.expects(:connection).with { |state|
          state[:hostname].must_equal "fizzy"
        }.returns(stub(:login_command => stub))

        cmd
      end

      it "with username set from state" do
        transport.expects(:connection).with { |state|
          state[:username].must_equal "bork"
        }.returns(stub(:login_command => stub))

        cmd
      end

      it "with :ssh_key option set from config" do
        config[:ssh_key] = "wicked"

        transport.expects(:connection).with { |state|
          state[:ssh_key].must_equal "wicked"
        }.returns(stub(:login_command => stub))

        cmd
      end

      it "with :ssh_key option set from state" do
        state[:ssh_key] = "wicked"

        transport.expects(:connection).with { |state|
          state[:ssh_key].must_equal "wicked"
        }.returns(stub(:login_command => stub))

        cmd
      end

      it "with :password option set to falsey by default" do
        transport.expects(:connection).with { |state|
          state[:password].nil?
        }.returns(stub(:login_command => stub))

        cmd
      end

      it "with :password option set if given in config" do
        config[:password] = "psst"

        transport.expects(:connection).with { |state|
          state[:password].must_equal "psst"
        }.returns(stub(:login_command => stub))

        cmd
      end

      it "with :password option set if given in state" do
        state[:password] = "psst"

        transport.expects(:connection).with { |state|
          state[:password].must_equal "psst"
        }.returns(stub(:login_command => stub))

        cmd
      end

      it "with :forward_agent option set to falsey by default" do
        transport.expects(:connection).with { |state|
          state[:forward_agent].nil?
        }.returns(stub(:login_command => stub))

        cmd
      end

      it "with :forward_agent option set if given in config" do
        config[:forward_agent] = "yeah?"

        transport.expects(:connection).with { |state|
          state[:forward_agent].must_equal "yeah?"
        }.returns(stub(:login_command => stub))

        cmd
      end

      it "with :forward_agent option set if given in state" do
        state[:forward_agent] = "yeah?"

        transport.expects(:connection).with { |state|
          state[:forward_agent].must_equal "yeah?"
        }.returns(stub(:login_command => stub))

        cmd
      end

      it "with :port option set to 22 by default" do
        transport.expects(:connection).with { |state|
          state[:port].must_equal 22
        }.returns(stub(:login_command => stub))

        cmd
      end

      it "with :port option set if customized in config" do
        config[:port] = 1234

        transport.expects(:connection).with { |state|
          state[:port].must_equal 1234
        }.returns(stub(:login_command => stub))

        cmd
      end

      it "with :port option set if customized in state" do
        state[:port] = 9999

        transport.expects(:connection).with { |state|
          state[:port].must_equal 9999
        }.returns(stub(:login_command => stub))

        cmd
      end
    end
  end
  # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

  describe "#login_command" do

    let(:cmd) { driver.login_command(state) }

    before do
      state[:hostname] = "fizzy"
      state[:username] = "bork"
    end

    it "returns a LoginCommand" do
      transport.stubs(:connection).returns(stub(:login_command => "command"))

      cmd.must_equal "command"
    end

    constructs_an_ssh_connection
  end

  describe "#converge" do

    let(:cmd)         { driver.converge(state) }
    let(:connection)  { stub(:execute => true, :upload => true) }

    before do
      state[:hostname] = "fizzy"
      state[:username] = "bork"
      provisioner.stubs(:[]).with(:root_path).returns("/rooty")
      FakeFS.activate!
      FileUtils.mkdir_p("/tmp")
      @original_env = ENV.to_hash
      ENV.replace("http_proxy"  => nil, "HTTP_PROXY"  => nil,
                  "https_proxy" => nil, "HTTPS_PROXY" => nil,
                  "no_proxy"    => nil, "NO_PROXY"    => nil)
    end

    after do
      FakeFS.deactivate!
      FakeFS::FileSystem.clear
      ENV.clear
      ENV.replace(@original_env)
    end

    constructs_an_ssh_connection

    it "creates the sandbox" do
      transport.stubs(:connection).yields(connection)
      provisioner.expects(:create_sandbox)

      cmd
    end

    it "ensures that the sandbox is cleaned up" do
      transport.stubs(:connection).raises
      provisioner.expects(:cleanup_sandbox)

      begin
        cmd
      rescue # rubocop:disable Lint/HandleExceptions
      end
    end

    it "invokes the provisioner commands over ssh" do
      transport.stubs(:connection).yields(connection)
      order = sequence("order")
      connection.expects(:execute).with("install").in_sequence(order)
      connection.expects(:execute).with("init").in_sequence(order)
      connection.expects(:execute).with("prepare").in_sequence(order)
      connection.expects(:execute).with("run").in_sequence(order)

      cmd
    end

    it "invokes the #install_command with :http_proxy set in config" do
      config[:http_proxy] = "http://proxy"
      transport.stubs(:connection).yields(connection)
      connection.expects(:execute).with("env http_proxy=http://proxy install")

      cmd
    end

    it "invokes the #install_command with ENV[\"http_proxy\"] set" do
      ENV["http_proxy"] = "http://proxy"
      transport.stubs(:connection).yields(connection)
      if running_tests_on_windows?
        connection.expects(:execute).
          with("env http_proxy=http://proxy HTTP_PROXY=http://proxy install")
      else
        connection.expects(:execute).with("env http_proxy=http://proxy install")
      end
      cmd
    end

    it "invokes the #install_command with ENV[\"http_proxy\"] and ENV[\"no_proxy\"] set" do
      ENV["http_proxy"] = "http://proxy"
      ENV["no_proxy"]   = "http://no"
      transport.stubs(:connection).yields(connection)
      if running_tests_on_windows?
        connection.expects(:execute).
          with("env http_proxy=http://proxy HTTP_PROXY=http://proxy " \
            "no_proxy=http://no NO_PROXY=http://no install")
      else
        connection.expects(:execute).with("env http_proxy=http://proxy " \
          "no_proxy=http://no install")
      end
      cmd
    end

    it "invokes the #install_command with :https_proxy set in config" do
      config[:https_proxy] = "https://proxy"
      transport.stubs(:connection).yields(connection)
      connection.expects(:execute).with("env https_proxy=https://proxy install")

      cmd
    end

    it "invokes the #install_command with ENV[\"https_proxy\"] set" do
      ENV["https_proxy"] = "https://proxy"
      transport.stubs(:connection).yields(connection)
      if running_tests_on_windows?
        connection.expects(:execute).
          with("env https_proxy=https://proxy HTTPS_PROXY=https://proxy install")
      else
        connection.expects(:execute).with("env https_proxy=https://proxy install")
      end
      cmd
    end

    it "invokes the #install_command with ENV[\"https_proxy\"] and ENV[\"no_proxy\"] set" do
      ENV["https_proxy"] = "https://proxy"
      ENV["no_proxy"]    = "https://no"
      transport.stubs(:connection).yields(connection)
      if running_tests_on_windows?
        connection.expects(:execute).
          with("env https_proxy=https://proxy HTTPS_PROXY=https://proxy " \
          "no_proxy=https://no NO_PROXY=https://no install")
      else
        connection.expects(:execute).with("env https_proxy=https://proxy " \
          "no_proxy=https://no install")
      end
      cmd
    end

    it "invokes the #install_command with :http_proxy & :https_proxy set" do
      config[:http_proxy] = "http://proxy"
      config[:https_proxy] = "https://proxy"
      transport.stubs(:connection).yields(connection)
      connection.expects(:execute).with(
        "env http_proxy=http://proxy https_proxy=https://proxy install")

      cmd
    end

    describe "transferring files" do

      before do
        transport.stubs(:connection).yields(connection)
        connection.stubs(:upload)
        FileUtils.mkdir_p "/tmp/sandbox/stuff"
      end

      it "uploads files" do
        connection.expects(:upload).with(["/tmp/sandbox/stuff"], "/rooty")

        cmd
      end

      it "logs to info" do
        cmd

        logged_output.string.
          must_match(/INFO -- : Transferring files to instance$/)
      end

      it "logs to debug" do
        cmd

        logged_output.string.must_match(/DEBUG -- : Transfer complete$/)
      end

      it "raises an ActionFailed on transfer when SshFailed is raised" do
        connection.stubs(:upload).raises(Kitchen::Transport::SshFailed.new("dang"))

        proc { cmd }.must_raise Kitchen::ActionFailed
      end
    end

    it "raises an ActionFailed on execute when SshFailed is raised" do
      transport.stubs(:connection).yields(connection)
      connection.stubs(:execute).raises(Kitchen::Transport::SshFailed.new("dang"))

      proc { cmd }.must_raise Kitchen::ActionFailed
    end
  end

  describe "#setup" do

    let(:cmd)         { driver.setup(state) }
    let(:connection)  { mock }

    before do
      state[:hostname] = "fizzy"
      state[:username] = "bork"
    end

    constructs_an_ssh_connection

    it "invokes the Verifier#install_command over ssh" do
      transport.stubs(:connection).yields(connection)
      connection.expects(:execute).with("install")

      cmd
    end

    it "invokes the Verifier#install_command with :http_proxy set in config" do
      config[:http_proxy] = "http://proxy"
      transport.stubs(:connection).yields(connection)
      connection.expects(:execute).with("env http_proxy=http://proxy install")

      cmd
    end

    it "invokes the Verifier#install_command with :https_proxy set in config" do
      config[:https_proxy] = "https://proxy"
      transport.stubs(:connection).yields(connection)
      connection.expects(:execute).with("env https_proxy=https://proxy install")

      cmd
    end

    it "invokes the Verifier#install_command with :http_proxy & :https_proxy set" do
      config[:http_proxy] = "http://proxy"
      config[:https_proxy] = "https://proxy"
      transport.stubs(:connection).yields(connection)
      connection.expects(:execute).with(
        "env http_proxy=http://proxy https_proxy=https://proxy install")

      cmd
    end

    it "raises an ActionFailed when SshFailed is raised" do
      transport.stubs(:connection).yields(connection)
      connection.stubs(:execute).raises(Kitchen::Transport::SshFailed.new("dang"))

      proc { cmd }.must_raise Kitchen::ActionFailed
    end
  end

  describe "#verify" do

    let(:cmd)         { driver.verify(state) }
    let(:connection)  { stub(:execute => true, :upload => true) }

    before do
      state[:hostname] = "fizzy"
      state[:username] = "bork"
      transport.stubs(:connection).yields(connection)
    end

    constructs_an_ssh_connection

    it "creates the sandbox" do
      verifier.expects(:create_sandbox)

      cmd
    end

    it "ensures that the sandbox is cleanup up" do
      transport.stubs(:connection).raises
      verifier.expects(:cleanup_sandbox)

      begin
        cmd
      rescue # rubocop:disable Lint/HandleExceptions
      end
    end

    it "invokes the verifier commands over the transport" do
      order = sequence("order")
      connection.expects(:execute).with("init").in_sequence(order)
      connection.expects(:execute).with("prepare").in_sequence(order)
      connection.expects(:execute).with("run").in_sequence(order)

      cmd
    end

    %W[init prepare run].each do |phase|
      it "invokes Verifier##{phase}_command over ssh" do
        connection.expects(:execute).with(phase)

        cmd
      end

      it "invokes Verifier##{phase}_command with :http_proxy set in config" do
        config[:http_proxy] = "http://proxy"
        connection.expects(:execute).with("env http_proxy=http://proxy #{phase}")

        cmd
      end

      it "invokes Verifier##{phase}_command with :https_proxy set in config" do
        config[:https_proxy] = "https://proxy"
        connection.expects(:execute).with("env https_proxy=https://proxy #{phase}")

        cmd
      end

      it "invokes Verifier##{phase}_command with :http_proxy & :https_proxy set" do
        config[:http_proxy] = "http://proxy"
        config[:https_proxy] = "https://proxy"
        connection.expects(:execute).with(
          "env http_proxy=http://proxy https_proxy=https://proxy #{phase}")

        cmd
      end
    end

    it "logs to info" do
      cmd

      logged_output.string.
        must_match(/INFO -- : Transferring files to instance$/)
    end

    it "uploads sandbox files" do
      connection.expects(:upload).with([], "/tmp/verifier")

      cmd
    end

    it "logs to debug" do
      cmd

      logged_output.string.must_match(/DEBUG -- : Transfer complete$/)
    end

    it "raises an ActionFailed on transfer when TransportFailed is raised" do
      connection.stubs(:upload).
        raises(Kitchen::Transport::TransportFailed.new("dang"))

      proc { cmd }.must_raise Kitchen::ActionFailed
    end

    it "raises an ActionFailed when SSHFailed is raised" do
      connection.stubs(:execute).raises(Kitchen::Transport::SshFailed.new("dang"))

      proc { cmd }.must_raise Kitchen::ActionFailed
    end
  end

  describe "#ssh" do

    let(:cmd)         { driver.ssh(["host", "user", { :one => "two" }], "go") }
    let(:connection)  { mock }

    it "creates an SSH connection" do
      connection.stubs(:execute)
      transport.expects(:connection).with(
        :hostname => "host",
        :username => "user",
        :port => 22,
        :one => "two"
      ).yields(connection)

      cmd
    end

    it "invokes the command over ssh" do
      transport.expects(:connection).yields(connection)
      connection.expects(:execute).with("go")

      cmd
    end
  end

  describe "#remote_command" do

    let(:cmd)         { driver.remote_command(state, "shipit") }
    let(:connection)  { mock }

    before do
      state[:hostname] = "fizzy"
      state[:username] = "bork"
    end

    it "creates an SSH connection" do
      transport.expects(:connection).with(
        :hostname => "fizzy",
        :username => "bork",
        :port => 22
      )

      cmd
    end

    it "invokes the command over ssh" do
      transport.expects(:connection).yields(connection)
      connection.expects(:execute).with("shipit")

      cmd
    end
  end

  describe "#wait_for_sshd" do

    let(:cmd) do
      driver.send(:wait_for_sshd, "host", "user", :one => "two")
    end

    it "creates an SSH connection with merged options" do
      transport.expects(:connection).with(
        :hostname => "host",
        :username => "user",
        :port => 22,
        :one => "two"
      ).returns(stub(:wait_until_ready => true))

      cmd
    end

    it "calls wait on the SSH connection" do
      connection = mock
      transport.expects(:connection).returns(connection)
      connection.expects(:wait_until_ready)

      cmd
    end
  end

  describe "to maintain backwards compatibility" do

    let(:driver) do
      Kitchen::Driver::BackCompat.new(config).finalize_config!(instance)
    end

    it "#instance returns its instance" do
      driver.instance.must_equal instance
    end

    it "#name returns the name of the driver" do
      driver.name.must_equal "BackCompat"
    end

    describe "#logger" do

      before  { @klog = Kitchen.logger }
      after   { Kitchen.logger = @klog }

      it "returns the instance's logger if defined" do
        driver.send(:logger).must_equal logger
      end

      it "returns the default logger if instance's logger is not set" do
        driver = Kitchen::Driver::BackCompat.new(config)
        Kitchen.logger = "yep"

        driver.send(:logger).must_equal Kitchen.logger
      end
    end

    it "#puts calls logger.info" do
      driver.send(:puts, "yo")

      logged_output.string.must_match(/I, /)
      logged_output.string.must_match(/yo\n/)
    end

    it "#print calls logger.info" do
      driver.send(:print, "yo")

      logged_output.string.must_match(/I, /)
      logged_output.string.must_match(/yo\n/)
    end

    it "has a default verify dependencies method" do
      driver.verify_dependencies.must_be_nil
    end

    it "#busser returns the instance's verifier" do
      driver.send(:busser).must_equal verifier
    end

    describe ".no_parallel_for" do

      it "registers no serial actions when none are declared" do
        Kitchen::Driver::SpeedyCompat.serial_actions.must_equal nil
      end

      it "registers a single serial action method" do
        Kitchen::Driver::DodgyCompat.serial_actions.must_equal [:converge]
      end

      it "registers multiple serial action methods" do
        actions = Kitchen::Driver::SlowCompat.serial_actions

        actions.must_include :create
        actions.must_include :verify
        actions.must_include :destroy
      end

      it "raises a ClientError if value is not an action method" do
        proc {
          Class.new(Kitchen::Driver::BackCompat) {
            no_parallel_for :telling_stories
          }
        }.must_raise Kitchen::ClientError
      end
    end

    # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    def self.constructs_an_ssh_object
      it "with hostname set from state" do
        Kitchen::SSH.expects(:new).with { |hostname, _username, _opts|
          hostname.must_equal "fizzy"
        }.returns(connection)

        cmd
      end

      it "with username set from state" do
        Kitchen::SSH.expects(:new).with { |_hostname, username, _opts|
          username.must_equal "bork"
        }.returns(connection)

        cmd
      end

      it "with :user_known_hosts_file option set to /dev/null" do
        Kitchen::SSH.expects(:new).with { |_hostname, _username, opts|
          opts[:user_known_hosts_file].must_equal "/dev/null"
        }.returns(connection)

        cmd
      end

      it "with :paranoid option set to false" do
        Kitchen::SSH.expects(:new).with { |_hostname, _username, opts|
          opts[:paranoid].must_equal false
        }.returns(connection)

        cmd
      end

      it "with :keys_only option set to falsey by default" do
        Kitchen::SSH.expects(:new).with { |_hostname, _username, opts|
          opts[:keys_only].nil?
        }.returns(connection)

        cmd
      end

      it "with :keys_only option set to true if :ssh_key is set in config" do
        config[:ssh_key] = "wicked"

        Kitchen::SSH.expects(:new).with { |_hostname, _username, opts|
          opts[:keys_only].must_equal true
        }.returns(connection)

        cmd
      end

      it "with :keys_only option set to true if :ssh_key is set in state" do
        state[:ssh_key] = "wicked"

        Kitchen::SSH.expects(:new).with { |_hostname, _username, opts|
          opts[:keys_only].must_equal true
        }.returns(connection)

        cmd
      end

      it "with :keys option set to falsey by default" do
        Kitchen::SSH.expects(:new).with { |_hostname, _username, opts|
          opts[:keys].nil?
        }.returns(connection)

        cmd
      end

      it "with :keys option set to an array if :ssh_key is set in config" do
        config[:ssh_key] = "wicked"

        Kitchen::SSH.expects(:new).with { |_hostname, _username, opts|
          opts[:keys].must_equal ["wicked"]
        }.returns(connection)

        cmd
      end

      it "with :keys option set to an array if :ssh_key is set in state" do
        state[:ssh_key] = "wicked"

        Kitchen::SSH.expects(:new).with { |_hostname, _username, opts|
          opts[:keys].must_equal ["wicked"]
        }.returns(connection)

        cmd
      end

      it "with :password option set to falsey by default" do
        Kitchen::SSH.expects(:new).with { |_hostname, _username, opts|
          opts[:password].nil?
        }.returns(connection)

        cmd
      end

      it "with :password option set if given in config" do
        config[:password] = "psst"

        Kitchen::SSH.expects(:new).with { |_hostname, _username, opts|
          opts[:password].must_equal "psst"
        }.returns(connection)

        cmd
      end

      it "with :password option set if given in state" do
        state[:password] = "psst"

        Kitchen::SSH.expects(:new).with { |_hostname, _username, opts|
          opts[:password].must_equal "psst"
        }.returns(connection)

        cmd
      end

      it "with :forward_agent option set to falsey by default" do
        Kitchen::SSH.expects(:new).with { |_hostname, _username, opts|
          opts[:forward_agent].nil?
        }.returns(connection)

        cmd
      end

      it "with :forward_agent option set if given in config" do
        config[:forward_agent] = "yeah?"

        Kitchen::SSH.expects(:new).with { |_hostname, _username, opts|
          opts[:forward_agent].must_equal "yeah?"
        }.returns(connection)

        cmd
      end

      it "with :forward_agent option set if given in state" do
        state[:forward_agent] = "yeah?"

        Kitchen::SSH.expects(:new).with { |_hostname, _username, opts|
          opts[:forward_agent].must_equal "yeah?"
        }.returns(connection)

        cmd
      end

      it "with :port option set to 22 by default" do
        Kitchen::SSH.expects(:new).with { |_hostname, _username, opts|
          opts[:port].must_equal 22
        }.returns(connection)

        cmd
      end

      it "with :port option set if customized in config" do
        config[:port] = 1234

        Kitchen::SSH.expects(:new).with { |_hostname, _username, opts|
          opts[:port].must_equal 1234
        }.returns(connection)

        cmd
      end

      it "with :port option set if customized in state" do
        state[:port] = 9999

        Kitchen::SSH.expects(:new).with { |_hostname, _username, opts|
          opts[:port].must_equal 9999
        }.returns(connection)

        cmd
      end

      it "with :logger option set to driver's logger" do
        Kitchen::SSH.expects(:new).with { |_hostname, _username, opts|
          opts[:logger].must_equal logger
        }.returns(connection)

        cmd
      end
    end
    # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

    describe "#run_remote" do

      let(:cmd)         { driver.use_run_remote(state, "huh") }
      let(:connection)  { stub(:exec => true) }

      before do
        state[:hostname] = "fizzy"
        state[:username] = "bork"
      end

      constructs_an_ssh_object

      it "invokes the #install_command with :http_proxy set in config" do
        config[:http_proxy] = "http://proxy"
        Kitchen::SSH.stubs(:new).returns(connection)
        connection.expects(:exec).with("env http_proxy=http://proxy huh")

        cmd
      end

      it "invokes the #install_command with :https_proxy set in config" do
        config[:https_proxy] = "https://proxy"
        Kitchen::SSH.stubs(:new).returns(connection)
        connection.expects(:exec).with("env https_proxy=https://proxy huh")

        cmd
      end

      it "invokes the #install_command with :http_proxy & :https_proxy set" do
        config[:http_proxy] = "http://proxy"
        config[:https_proxy] = "https://proxy"
        Kitchen::SSH.stubs(:new).returns(connection)
        connection.expects(:exec).with(
          "env http_proxy=http://proxy https_proxy=https://proxy huh")

        cmd
      end

      it "doesn't invoke an ssh command if command is nil" do
        Kitchen::SSH.stubs(:new).returns(mock)

        driver.use_run_remote(state, nil)
      end

      it "raises an ActionFailed on transfer when SSHFailed is raised" do
        Kitchen::SSH.stubs(:new).returns(connection)
        connection.stubs(:exec).raises(Kitchen::SSHFailed.new("dang"))

        proc { cmd }.must_raise Kitchen::ActionFailed
      end

      it "raises an ActionFailed on exec when Net::SSH:Exception is raised" do
        Kitchen::SSH.stubs(:new).returns(connection)
        connection.stubs(:exec).raises(Net::SSH::Exception.new("dang"))

        proc { cmd }.must_raise Kitchen::ActionFailed
      end
    end

    describe "#transfer_path" do

      let(:cmd)         { driver.use_transfer_path(state, ["nope"], "nadda") }
      let(:connection)  { stub(:upload_path! => true) }

      before do
        state[:hostname] = "fizzy"
        state[:username] = "bork"
      end

      constructs_an_ssh_object

      it "doesn't invoke an scp command if locals is nil" do
        Kitchen::SSH.stubs(:new).returns(mock)

        driver.use_transfer_path(state, nil, "nope")
      end

      it "doesn't invoke an scp command if locals is an empty array" do
        Kitchen::SSH.stubs(:new).returns(mock)

        driver.use_transfer_path(state, [], "nope")
      end

      it "raises an ActionFailed on transfer when SSHFailed is raised" do
        Kitchen::SSH.stubs(:new).returns(connection)
        connection.stubs(:upload_path!).raises(Kitchen::SSHFailed.new("dang"))

        proc { cmd }.must_raise Kitchen::ActionFailed
      end

      it "raises an ActionFailed on exec when Net::SSH:Exception is raised" do
        Kitchen::SSH.stubs(:new).returns(connection)
        connection.stubs(:upload_path!).raises(Net::SSH::Exception.new("dang"))

        proc { cmd }.must_raise Kitchen::ActionFailed
      end
    end
  end
end
