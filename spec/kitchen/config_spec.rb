# -*- encoding: utf-8 -*-
#
# Author:: Fletcher Nichol (<fnichol@nichol.ca>)
#
# Copyright (C) 2012, Fletcher Nichol
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

require "kitchen"
require "kitchen/logging"
require "kitchen/collection"
require "kitchen/config"
require "kitchen/driver"
require "kitchen/instance"
require "kitchen/platform"
require "kitchen/provisioner"
require "kitchen/suite"
require "kitchen/transport"
require "kitchen/util"
require "kitchen/verifier"

module Kitchen

  class DummyLoader

    attr_writer :data

    def read
      @data || Hash.new
    end
  end

end

describe Kitchen::Config do
  # Explicitly enable tty to test colorize default option later
  before do
    Kitchen.stubs(:tty?).returns(true)
  end

  let(:loader)  { Kitchen::DummyLoader.new }
  let(:config)  { Kitchen::Config.new(opts) }

  let(:opts) do
    {
      :loader         => loader,
      :kitchen_root   => "/tmp/that/place",
      :log_root       => "/tmp/logs",
      :test_base_path => "/testing/yo",
      :log_level      => :debug,
      :log_overwrite  => false,
      :colorize       => false
    }
  end

  let(:default_kitchen_config) do
    {
      :defaults => {
        :driver => "dummy",
        :provisioner => "chef_solo",
        :transport => "ssh",
        :verifier => "busser"
      },
      :kitchen_root => "/tmp/that/place",
      :test_base_path => "/testing/yo",
      :log_level => :debug,
      :log_overwrite  => false,
      :colorize => false
    }
  end

  describe "#loader" do

    it "returns its loader" do
      config.loader.must_equal loader
    end

    it "creates a Kitchen::Loader::YAML loader by default" do
      opts.delete(:loader)

      config.loader.must_be_kind_of Kitchen::Loader::YAML
    end
  end

  describe "#kitchen_root" do

    it "returns its kitchen root" do
      config.kitchen_root.must_equal "/tmp/that/place"
    end

    it "uses Dir.pwd by default" do
      opts.delete(:kitchen_root)

      config.kitchen_root.must_equal Dir.pwd
    end
  end

  describe "#log_root" do

    it "returns its log root" do
      config.log_root.must_equal "/tmp/logs"
    end

    it "calculates a default log root using kitchen_root" do
      opts.delete(:log_root)

      config.log_root.must_equal "/tmp/that/place/.kitchen/logs"
    end
  end

  describe "#test_base_path" do

    it "returns its base test path" do
      config.test_base_path.must_equal "/testing/yo"
    end

    it "calculates a default base using kitchen_root" do
      opts.delete(:test_base_path)

      config.test_base_path.must_equal "/tmp/that/place/test/integration"
    end
  end

  describe "#log_level" do

    it "returns its log level" do
      config.log_level.must_equal :debug
    end

    it "uses :info by default" do
      opts.delete(:log_level)

      config.log_level.must_equal :info
    end
  end

  describe "#log_overwrite" do

    it "returns its log level" do
      config.log_overwrite.must_equal false
    end

    it "uses :info by default" do
      opts.delete(:log_overwrite)

      config.log_overwrite.must_equal true
    end
  end

  describe "#colorize" do

    it "returns its colorize" do
      config.colorize.must_equal false
    end

    it "uses true by default" do
      opts.delete(:colorize)

      config.colorize.must_equal true
    end
  end

  describe "#platforms" do

    before do
      Kitchen::DataMunger.stubs(:new).returns(munger)
      Kitchen::Platform.stubs(:new).returns("platform")
    end

    let(:munger) do
      stub(
        :platform_data => [{ :one => "a" }, { :two => "b" }]
      )
    end

    it "loader loads data" do
      loader.expects(:read).returns(Hash.new)

      config.platforms
    end

    it "constructs a munger with loader data and defaults" do
      loader.stubs(:read).returns("datum")

      Kitchen::DataMunger.expects(:new).with { |data, kitchen_config|
        data.must_equal "datum"
        kitchen_config.is_a?(Hash).must_equal true
      }.returns(munger)

      config.platforms
    end

    it "platform_data is called on munger" do
      munger.expects(:platform_data).returns([])

      config.platforms
    end

    it "contructs Platform objects" do
      Kitchen::Platform.expects(:new).with(:one => "a")
      Kitchen::Platform.expects(:new).with(:two => "b")

      config.platforms
    end

    it "returns a Collection of platforms" do
      Kitchen::Platform.stubs(:new).
        with(:one => "a").returns(stub(:name => "one"))
      Kitchen::Platform.stubs(:new).
        with(:two => "b").returns(stub(:name => "two"))

      config.platforms.as_names.must_equal %w[one two]
    end
  end

  describe "#suites" do

    before do
      Kitchen::DataMunger.stubs(:new).returns(munger)
      Kitchen::Suite.stubs(:new).returns("suite")
    end

    let(:munger) do
      stub(
        :suite_data => [{ :one => "a" }, { :two => "b" }]
      )
    end

    it "loader loads data" do
      loader.expects(:read).returns(Hash.new)

      config.suites
    end

    it "constucts a munger with loader data and defaults" do
      loader.stubs(:read).returns("datum")

      Kitchen::DataMunger.expects(:new).with { |data, kitchen_config|
        data.must_equal "datum"
        kitchen_config.is_a?(Hash).must_equal true
      }.returns(munger)

      config.suites
    end

    it "platform_data is called on munger" do
      munger.expects(:suite_data).returns([])

      config.suites
    end

    it "contructs Suite objects" do
      Kitchen::Suite.expects(:new).with(:one => "a")
      Kitchen::Suite.expects(:new).with(:two => "b")

      config.suites
    end

    it "returns a Collection of suites" do
      Kitchen::Suite.stubs(:new).
        with(:one => "a").returns(stub(:name => "one"))
      Kitchen::Suite.stubs(:new).
        with(:two => "b").returns(stub(:name => "two"))

      config.suites.as_names.must_equal %w[one two]
    end
  end

  describe "#instances" do

    let(:platforms) do
      [stub(:name => "unax")]
    end

    let(:suites) do
      [stub(:name => "tiny", :includes => [], :excludes => [])]
    end

    let(:munger) do
      stub(
        :driver_data_for => { "junk" => true },
        :provisioner_data_for => { "junk" => true },
        :transport_data_for => { "junk" => true },
        :verifier_data_for => { "junk" => true }
      )
    end

    before do
      Kitchen::Instance.stubs(:new).returns("instance")
      Kitchen::Driver.stubs(:for_plugin).returns("driver")
      Kitchen::Provisioner.stubs(:for_plugin).returns("provisioner")
      Kitchen::Transport.stubs(:for_plugin).returns("transport")
      Kitchen::Verifier.stubs(:for_plugin).returns("verifier")
      Kitchen::Logger.stubs(:new).returns("logger")
      Kitchen::StateFile.stubs(:new).returns("state_file")

      Kitchen::DataMunger.stubs(:new).returns(munger)
      config.stubs(:platforms).returns(platforms)
      config.stubs(:suites).returns(suites)
    end

    it "constructs a Driver object" do
      munger.expects(:driver_data_for).with("tiny", "unax").
        returns(:name => "drivey", :datum => "lots")
      Kitchen::Driver.unstub(:for_plugin)
      Kitchen::Driver.expects(:for_plugin).
        with("drivey", :name => "drivey", :datum => "lots")

      config.instances
    end

    it "constructs a Provisioner object" do
      munger.expects(:provisioner_data_for).with("tiny", "unax").
        returns(:name => "provey", :datum => "lots")
      Kitchen::Provisioner.unstub(:for_plugin)
      Kitchen::Provisioner.expects(:for_plugin).
        with("provey", :name => "provey", :datum => "lots")

      config.instances
    end

    it "constructs a Transport object" do
      munger.expects(:transport_data_for).with("tiny", "unax").
        returns(:name => "transey", :datum => "lots")
      Kitchen::Transport.unstub(:for_plugin)
      Kitchen::Transport.expects(:for_plugin).
        with("transey", :name => "transey", :datum => "lots")

      config.instances
    end

    it "constructs a Verifier object" do
      munger.expects(:verifier_data_for).with("tiny", "unax").
        returns(:name => "vervey", :datum => "lots")
      Kitchen::Verifier.unstub(:for_plugin)
      Kitchen::Verifier.expects(:for_plugin).
        with("vervey", :name => "vervey", :datum => "lots")

      config.instances
    end

    it "constructs a Logger object" do
      Kitchen::Logger.unstub(:new)
      Kitchen::Logger.expects(:new).with(
        :stdout => STDOUT,
        :color => :cyan,
        :logdev => "/tmp/logs/tiny-unax.log",
        :log_overwrite => false,
        :level => 0,
        :progname => "tiny-unax",
        :colorize => false
      )

      config.instances
    end

    it "constructs a StateFile object" do
      Kitchen::StateFile.unstub(:new)
      Kitchen::StateFile.expects(:new).with("/tmp/that/place", "tiny-unax")

      config.instances
    end

    it "constructs an Instance object from all built objects" do
      Kitchen::Instance.unstub(:new)

      Kitchen::Instance.expects(:new).with(
        :driver => "driver",
        :logger => "logger",
        :suite => suites.first,
        :platform => platforms.first,
        :provisioner => "provisioner",
        :transport => "transport",
        :verifier => "verifier",
        :state_file => "state_file"
      )

      config.instances
    end
  end

  describe "using Suite#includes" do

    it "selects only platforms in a suite's includes array" do
      config.stubs(:platforms).returns([
        stub(:name => "good"),
        stub(:name => "nope"),
        stub(:name => "one")
      ])
      config.stubs(:suites).returns([
        stub(:name => "selecta", :includes => %w[good one], :excludes => []),
        stub(:name => "allem", :includes => [], :excludes => [])
      ])

      config.instances.as_names.must_equal [
        "selecta-good", "selecta-one", "allem-good", "allem-nope", "allem-one"]
    end
  end

  describe "using Suite#excludes" do

    it "selects only platforms in a suite's includes array" do
      config.stubs(:platforms).returns([
        stub(:name => "good"),
        stub(:name => "nope"),
        stub(:name => "one")
      ])
      config.stubs(:suites).returns([
        stub(:name => "selecta", :includes => [], :excludes => ["nope"]),
        stub(:name => "allem", :includes => [], :excludes => [])
      ])

      config.instances.as_names.must_equal [
        "selecta-good", "selecta-one", "allem-good", "allem-nope", "allem-one"]
    end
  end
end
