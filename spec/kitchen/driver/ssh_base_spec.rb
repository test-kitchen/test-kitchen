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

describe Kitchen::Driver::SSHBase do

  let(:logged_output) { StringIO.new }
  let(:logger)        { Logger.new(logged_output) }
  let(:config)        { Hash.new }
  let(:state)         { Hash.new }

  let(:busser) do
    stub(
      :setup_cmd  => "setup",
      :sync_cmd   => "sync",
      :run_cmd    => "run"
    )
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

  let(:instance) do
    stub(
      :name         => "coolbeans",
      :logger       => logger,
      :busser       => busser,
      :provisioner  => provisioner,
      :to_str       => "instance"
    )
  end

  let(:driver) do
    Kitchen::Driver::SSHBase.new(config).finalize_config!(instance)
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

  def self.constructs_an_ssh_object # rubocop:disable Style/MethodLength
    describe "constructs an SSH object" do

      it "with hostname set from state" do
        Kitchen::SSH.expects(:new).with { |hostname, _username, _opts|
          hostname.must_equal "fizzy"
        }.returns(stub(:login_command => stub))

        cmd
      end

      it "with username set from state" do
        Kitchen::SSH.expects(:new).with { |_hostname, username, _opts|
          username.must_equal "bork"
        }.returns(stub(:login_command => stub))

        cmd
      end

      it "with :user_known_hosts_file option set to /dev/null" do
        Kitchen::SSH.expects(:new).with { |_hostname, _username, opts|
          opts[:user_known_hosts_file].must_equal "/dev/null"
        }.returns(stub(:login_command => stub))

        cmd
      end

      it "with :paranoid option set to false" do
        Kitchen::SSH.expects(:new).with { |_hostname, _username, opts|
          opts[:paranoid].must_equal false
        }.returns(stub(:login_command => stub))

        cmd
      end

      it "with :keys_only option set to falsey by default" do
        Kitchen::SSH.expects(:new).with { |_hostname, _username, opts|
          opts[:keys_only].nil?
        }.returns(stub(:login_command => stub))

        cmd
      end

      it "with :keys_only option set to true if :ssh_key is set in config" do
        config[:ssh_key] = "wicked"

        Kitchen::SSH.expects(:new).with { |_hostname, _username, opts|
          opts[:keys_only].must_equal true
        }.returns(stub(:login_command => stub))

        cmd
      end

      it "with :keys_only option set to true if :ssh_key is set in state" do
        state[:ssh_key] = "wicked"

        Kitchen::SSH.expects(:new).with { |_hostname, _username, opts|
          opts[:keys_only].must_equal true
        }.returns(stub(:login_command => stub))

        cmd
      end

      it "with :keys option set to falsey by default" do
        Kitchen::SSH.expects(:new).with { |_hostname, _username, opts|
          opts[:keys].nil?
        }.returns(stub(:login_command => stub))

        cmd
      end

      it "with :keys option set to an array if :ssh_key is set in config" do
        config[:ssh_key] = "wicked"

        Kitchen::SSH.expects(:new).with { |_hostname, _username, opts|
          opts[:keys].must_equal ["wicked"]
        }.returns(stub(:login_command => stub))

        cmd
      end

      it "with :keys option set to an array if :ssh_key is set in state" do
        state[:ssh_key] = "wicked"

        Kitchen::SSH.expects(:new).with { |_hostname, _username, opts|
          opts[:keys].must_equal ["wicked"]
        }.returns(stub(:login_command => stub))

        cmd
      end

      it "with :password option set to falsey by default" do
        Kitchen::SSH.expects(:new).with { |_hostname, _username, opts|
          opts[:password].nil?
        }.returns(stub(:login_command => stub))

        cmd
      end

      it "with :password option set if given in config" do
        config[:password] = "psst"

        Kitchen::SSH.expects(:new).with { |_hostname, _username, opts|
          opts[:password].must_equal "psst"
        }.returns(stub(:login_command => stub))

        cmd
      end

      it "with :password option set if given in state" do
        config[:password] = "psst"

        Kitchen::SSH.expects(:new).with { |_hostname, _username, opts|
          opts[:password].must_equal "psst"
        }.returns(stub(:login_command => stub))

        cmd
      end

      it "with :forward_agent option set to falsey by default" do
        Kitchen::SSH.expects(:new).with { |_hostname, _username, opts|
          opts[:forward_agent].nil?
        }.returns(stub(:login_command => stub))

        cmd
      end

      it "with :forward_agent option set if given in config" do
        config[:forward_agent] = "yeah?"

        Kitchen::SSH.expects(:new).with { |_hostname, _username, opts|
          opts[:forward_agent].must_equal "yeah?"
        }.returns(stub(:login_command => stub))

        cmd
      end

      it "with :forward_agent option set if given in state" do
        state[:forward_agent] = "yeah?"

        Kitchen::SSH.expects(:new).with { |_hostname, _username, opts|
          opts[:forward_agent].must_equal "yeah?"
        }.returns(stub(:login_command => stub))

        cmd
      end

      it "with :port option set to 22 by default" do
        Kitchen::SSH.expects(:new).with { |_hostname, _username, opts|
          opts[:port].must_equal 22
        }.returns(stub(:login_command => stub))

        cmd
      end

      it "with :port option set if customized in config" do
        config[:port] = 1234

        Kitchen::SSH.expects(:new).with { |_hostname, _username, opts|
          opts[:port].must_equal 1234
        }.returns(stub(:login_command => stub))

        cmd
      end

      it "with :port option set if customized in state" do
        config[:port] = 9999

        Kitchen::SSH.expects(:new).with { |_hostname, _username, opts|
          opts[:port].must_equal 9999
        }.returns(stub(:login_command => stub))

        cmd
      end

      it "with :logger option set to driver's logger" do
        Kitchen::SSH.expects(:new).with { |_hostname, _username, opts|
          opts[:logger].must_equal logger
        }.returns(stub(:login_command => stub))

        cmd
      end
    end
  end

  describe "#login_command" do

    let(:cmd) { driver.login_command(state) }

    before do
      state[:hostname] = "fizzy"
      state[:username] = "bork"
    end

    it "returns a LoginCommand" do
      cmd.must_be_instance_of Kitchen::LoginCommand
    end

    constructs_an_ssh_object
  end

  describe "#converge" do

    let(:cmd)         { driver.converge(state) }
    let(:connection)  { stub(:exec => true) }

    before do
      state[:hostname] = "fizzy"
      state[:username] = "bork"
      provisioner.stubs(:[]).with(:root_path).returns("/rooty")
      FakeFS.activate!
      FileUtils.mkdir_p("/tmp")
    end

    after do
      FakeFS.deactivate!
      FakeFS::FileSystem.clear
    end

    constructs_an_ssh_object

    it "creates the sandbox" do
      Kitchen::SSH.stubs(:new).yields(connection)
      provisioner.expects(:create_sandbox)

      cmd
    end

    it "ensures that the sandbox is cleaned up" do
      Kitchen::SSH.stubs(:new).raises
      provisioner.expects(:cleanup_sandbox)

      begin
        cmd
      rescue # rubocop:disable Lint/HandleExceptions
      end
    end

    it "invokes the provisioner commands over ssh" do
      Kitchen::SSH.stubs(:new).yields(connection)
      order = sequence("order")
      connection.expects(:exec).with("install").in_sequence(order)
      connection.expects(:exec).with("init").in_sequence(order)
      connection.expects(:exec).with("prepare").in_sequence(order)
      connection.expects(:exec).with("run").in_sequence(order)

      cmd
    end

    it "invokes the #install_command with :http_proxy set in config" do
      config[:http_proxy] = "http://proxy"
      Kitchen::SSH.stubs(:new).yields(connection)
      connection.expects(:exec).with("env http_proxy=http://proxy install")

      cmd
    end

    it "invokes the #install_command with :https_proxy set in config" do
      config[:https_proxy] = "https://proxy"
      Kitchen::SSH.stubs(:new).yields(connection)
      connection.expects(:exec).with("env https_proxy=https://proxy install")

      cmd
    end

    it "invokes the #install_command with :http_proxy & :https_proxy set" do
      config[:http_proxy] = "http://proxy"
      config[:https_proxy] = "https://proxy"
      Kitchen::SSH.stubs(:new).yields(connection)
      connection.expects(:exec).with(
        "env http_proxy=http://proxy https_proxy=https://proxy install")

      cmd
    end

    describe "transferring files" do

      before do
        Kitchen::SSH.stubs(:new).yields(connection)
        connection.stubs(:upload_path!)
        FileUtils.mkdir_p "/tmp/sandbox/stuff"
      end

      it "uploads files" do
        connection.expects(:upload_path!).with("/tmp/sandbox/stuff", "/rooty")

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

      it "raises an ActionFailed on transfer when SSHFailed is raised" do
        connection.stubs(:upload_path!).raises(Kitchen::SSHFailed.new("dang"))

        proc { cmd }.must_raise Kitchen::ActionFailed
      end

      it "raises an ActionFailed on exec when Net::SSH:Exception is raised" do
        connection.stubs(:upload_path!).raises(Net::SSH::Exception.new("dang"))

        proc { cmd }.must_raise Kitchen::ActionFailed
      end
    end

    it "raises an ActionFailed on exec when SSHFailed is raised" do
      Kitchen::SSH.stubs(:new).yields(connection)
      connection.stubs(:exec).raises(Kitchen::SSHFailed.new("dang"))

      proc { cmd }.must_raise Kitchen::ActionFailed
    end

    it "raises an ActionFailed on exec when Net::SSH:Exception is raised" do
      Kitchen::SSH.stubs(:new).yields(connection)
      connection.stubs(:exec).raises(Net::SSH::Exception.new("dang"))

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

    constructs_an_ssh_object

    it "doesn't invoke an ssh command if busser#setup_cmd is nil" do
      busser.stubs(:setup_cmd).returns(nil)
      Kitchen::SSH.stubs(:new).yields(connection)

      cmd
    end

    it "invokes the busser#setup_cmd over ssh" do
      Kitchen::SSH.stubs(:new).yields(connection)
      connection.expects(:exec).with("setup")

      cmd
    end

    it "invokes the busser#setup_cmd with :http_proxy set in config" do
      config[:http_proxy] = "http://proxy"
      Kitchen::SSH.stubs(:new).yields(connection)
      connection.expects(:exec).with("env http_proxy=http://proxy setup")

      cmd
    end

    it "invokes the busser#setup_cmd with :https_proxy set in config" do
      config[:https_proxy] = "https://proxy"
      Kitchen::SSH.stubs(:new).yields(connection)
      connection.expects(:exec).with("env https_proxy=https://proxy setup")

      cmd
    end

    it "invokes the busser#setup_cmd with :http_proxy & :https_proxy set" do
      config[:http_proxy] = "http://proxy"
      config[:https_proxy] = "https://proxy"
      Kitchen::SSH.stubs(:new).yields(connection)
      connection.expects(:exec).with(
        "env http_proxy=http://proxy https_proxy=https://proxy setup")

      cmd
    end

    it "raises an ActionFailed when SSHFailed is raised" do
      Kitchen::SSH.stubs(:new).yields(connection)
      connection.stubs(:exec).raises(Kitchen::SSHFailed.new("dang"))

      proc { cmd }.must_raise Kitchen::ActionFailed
    end

    it "raises an ActionFailed when Net::SSH:Exception is raised" do
      Kitchen::SSH.stubs(:new).yields(connection)
      connection.stubs(:exec).raises(Net::SSH::Exception.new("dang"))

      proc { cmd }.must_raise Kitchen::ActionFailed
    end
  end

  describe "#verify" do

    let(:cmd)         { driver.verify(state) }
    let(:connection)  { mock }

    before do
      state[:hostname] = "fizzy"
      state[:username] = "bork"
    end

    constructs_an_ssh_object

    it "doesn't invoke an ssh command if busser#sync_cmd & #run_cmd are nil" do
      busser.stubs(:sync_cmd).returns(nil)
      busser.stubs(:run_cmd).returns(nil)
      Kitchen::SSH.stubs(:new).yields(connection)

      cmd
    end

    it "doesn't invoke an ssh command for busser#sync_cmd if nil" do
      busser.stubs(:sync_cmd).returns(nil)
      Kitchen::SSH.stubs(:new).yields(connection)
      connection.expects(:exec).with("run")

      cmd
    end

    it "doesn't invoke an ssh command for busser#run_cmd if nil" do
      busser.stubs(:run_cmd).returns(nil)
      Kitchen::SSH.stubs(:new).yields(connection)
      connection.expects(:exec).with("sync")

      cmd
    end

    it "invokes the busser#sync_cmd & #run_cmd over ssh" do
      Kitchen::SSH.stubs(:new).yields(connection)
      connection.expects(:exec).with("sync")
      connection.expects(:exec).with("run")

      cmd
    end

    it "invokes the busser#setup_cmd with :http_proxy set in config" do
      busser.stubs(:run_cmd).returns(nil)
      config[:http_proxy] = "http://proxy"
      Kitchen::SSH.stubs(:new).yields(connection)
      connection.expects(:exec).with("env http_proxy=http://proxy sync")

      cmd
    end

    it "invokes the busser#setup_cmd with :https_proxy set in config" do
      busser.stubs(:run_cmd).returns(nil)
      config[:https_proxy] = "https://proxy"
      Kitchen::SSH.stubs(:new).yields(connection)
      connection.expects(:exec).with("env https_proxy=https://proxy sync")

      cmd
    end

    it "invokes the busser#setup_cmd with :http_proxy & :https_proxy set" do
      busser.stubs(:run_cmd).returns(nil)
      config[:http_proxy] = "http://proxy"
      config[:https_proxy] = "https://proxy"
      Kitchen::SSH.stubs(:new).yields(connection)
      connection.expects(:exec).with(
        "env http_proxy=http://proxy https_proxy=https://proxy sync")

      cmd
    end

    it "raises an ActionFailed when SSHFailed is raised" do
      Kitchen::SSH.stubs(:new).yields(connection)
      connection.stubs(:exec).raises(Kitchen::SSHFailed.new("dang"))

      proc { cmd }.must_raise Kitchen::ActionFailed
    end

    it "raises an ActionFailed when Net::SSH:Exception is raised" do
      Kitchen::SSH.stubs(:new).yields(connection)
      connection.stubs(:exec).raises(Net::SSH::Exception.new("dang"))

      proc { cmd }.must_raise Kitchen::ActionFailed
    end
  end

  describe "#ssh" do

    let(:cmd)         { driver.ssh(["host", "user", { :one => "two" }], "go") }
    let(:connection)  { mock }

    it "creates an SSH object" do
      Kitchen::SSH.expects(:new).with { |hostname, username, opts|
        hostname.must_equal "host"
        username.must_equal "user"
        opts.must_equal(:one => "two")
      }

      cmd
    end

    it "invokes the command over ssh" do
      Kitchen::SSH.stubs(:new).yields(connection)
      connection.expects(:exec).with("go")

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

    it "creates an SSH object" do
      Kitchen::SSH.expects(:new).with { |hostname, username, _opts|
        hostname.must_equal "fizzy"
        username.must_equal "bork"
      }

      cmd
    end

    it "invokes the command over ssh" do
      Kitchen::SSH.stubs(:new).yields(connection)
      connection.expects(:exec).with("shipit")

      cmd
    end
  end

  describe "#wait_for_sshd" do

    let(:cmd) do
      driver.send(:wait_for_sshd, "host", "user", :one => "two")
    end

    it "creates an SSH object with merged options" do
      Kitchen::SSH.expects(:new).with { |hostname, username, opts|
        hostname.must_equal "host"
        username.must_equal "user"
        opts.must_equal(:one => "two", :logger => logger)
      }.returns(stub(:wait => true))

      cmd
    end

    it "calls wait on the SSH object" do
      ssh = mock
      Kitchen::SSH.stubs(:new).returns(ssh)
      ssh.expects(:wait)

      cmd
    end
  end
end
