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

require_relative '../../spec_helper'
require 'logger'
require 'stringio'

require 'kitchen'

module Kitchen

  module Driver

    class Sneaky < Base

      def method_missing(meth, *args, &block)
        if meth.to_s.start_with?("invoke_")
          send(meth.to_s.sub(/^invoke_/, ''), *args)
        else
          super
        end
      end
    end

    class BubbleGum < Base

      default_config :cheese, "cheddar"
    end

    class StaticDefaults < Base

      default_config :beans, "kidney"
      default_config :tunables, 'flimflam' => 'positate'
      default_config :edible, true
      default_config :fetch_command, "curl"
      default_config :beans_url do |driver|
        "http://gim.me/#{driver[:beans]}"
      end
      default_config :command do |driver|
        "#{driver[:fetch_command]} #{driver[:beans_url]}"
      end
      default_config :fetch_url do |driver|
        "http://gim.me/beans-for/#{driver.instance.name}"
      end
    end

    class SubclassDefaults < StaticDefaults

      default_config :yea, "ya"
      default_config :fetch_command, "wget"
      default_config :fetch_url, "http://no.beans"
    end
  end
end

describe Kitchen::Driver::Base do

  let(:logged_output) { StringIO.new }
  let(:logger)        { Logger.new(logged_output) }
  let(:config)        { Hash.new }
  let(:state)         { Hash.new }

  let(:busser) do
    stub(:setup_cmd => "setup", :sync_cmd => "sync", :run_cmd => "run")
  end

  let(:instance) do
    stub(
      :name => "coolbeans",
      :logger => logger,
      :busser => busser,
      :to_str => "instance"
    )
  end

  let(:driver) do
    d = Kitchen::Driver::Sneaky.new(config)
    d.instance = instance
    d
  end

  it "#name returns the name of the driver" do
    Kitchen::Driver::BubbleGum.new(config).name.must_equal "BubbleGum"
  end

  describe "configuration" do

    describe "provided from the outside" do

      it "returns provided config" do
        config[:fruit] = %w{apples oranges}
        config[:cool_enough] = true

        driver[:fruit].must_equal %w{apples oranges}
        driver[:cool_enough].must_equal true
      end
    end

    describe "using static default_config statements" do

      let(:driver) do
        d = Kitchen::Driver::StaticDefaults.new(config)
        d.instance = instance
        d
      end

      it "uses defaults" do
        driver[:beans].must_equal "kidney"
        driver[:tunables]['flimflam'].must_equal 'positate'
        driver[:edible].must_equal true
      end

      it "uses provided config over default_config" do
        config[:beans] = "pinto"
        config[:edible] = false

        driver[:beans].must_equal "pinto"
        driver[:edible].must_equal false
      end

      it "uses other config values to compute values" do
        driver[:beans_url].must_equal "http://gim.me/kidney"
        driver[:command].must_equal "curl http://gim.me/kidney"
      end

      it "computed value blocks have access to instance object" do
        driver[:fetch_url].must_equal "http://gim.me/beans-for/coolbeans"
      end

      it "uses provided config over default_config for computed values" do
        config[:command] = "echo listentome"
        config[:beans] = "pinto"

        driver[:command].must_equal "echo listentome"
        driver[:beans_url].must_equal "http://gim.me/pinto"
      end
    end

    describe "using inherited static default_config statements" do

      let(:driver) do
        p = Kitchen::Driver::SubclassDefaults.new(config)
        p.instance = instance
        p
      end

      it "contains defaults from superclass" do
        driver[:beans].must_equal "kidney"
        driver[:tunables]['flimflam'].must_equal 'positate'
        driver[:edible].must_equal true
        driver[:yea].must_equal "ya"
      end

      it "uses provided config over default config" do
        config[:beans] = "pinto"
        config[:edible] = false

        driver[:beans].must_equal "pinto"
        driver[:edible].must_equal false
        driver[:yea].must_equal "ya"
        driver[:beans_url].must_equal "http://gim.me/pinto"
      end

      it "uses its own default_config over inherited default_config" do
        driver[:fetch_url].must_equal "http://no.beans"
        driver[:command].must_equal "wget http://gim.me/kidney"
      end
    end

    it "#config_keys returns an array of config key names" do
      driver = Kitchen::Driver::BubbleGum.new(:ice_cream => "dragon")

      driver.config_keys.sort.must_equal [:cheese, :ice_cream]
    end
  end

  [:create, :converge, :setup, :verify, :destroy].each do |action|

    it "has a #{action} method that takes state" do
      state = Hash.new
      driver.public_send(action, state).must_be_nil
    end
  end

  it "has a login command that raises ActionFailed by default" do
    proc { driver.login_command(Hash.new) }.must_raise Kitchen::ActionFailed
  end

  it "has a default verify dependencies method" do
    driver.verify_dependencies.must_be_nil
  end

  it "#diagnose returns an empty hash for no config" do
    driver.diagnose.must_equal Hash.new
  end

  it "#diagnose returns a hash of config" do
    config[:alpha] = "beta"
    driver.diagnose.must_equal({ :alpha => "beta" })
  end

  it "#diagnose returns a hash with sorted keys" do
    config[:zebra] = true
    config[:elephant] = true

    driver.diagnose.keys.must_equal [:elephant, :zebra]
  end

  describe "#logger" do

    before  { @klog = Kitchen.logger }
    after   { Kitchen.logger = @klog }

    it "returns the instance's logger if defined" do
      driver.invoke_logger.must_equal logger
    end

    it "returns the default logger if instance's logger is not set" do
      driver.instance = nil
      Kitchen.logger = "yep"

      driver.invoke_logger.must_equal Kitchen.logger
    end
  end

  it "#puts calls logger.info" do
    driver.invoke_puts "yo"

    logged_output.string.must_match /I, /
    logged_output.string.must_match /yo\n/
  end

  it "#print calls logger.info" do
    driver.invoke_print "yo"

    logged_output.string.must_match /I, /
    logged_output.string.must_match /yo\n/
  end

  it "#busser raises an exception if instance is nil" do
    driver.instance = nil

    proc { driver.invoke_busser }.must_raise Kitchen::ClientError
  end

  it "#busser returns the instance's busser" do
    driver.invoke_busser.must_equal busser
  end

  it "#busser_setup_cmd calls busser.setup_cmd" do
    driver.invoke_busser_setup_cmd.must_equal "setup"
  end

  it "#busser_sync_cmd calls busser.sync_cmd" do
    driver.invoke_busser_sync_cmd.must_equal "sync"
  end

  it "#busser_run_cmd calls busser.run_cmd" do
    driver.invoke_busser_run_cmd.must_equal "run"
  end
end
