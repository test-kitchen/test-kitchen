#
# Author:: Fletcher Nichol (<fnichol@nichol.ca>)
#
# Copyright (C) 2012, Fletcher Nichol
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

require_relative "../spec_helper"
require "stringio"

require "kitchen/logging"
require "kitchen/instance"
require "kitchen/driver"
require "kitchen/driver/dummy"
require "kitchen/platform"
require "kitchen/provisioner"
require "kitchen/provisioner/dummy"
require "kitchen/suite"
require "kitchen/transport/dummy"
require "kitchen/verifier/dummy"

class DummyStateFile
  def initialize(*)
    @_state = {}
  end

  def read
    @_state.dup
  end

  def write(state)
    @_state = state.dup
  end

  def destroy
    @_state = {}
  end

  def diagnose
    {}
  end
end

class SerialDummyDriver < Kitchen::Driver::Dummy
  no_parallel_for :create, :destroy

  attr_reader :action_in_mutex

  def initialize(config = {})
    super(config)
    @action_in_mutex = {}
  end

  def track_locked(action)
    @action_in_mutex ||= {}
    @action_in_mutex[action] = Kitchen::Instance.mutexes[self.class].locked?
  end

  def create(state)
    track_locked(:create)
    super
  end

  def destroy(state)
    track_locked(:destroy)
    super
  end
end

class SerialDummyVerifier < Kitchen::Verifier::Dummy
  no_parallel_for :verify

  attr_reader :action_in_mutex

  def initialize(config = {})
    super(config)
    @action_in_mutex = {}
  end

  def track_locked(action)
    @action_in_mutex ||= {}
    @action_in_mutex[action] = Kitchen::Instance.mutexes[self.class].locked?
  end

  def call(state)
    track_locked(:verify)
    super
  end
end

class LegacyDriver < Kitchen::Driver::SSHBase
  attr_reader :called_converge, :called_setup, :called_verify

  def converge(_)
    @called_converge
  end

  def setup(_)
    @called_setup
  end

  def verify(_)
    @called_verify
  end
end

describe Kitchen::Instance do
  let(:driver)          { Kitchen::Driver::Dummy.new({}) }
  let(:logger_io)       { StringIO.new }
  let(:logger)          { Kitchen::Logger.new(logdev: logger_io) }
  let(:instance)        { Kitchen::Instance.new(opts) }
  let(:lifecycle_hooks) { Kitchen::LifecycleHooks.new({}, state_file) }
  let(:provisioner)     { Kitchen::Provisioner::Dummy.new({}) }
  let(:state_file)      { DummyStateFile.new }
  let(:transport)       { Kitchen::Transport::Dummy.new({}) }
  let(:verifier)        { Kitchen::Verifier::Dummy.new({}) }

  let(:opts) do
    { suite: suite, platform: platform, driver: driver, lifecycle_hooks: lifecycle_hooks,
      provisioner: provisioner, verifier: verifier,
      logger: logger, state_file: state_file, transport: transport }
  end

  def suite(name = "suite")
    @suite ||= Kitchen::Suite.new(name: name)
  end

  def platform(name = "platform")
    @platform ||= Kitchen::Platform.new(name: name)
  end

  describe ".name_for" do
    it "combines the suite and platform names with a dash" do
      _(Kitchen::Instance.name_for(suite("suite"), platform("platform")))
        .must_equal "suite-platform"
    end

    it "squashes periods in suite name" do
      _(Kitchen::Instance.name_for(suite("suite.ness"), platform("platform")))
        .must_equal "suiteness-platform"
    end

    it "squashes periods in platform name" do
      _(Kitchen::Instance.name_for(suite("suite"), platform("platform.s")))
        .must_equal "suite-platforms"
    end

    it "squashes periods in suite and platform names" do
      _(Kitchen::Instance.name_for(suite("s.s"), platform("p.p")))
        .must_equal "ss-pp"
    end

    it "transforms underscores to dashes in suite name" do
      _(Kitchen::Instance.name_for(suite("suite_ness"), platform("platform")))
        .must_equal "suite-ness-platform"
    end

    it "transforms underscores to dashes in platform name" do
      _(Kitchen::Instance.name_for(suite("suite"), platform("platform_s")))
        .must_equal "suite-platform-s"
    end

    it "transforms underscores to dashes in suite and platform names" do
      _(Kitchen::Instance.name_for(suite("_s__s_"), platform("pp_")))
        .must_equal "-s--s--pp-"
    end

    it "transforms forward slashes to dashes in suite name" do
      _(Kitchen::Instance.name_for(suite("suite/ness"), platform("platform")))
        .must_equal "suite-ness-platform"
    end

    it "transforms forward slashes to dashes in platform name" do
      _(Kitchen::Instance.name_for(suite("suite"), platform("platform/s")))
        .must_equal "suite-platform-s"
    end

    it "transforms forward slashes to dashes in suite and platform names" do
      _(Kitchen::Instance.name_for(suite("/s//s/"), platform("pp/")))
        .must_equal "-s--s--pp-"
    end
  end

  describe "#suite" do
    it "returns its suite" do
      _(instance.suite).must_equal suite
    end

    it "raises an ArgumentError if missing" do
      opts.delete(:suite)
      _ { Kitchen::Instance.new(opts) }.must_raise Kitchen::ClientError
    end
  end

  describe "#platform" do
    it "returns its platform" do
      _(instance.platform).must_equal platform
    end

    it "raises an ArgumentError if missing" do
      opts.delete(:platform)
      _ { Kitchen::Instance.new(opts) }.must_raise Kitchen::ClientError
    end
  end

  describe "#driver" do
    it "returns its driver" do
      _(instance.driver).must_equal driver
    end

    it "raises an ArgumentError if missing" do
      opts.delete(:driver)
      _ { Kitchen::Instance.new(opts) }.must_raise Kitchen::ClientError
    end

    it "sets Driver#instance to itself" do
      # it's mind-bottling
      _(instance.driver.instance).must_equal instance
    end
  end

  describe "#logger" do
    it "returns its logger" do
      _(instance.logger).must_equal logger
    end

    it "uses Kitchen.logger by default" do
      opts.delete(:logger)
      _(instance.logger).must_equal Kitchen.logger
    end
  end

  describe "#provisioner" do
    it "returns its provisioner" do
      _(instance.provisioner).must_equal provisioner
    end

    it "raises an ArgumentError if missing" do
      opts.delete(:provisioner)
      _ { Kitchen::Instance.new(opts) }.must_raise Kitchen::ClientError
    end

    it "sets Provisioner#instance to itself" do
      # it's mind-bottling
      _(instance.provisioner.instance).must_equal instance
    end
  end

  describe "#transport" do
    it "returns its transport" do
      _(instance.transport).must_equal transport
    end

    it "raises an ArgumentError if missing" do
      opts.delete(:transport)
      _ { Kitchen::Instance.new(opts) }.must_raise Kitchen::ClientError
    end

    it "sets Transport#instance to itself" do
      # it's mind-bottling
      _(instance.transport.instance).must_equal instance
    end
  end

  describe "#verifier" do
    it "returns its verifier" do
      _(instance.verifier).must_equal verifier
    end

    it "raises and ArgumentError if missing" do
      opts.delete(:verifier)
      _ { Kitchen::Instance.new(opts) }.must_raise Kitchen::ClientError
    end

    it "sets Verifier#instance to itself" do
      # it's mind-bottling
      _(instance.verifier.instance).must_equal instance
    end
  end

  describe "#state_file" do
    it "raises an ArgumentError if missing" do
      opts.delete(:state_file)
      _ { Kitchen::Instance.new(opts) }.must_raise Kitchen::ClientError
    end
  end

  it "#name returns it name" do
    _(instance.name).must_equal "suite-platform"
  end

  it "#to_str returns a string representation with its name" do
    _(instance.to_str).must_equal "<suite-platform>"
  end

  it "#login executes the transport's login_command" do
    conn = stub("connection")
    state_file.write(last_action: "create")
    transport.stubs(:connection).with(has_entries(last_action: "create"))
      .returns(conn)
    conn.stubs(:login_command)
      .returns(Kitchen::LoginCommand.new("echo", ["hello"], purple: true))
    Kernel.expects(:exec).with("echo", "hello", { purple: true })

    instance.login
  end

  it "#login raises a UserError if the instance is not created" do
    state_file.write({})

    _ { instance.login }.must_raise Kitchen::UserError
  end

  describe "#diagnose" do
    it "returns a hash" do
      _(instance.diagnose).must_be_instance_of Hash
    end

    it "sets :platform key to platform's diagnose info" do
      platform.stubs(:diagnose).returns(a: "b")

      _(instance.diagnose[:platform]).must_equal(a: "b")
    end

    it "sets :platform key to :unknown if obj can't respond to #diagnose" do
      opts[:platform] = Class.new(platform.class) do
        undef_method :diagnose
      end.new(name: "whoop")

      _(instance.diagnose[:platform]).must_equal :unknown
    end

    it "sets :state_file key to state_file's diagnose info" do
      state_file.stubs(:diagnose).returns(a: "b")

      _(instance.diagnose[:state_file]).must_equal(a: "b")
    end

    it "sets :state_file key to :unknown if obj can't respond to #diagnose" do
      opts[:state_file] = Class.new(state_file.class) do
        undef_method :diagnose
      end.new

      _(instance.diagnose[:state_file]).must_equal :unknown
    end

    it "sets :provisioner key to provisioner's diagnose info" do
      provisioner.stubs(:diagnose).returns(a: "b")

      _(instance.diagnose[:provisioner]).must_equal(a: "b")
    end

    it "sets :provisioner key to :unknown if obj can't respond to #diagnose" do
      opts[:provisioner] = Class.new(provisioner.class) do
        undef_method :diagnose
      end.new

      _(instance.diagnose[:provisioner]).must_equal :unknown
    end

    it "sets :verifier key to verifier's diagnose info" do
      verifier.stubs(:diagnose).returns(a: "b")

      _(instance.diagnose[:verifier]).must_equal(a: "b")
    end

    it "sets :verifier key to :unknown if obj can't respond to #diagnose" do
      opts[:verifier] = Class.new(verifier.class) do
        undef_method :diagnose
      end.new({})

      _(instance.diagnose[:verifier]).must_equal :unknown
    end

    it "sets :transport key to transport's diagnose info" do
      transport.stubs(:diagnose).returns(a: "b")

      _(instance.diagnose[:transport]).must_equal(a: "b")
    end

    it "sets :transport key to :unknown if obj can't respond to #diagnose" do
      opts[:transport] = Class.new(transport.class) do
        undef_method :diagnose
      end.new

      _(instance.diagnose[:transport]).must_equal :unknown
    end
  end

  describe "#diagnose_plugins" do
    it "returns a hash" do
      _(instance.diagnose_plugins).must_be_instance_of Hash
    end

    it "sets :driver key to driver's plugin_diagnose info" do
      driver.class.stubs(:diagnose).returns(a: "b")

      _(instance.diagnose_plugins[:driver]).must_equal(
        name: "Dummy",
        a: "b"
      )
    end

    it "sets :driver key to :unknown if class doesn't have #diagnose" do
      opts[:driver] = Class.new(driver.class) do
        undef_method :diagnose_plugin
      end.new({})

      _(instance.diagnose_plugins[:driver]).must_equal(:unknown)
    end

    it "sets :provisioner key to provisioner's plugin_diagnose info" do
      provisioner.class.stubs(:diagnose).returns(a: "b")

      _(instance.diagnose_plugins[:provisioner]).must_equal(
        name: "Dummy",
        a: "b"
      )
    end

    it "sets :provisioner key to :unknown if class doesn't have #diagnose" do
      opts[:provisioner] = Class.new(driver.class) do
        undef_method :diagnose_plugin
      end.new({})

      _(instance.diagnose_plugins[:provisioner]).must_equal(:unknown)
    end

    it "sets :verifier key to verifier's plugin_diagnose info" do
      verifier.class.stubs(:diagnose).returns(a: "b")

      _(instance.diagnose_plugins[:verifier]).must_equal(
        name: "Dummy",
        a: "b"
      )
    end

    it "sets :verifier key to :unknown if class doesn't have #diagnose" do
      opts[:verifier] = Class.new(verifier.class) do
        undef_method :diagnose_plugin
      end.new({})

      _(instance.diagnose_plugins[:verifier]).must_equal(:unknown)
    end

    it "sets :transport key to transport's plugin_diagnose info" do
      transport.class.stubs(:diagnose).returns(a: "b")

      _(instance.diagnose_plugins[:transport]).must_equal(
        name: "Dummy",
        a: "b"
      )
    end

    it "sets :transport key to :unknown if class doesn't have #diagnose" do
      opts[:transport] = Class.new(transport.class) do
        undef_method :diagnose_plugin
      end.new({})

      _(instance.diagnose_plugins[:transport]).must_equal(:unknown)
    end
  end

  describe "performing actions" do
    describe "#create" do
      describe "with no state" do
        it "calls Driver#create with empty state hash" do
          driver.expects(:create).with({})

          instance.create
        end

        it "writes the state file with last_action" do
          instance.create

          _(state_file.read[:last_action]).must_equal "create"
        end

        it "logs the action start" do
          instance.create

          _(logger_io.string).must_match regex_for("Creating #{instance.to_str}")
        end

        it "logs the action finish" do
          instance.create

          _(logger_io.string)
            .must_match regex_for("Finished creating #{instance.to_str}")
        end

        it "calls lifecycle hooks" do
          lifecycle_hooks.expects(:run).with(:create, :pre)
          lifecycle_hooks.expects(:run).with(:create, :post)
          lifecycle_hooks.expects(:run).with(:create, :finally)

          instance.create
        end
      end

      describe "with last_action of create" do
        before { state_file.write(last_action: "create") }

        it "calls Driver#create with state hash" do
          driver.expects(:create)
            .with { |state| state[:last_action] == "create" }

          instance.create
        end

        it "writes the state file with last_action" do
          instance.create

          _(state_file.read[:last_action]).must_equal "create"
        end
      end
    end

    describe "#converge" do
      describe "with no state" do
        it "calls Driver#create and Provisioner#call with empty state hash" do
          driver.expects(:create).with({})
          provisioner.expects(:check_license)
          provisioner.expects(:call)
            .with { |state| state[:last_action] == "create" }

          instance.converge
        end

        it "writes the state file with last_action" do
          instance.converge

          _(state_file.read[:last_action]).must_equal "converge"
        end

        it "logs the action start" do
          instance.converge

          _(logger_io.string)
            .must_match regex_for("Converging #{instance.to_str}")
        end

        it "logs the action finish" do
          instance.converge

          _(logger_io.string)
            .must_match regex_for("Finished converging #{instance.to_str}")
        end

        it "calls lifecycle hooks" do
          lifecycle_hooks.expects(:run).with(:create, :pre)
          lifecycle_hooks.expects(:run).with(:create, :post)
          lifecycle_hooks.expects(:run).with(:create, :finally)
          lifecycle_hooks.expects(:run).with(:converge, :pre)
          lifecycle_hooks.expects(:run).with(:converge, :post)
          lifecycle_hooks.expects(:run).with(:converge, :finally)

          instance.converge
        end
      end

      describe "with last action of create" do
        before { state_file.write(last_action: "create") }

        it "calls Provisioner#call with state hash" do
          provisioner.expects(:call)
            .with { |state| state[:last_action] == "create" }

          instance.converge
        end

        it "writes the state file with last_action" do
          instance.converge

          _(state_file.read[:last_action]).must_equal "converge"
        end

        it "calls lifecycle hooks" do
          lifecycle_hooks.expects(:run).with(:converge, :pre)
          lifecycle_hooks.expects(:run).with(:converge, :post)
          lifecycle_hooks.expects(:run).with(:converge, :finally)

          instance.converge
        end
      end

      describe "with last action of converge" do
        before { state_file.write(last_action: "converge") }

        it "calls Provisioner#call with state hash" do
          provisioner.expects(:call)
            .with { |state| state[:last_action] == "converge" }

          instance.converge
        end

        it "writes the state file with last_action" do
          instance.converge

          _(state_file.read[:last_action]).must_equal "converge"
        end
      end
    end

    describe "#setup" do
      describe "with no state" do
        it "calls create and converge with empty state hash" do
          driver.expects(:create).with({})
          provisioner.expects(:call)
            .with { |state| state[:last_action] == "create" }
          driver.expects(:setup)
            .with { |state| state[:last_action] == "converge" }
            .never

          instance.setup
        end

        it "writes the state file with last_action" do
          instance.setup

          _(state_file.read[:last_action]).must_equal "setup"
        end

        it "logs the action start" do
          instance.setup

          _(logger_io.string)
            .must_match regex_for("Setting up #{instance.to_str}")
        end

        it "logs the action finish" do
          instance.setup

          _(logger_io.string)
            .must_match regex_for("Finished setting up #{instance.to_str}")
        end
      end

      describe "with last action of create" do
        before { state_file.write(last_action: "create") }

        it "calls Provisioner#call with state hash" do
          provisioner.expects(:call)
            .with { |state| state[:last_action] == "create" }
          driver.expects(:setup)
            .with { |state| state[:last_action] == "converge" }
            .never

          instance.setup
        end

        it "writes the state file with last_action" do
          instance.setup

          _(state_file.read[:last_action]).must_equal "setup"
        end
      end

      describe "with last action of converge" do
        before { state_file.write(last_action: "converge") }

        it "calls nothing with state hash" do
          driver.expects(:setup)
            .with { |state| state[:last_action] == "converge" }
            .never

          instance.setup
        end

        it "writes the state file with last_action" do
          instance.setup

          _(state_file.read[:last_action]).must_equal "setup"
        end
      end

      describe "with last action of setup" do
        before { state_file.write(last_action: "setup") }

        it "calls nothing with state hash" do
          driver.expects(:setup)
            .with { |state| state[:last_action] == "setup" }
            .never

          instance.setup
        end

        it "writes the state file with last_action" do
          instance.setup

          _(state_file.read[:last_action]).must_equal "setup"
        end
      end
    end

    describe "#verify" do
      describe "with no state" do
        it "calls create, converge, and verify with empty state hash" do
          driver.expects(:create).with({})
          provisioner.expects(:call)
            .with { |state| state[:last_action] == "create" }
          driver.expects(:setup)
            .with { |state| state[:last_action] == "converge" }
            .never
          verifier.expects(:call)
            .with { |state| state[:last_action] == "setup" }

          instance.verify
        end

        it "writes the state file with last_action" do
          instance.verify

          _(state_file.read[:last_action]).must_equal "verify"
        end

        it "logs the action start" do
          instance.verify

          _(logger_io.string)
            .must_match regex_for("Verifying #{instance.to_str}")
        end

        it "logs the action finish" do
          instance.verify

          _(logger_io.string)
            .must_match regex_for("Finished verifying #{instance.to_str}")
        end
      end

      describe "with last of create" do
        before { state_file.write(last_action: "create") }

        it "calls converge, and verify with state hash" do
          provisioner.expects(:call)
            .with { |state| state[:last_action] == "create" }
          driver.expects(:setup)
            .with { |state| state[:last_action] == "converge" }
            .never
          verifier.expects(:call)
            .with { |state| state[:last_action] == "setup" }

          instance.verify
        end

        it "writes the state file with last_action" do
          instance.verify

          _(state_file.read[:last_action]).must_equal "verify"
        end
      end

      describe "with last of converge" do
        before { state_file.write(last_action: "converge") }

        it "calls Verifier#call with state hash" do
          driver.expects(:setup)
            .with { |state| state[:last_action] == "converge" }
            .never
          verifier.expects(:call)
            .with { |state| state[:last_action] == "setup" }

          instance.verify
        end

        it "writes the state file with last_action" do
          instance.verify

          _(state_file.read[:last_action]).must_equal "verify"
        end
      end

      describe "with last of setup" do
        before { state_file.write(last_action: "setup") }

        it "calls Verifier#call with state hash" do
          verifier.expects(:call)
            .with { |state| state[:last_action] == "setup" }

          instance.verify
        end

        it "writes the state file with last_action" do
          instance.verify

          _(state_file.read[:last_action]).must_equal "verify"
        end
      end

      describe "with last of verify" do
        before { state_file.write(last_action: "verify") }

        it "calls Verifier#call with state hash" do
          verifier.expects(:call)
            .with { |state| state[:last_action] == "verify" }

          instance.verify
        end

        it "writes the state file with last_action" do
          instance.verify

          _(state_file.read[:last_action]).must_equal "verify"
        end
      end
    end

    describe "#destroy" do
      describe "with no state" do
        it "calls Driver#destroy with empty state hash" do
          driver.expects(:destroy).with({})

          instance.destroy
        end

        it "destroys the state file" do
          state_file.expects(:destroy)

          instance.destroy
        end

        it "logs the action start" do
          instance.destroy

          _(logger_io.string)
            .must_match regex_for("Destroying #{instance.to_str}")
        end

        it "logs the create finish" do
          instance.destroy

          _(logger_io.string)
            .must_match regex_for("Finished destroying #{instance.to_str}")
        end
      end

      %i{create converge setup verify}.each do |action|
        describe "with last_action of #{action}" do
          before { state_file.write(last_action: action) }

          it "calls Driver#create with state hash" do
            driver.expects(:destroy)
              .with { |state| state[:last_action] == action }

            instance.destroy
          end

          it "destroys the state file" do
            state_file.expects(:destroy)

            instance.destroy
          end
        end
      end
    end

    describe "#test" do
      describe "with no state" do
        it "calls destroy, create, converge, setup, verify, destroy" do
          driver.expects(:destroy)
          driver.expects(:create)
          provisioner.expects(:call)
          verifier.expects(:call)
          driver.expects(:destroy)

          instance.test
        end

        it "logs the action start" do
          instance.test

          _(logger_io.string)
            .must_match regex_for("Testing #{instance.to_str}")
        end

        it "logs the action finish" do
          instance.test

          _(logger_io.string)
            .must_match regex_for("Finished testing #{instance.to_str}")
        end
      end

      %i{create converge setup verify}.each do |action|
        describe "with last action of #{action}" do
          before { state_file.write(last_action: action) }

          it "calls destroy, create, converge, setup, verify, destroy" do
            driver.expects(:destroy)
            driver.expects(:create)
            provisioner.expects(:call)
            verifier.expects(:call)
            driver.expects(:destroy)

            instance.test
          end
        end
      end

      describe "with destroy mode of never" do
        it "calls destroy, create, converge, setup, verify" do
          driver.expects(:destroy).once
          driver.expects(:create)
          provisioner.expects(:call)
          verifier.expects(:call)

          instance.test(:never)
        end
      end

      describe "with destroy mode of always" do
        it "calls destroy at even when action fails" do
          driver.expects(:destroy)
          driver.expects(:create)
          provisioner.expects(:call).raises(Kitchen::ActionFailed)
          driver.expects(:destroy)

          begin
            instance.test(:always)
          rescue # rubocop:disable Lint/HandleExceptions
          end
        end
      end

      describe "with destroy mode of passing" do
        it "doesn't call Driver#destroy at when action fails" do
          driver.stubs(:create).raises(Kitchen::ActionFailed)

          driver.expects(:destroy).once

          begin
            instance.test(:passing)
          rescue # rubocop:disable Lint/HandleExceptions
          end
        end
      end
    end

    describe "#remote_exec" do
      before { state_file.write(last_action: "create") }

      it "calls Transport#execute with command" do
        connection = mock("connection")
        connection.expects(:execute).with("uptime")
        transport.stubs(:connection).yields(connection)

        instance.remote_exec("uptime")
      end
    end

    %i{create converge setup verify test}.each do |action|
      describe "#{action} on driver crash with ActionFailed" do
        before do
          driver.stubs(:create).raises(Kitchen::ActionFailed, "death")
        end

        it "write the state file with last action" do
          begin
            instance.public_send(action)
          rescue Kitchen::Error
            true # no need to act here
          end

          _(state_file.read[:last_action]).must_be_nil
        end

        it "raises an InstanceFailure" do
          _ { instance.public_send(action) }
            .must_raise Kitchen::InstanceFailure
        end

        it "populates the InstanceFailure message" do
          instance.public_send(action)
        rescue Kitchen::Error => e
          _(e.message)
            .must_match regex_for("Create failed on instance #{instance.to_str}")
        end

        it "logs the failure" do
          begin
            instance.public_send(action)
          rescue Kitchen::Error
            true # no need to act here
          end

          _(logger_io.string)
            .must_match regex_for("Create failed on instance #{instance.to_str}")
        end
      end

      describe "on driver crash with unexpected exception class" do
        before do
          driver.stubs(:create).raises(RuntimeError, "watwat")
        end

        it "write the state file with last action" do
          begin
            instance.public_send(action)
          rescue Kitchen::Error
            true # no need to act here
          end

          _(state_file.read[:last_action]).must_be_nil
        end

        it "raises an ActionFailed" do
          _ { instance.public_send(action) }
            .must_raise Kitchen::ActionFailed
        end

        it "populates the ActionFailed message" do
          instance.public_send(action)
        rescue Kitchen::Error => e
          _(e.message)
            .must_match regex_for("Failed to complete #create action: [watwat]")
        end

        it "logs the failure" do
          begin
            instance.public_send(action)
          rescue Kitchen::Error
            true # no need to act here
          end

          _(logger_io.string)
            .must_match regex_for("Create failed on instance #{instance.to_str}")
        end
      end
    end

    describe "crashes preserve last action for desired verify action" do
      before do
        verifier.stubs(:call).raises(Kitchen::ActionFailed, "death")
      end

      %i{create converge setup}.each do |action|
        it "for last state #{action}" do
          state_file.write(last_action: action.to_s)
          begin
            instance.verify
          rescue Kitchen::Error
            true # no need to act here
          end

          _(state_file.read[:last_action]).must_equal "setup"
        end
      end

      it "for last state verify" do
        state_file.write(last_action: "verify")
        begin
          instance.verify
        rescue Kitchen::Error
          true # no need to act here
        end

        _(state_file.read[:last_action]).must_equal "verify"
      end
    end

    describe "on plugins with serial actions" do
      let(:driver) { SerialDummyDriver.new({}) }
      let(:verifier) { SerialDummyVerifier.new({}) }

      it "runs in a synchronized block for serial actions" do
        # require "byebug"; byebug

        instance.test
        _(driver.action_in_mutex[:create]).must_equal true
        _(verifier.action_in_mutex[:verify]).must_equal true
        _(driver.action_in_mutex[:destroy]).must_equal true
      end
    end

    describe "with legacy Driver::SSHBase subclasses" do
      let(:driver) { LegacyDriver.new({}) }

      describe "#converge" do
        describe "with no state" do
          it "calls Driver#create and Driver#converge with empty state hash" do
            driver.expects(:create).with({})
            driver.expects(:converge)
              .with { |state| state[:last_action] == "create" }

            instance.converge
          end
        end

        describe "with last action of create" do
          before { state_file.write(last_action: "create") }

          it "calls Driver#converge with state hash" do
            driver.expects(:converge)
              .with { |state| state[:last_action] == "create" }

            instance.converge
          end
        end

        describe "with last action of converge" do
          before { state_file.write(last_action: "converge") }

          it "calls Driver#converge with state hash" do
            driver.expects(:converge)
              .with { |state| state[:last_action] == "converge" }

            instance.converge
          end
        end
      end

      describe "#setup" do
        describe "with no state" do
          it "calls create, converge, and setup with empty state hash" do
            driver.expects(:create).with({})
            driver.expects(:converge)
              .with { |state| state[:last_action] == "create" }
            driver.expects(:setup)
              .with { |state| state[:last_action] == "converge" }

            instance.setup
          end
        end

        describe "with last action of create" do
          before { state_file.write(last_action: "create") }

          it "calls Provisioner#call and setup with state hash" do
            driver.expects(:converge)
              .with { |state| state[:last_action] == "create" }
            driver.expects(:setup)
              .with { |state| state[:last_action] == "converge" }

            instance.setup
          end
        end

        describe "with last action of converge" do
          before { state_file.write(last_action: "converge") }

          it "calls Driver#setup with state hash" do
            driver.expects(:setup)
              .with { |state| state[:last_action] == "converge" }

            instance.setup
          end
        end

        describe "with last action of setup" do
          before { state_file.write(last_action: "setup") }

          it "calls Driver#setup with state hash" do
            driver.expects(:setup)
              .with { |state| state[:last_action] == "setup" }

            instance.setup
          end
        end
      end

      describe "#verify" do
        describe "with no state" do
          it "calls create, converge, setup, and verify with empty state hash" do
            driver.expects(:create).with({})
            driver.expects(:converge)
              .with { |state| state[:last_action] == "create" }
            driver.expects(:setup)
              .with { |state| state[:last_action] == "converge" }
            driver.expects(:verify)
              .with { |state| state[:last_action] == "setup" }

            instance.verify
          end
        end

        describe "with last of create" do
          before { state_file.write(last_action: "create") }

          it "calls converge, setup, and verify with state hash" do
            driver.expects(:converge)
              .with { |state| state[:last_action] == "create" }
            driver.expects(:setup)
              .with { |state| state[:last_action] == "converge" }
            driver.expects(:verify)
              .with { |state| state[:last_action] == "setup" }

            instance.verify
          end
        end

        describe "with last of converge" do
          before { state_file.write(last_action: "converge") }

          it "calls Driver#setup, and verify with state hash" do
            driver.expects(:setup)
              .with { |state| state[:last_action] == "converge" }
            driver.expects(:verify)
              .with { |state| state[:last_action] == "setup" }

            instance.verify
          end
        end

        describe "with last of setup" do
          before { state_file.write(last_action: "setup") }

          it "calls Driver#verify with state hash" do
            driver.expects(:verify)
              .with { |state| state[:last_action] == "setup" }

            instance.verify
          end
        end

        describe "with last of verify" do
          before { state_file.write(last_action: "verify") }

          it "calls Driver#verify with state hash" do
            driver.expects(:verify)
              .with { |state| state[:last_action] == "verify" }

            instance.verify
          end
        end
      end

      describe "#test" do
        describe "with no state" do
          it "calls destroy, create, converge, setup, verify, destroy" do
            driver.expects(:destroy)
            driver.expects(:create)
            driver.expects(:converge)
            driver.expects(:setup)
            driver.expects(:verify)
            driver.expects(:destroy)

            instance.test
          end
        end

        %i{create converge setup verify}.each do |action|
          describe "with last action of #{action}" do
            before { state_file.write(last_action: action) }

            it "calls destroy, create, converge, setup, verify, destroy" do
              driver.expects(:destroy)
              driver.expects(:create)
              driver.expects(:converge)
              driver.expects(:setup)
              driver.expects(:verify)
              driver.expects(:destroy)

              instance.test
            end
          end
        end

        describe "with destroy mode of never" do
          it "calls destroy, create, converge, setup, verify" do
            driver.expects(:destroy).once
            driver.expects(:create)
            driver.expects(:converge)
            driver.expects(:setup)
            driver.expects(:verify)

            instance.test(:never)
          end
        end

        describe "with destroy mode of always" do
          it "calls destroy at even when action fails" do
            driver.expects(:destroy)
            driver.expects(:create)
            driver.expects(:converge).raises(Kitchen::ActionFailed)
            driver.expects(:destroy)

            begin
              instance.test(:always)
            rescue # rubocop:disable Lint/HandleExceptions
            end
          end
        end
      end

      it "#login executes the driver's login_command" do
        state_file.write(last_action: "create")
        driver.stubs(:login_command).with(has_entries(last_action: "create"))
          .returns(Kitchen::LoginCommand.new("echo", ["hello"], purple: true))
        Kernel.expects(:exec).with("echo", "hello", { purple: true })

        instance.login
      end
    end
  end

  describe Kitchen::Instance::FSM do
    let(:fsm) { Kitchen::Instance::FSM }

    describe ".actions" do
      it "passing nils returns destroy" do
        _(fsm.actions(nil, nil)).must_equal [:destroy]
      end

      it "accepts a string for desired argument" do
        _(fsm.actions(nil, "create")).must_equal [:create]
      end

      it "accepts a symbol for desired argument" do
        _(fsm.actions(nil, :create)).must_equal [:create]
      end

      it "starting from no state to create returns create" do
        _(fsm.actions(nil, :create)).must_equal [:create]
      end

      it "starting from :create to create returns create" do
        _(fsm.actions(:create, :create)).must_equal [:create]
      end

      it "starting from no state to converge returns create, converge" do
        _(fsm.actions(nil, :converge)).must_equal %i{create converge}
      end

      it "starting from create to converge returns converge" do
        _(fsm.actions(:create, :converge)).must_equal [:converge]
      end

      it "starting from converge to converge returns converge" do
        _(fsm.actions(:converge, :converge)).must_equal [:converge]
      end

      it "starting from no state to setup returns create, converge, setup" do
        _(fsm.actions(nil, :setup)).must_equal %i{create converge setup}
      end

      it "starting from create to setup returns converge, setup" do
        _(fsm.actions(:create, :setup)).must_equal %i{converge setup}
      end

      it "starting from converge to setup returns setup" do
        _(fsm.actions(:converge, :setup)).must_equal [:setup]
      end

      it "starting from setup to setup return setup" do
        _(fsm.actions(:setup, :setup)).must_equal [:setup]
      end

      it "starting from no state to verify returns create, converge, setup, verify" do
        _(fsm.actions(nil, :verify)).must_equal %i{create converge setup verify}
      end

      it "starting from create to verify returns converge, setup, verify" do
        _(fsm.actions(:create, :verify)).must_equal %i{converge setup verify}
      end

      it "starting from converge to verify returns setup, verify" do
        _(fsm.actions(:converge, :verify)).must_equal %i{setup verify}
      end

      it "starting from setup to verify returns verify" do
        _(fsm.actions(:setup, :verify)).must_equal [:verify]
      end

      it "starting from verify to verify returns verify" do
        _(fsm.actions(:verify, :verify)).must_equal [:verify]
      end

      %i{verify setup converge}.each do |s|
        it "starting from #{s} to create returns create" do
          _(fsm.actions(s, :create)).must_equal [:create]
        end
      end

      %i{verify setup}.each do |s|
        it "starting from #{s} to converge returns converge" do
          _(fsm.actions(s, :converge)).must_equal [:converge]
        end
      end

      it "starting from verify to setup returns setup" do
        _(fsm.actions(:verify, :setup)).must_equal [:setup]
      end
    end
  end

  def regex_for(string)
    Regexp.new(Regexp.escape(string))
  end
end
