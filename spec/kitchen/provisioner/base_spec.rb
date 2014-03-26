# -*- encoding: utf-8 -*-
#
# Author:: Fletcher Nichol (<fnichol@nichol.ca>)
#
# Copyright (C) 2013, Fletcher Nichol
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

  module Provisioner

    class Tiny < Base

      default_config :cheese, "cheddar"
    end

    class StaticDefaults < Base

      default_config :beans, "kidney"
      default_config :tunables, 'flimflam' => 'positate'
      default_config :edible, true
      default_config :fetch_command, "curl"
      default_config :beans_url do |provisioner|
        "http://gim.me/#{provisioner[:beans]}"
      end
      default_config :command do |provisioner|
        "#{provisioner[:fetch_command]} #{provisioner[:beans_url]}"
      end
      default_config :fetch_url do |provisioner|
        "http://gim.me/beans-for/#{provisioner.instance.name}"
      end
    end

    class SubclassDefaults < StaticDefaults

      default_config :yea, "ya"
      default_config :fetch_command, "wget"
      default_config :fetch_url, "http://no.beans"
    end
  end
end

describe Kitchen::Provisioner::Base do

  let(:logged_output)   { StringIO.new }
  let(:logger)          { Logger.new(logged_output) }
  let(:config)          { Hash.new }

  let(:instance) do
    stub(:name => "coolbeans", :logger => logger)
  end

  let(:provisioner) do
    p = Kitchen::Provisioner::Base.new(config)
    p.instance = instance
    p
  end

  it "#instance returns its instance" do
    provisioner.instance.must_equal instance
  end

  it "#name returns the name of the provisioner" do
    provisioner.name.must_equal "Base"
  end

  describe "configuration" do

    it ":root_path defaults to /tmp/kitchen" do
      provisioner[:root_path].must_equal "/tmp/kitchen"
    end

    it ":sudo defaults to true" do
      provisioner[:sudo].must_equal true
    end

    describe "provided from the outside" do

      it "returns provided config" do
        config[:fruit] = %w{apples oranges}
        config[:cool_enough] = true

        provisioner[:fruit].must_equal %w{apples oranges}
        provisioner[:cool_enough].must_equal true
      end
    end

    describe "using static default_config statements" do

      let(:provisioner) do
        p = Kitchen::Provisioner::StaticDefaults.new(config)
        p.instance = instance
        p
      end

      it "uses defaults" do
        provisioner[:beans].must_equal "kidney"
        provisioner[:tunables]['flimflam'].must_equal 'positate'
        provisioner[:edible].must_equal true
      end

      it "uses provided config over default_config" do
        config[:beans] = "pinto"
        config[:edible] = false

        provisioner[:beans].must_equal "pinto"
        provisioner[:edible].must_equal false
      end

      it "uses other config values to compute values" do
        provisioner[:beans_url].must_equal "http://gim.me/kidney"
        provisioner[:command].must_equal "curl http://gim.me/kidney"
      end

      it "computed value blocks have access to instance object" do
        provisioner[:fetch_url].must_equal "http://gim.me/beans-for/coolbeans"
      end

      it "uses provided config over default_config for computed values" do
        config[:command] = "echo listentome"
        config[:beans] = "pinto"

        provisioner[:command].must_equal "echo listentome"
        provisioner[:beans_url].must_equal "http://gim.me/pinto"
      end
    end

    describe "using inherited static default_config statements" do

      let(:provisioner) do
        p = Kitchen::Provisioner::SubclassDefaults.new(config)
        p.instance = instance
        p
      end

      it "contains defaults from superclass" do
        provisioner[:beans].must_equal "kidney"
        provisioner[:tunables]['flimflam'].must_equal 'positate'
        provisioner[:edible].must_equal true
        provisioner[:yea].must_equal "ya"
      end

      it "uses provided config over default config" do
        config[:beans] = "pinto"
        config[:edible] = false

        provisioner[:beans].must_equal "pinto"
        provisioner[:edible].must_equal false
        provisioner[:yea].must_equal "ya"
        provisioner[:beans_url].must_equal "http://gim.me/pinto"
      end

      it "uses its own default_config over inherited default_config" do
        provisioner[:fetch_url].must_equal "http://no.beans"
        provisioner[:command].must_equal "wget http://gim.me/kidney"
      end
    end

    it "#config_keys returns an array of config key names" do
      provisioner = Kitchen::Provisioner::Tiny.new(:ice_cream => "dragon")

      provisioner.config_keys.sort.
        must_equal [:cheese, :ice_cream, :root_path, :sudo]
    end
  end

  describe "#diagnose" do

    it "returns an empty hash for no config" do
      provisioner.diagnose.must_equal({
        :root_path => "/tmp/kitchen", :sudo => true
      })
    end

    it "returns a hash of config" do
      config[:alpha] = "beta"
      provisioner.diagnose.must_equal({
        :alpha => "beta", :root_path => "/tmp/kitchen", :sudo => true
      })
    end

    it "returns a hash with sorted keys" do
      config[:zebra] = true
      config[:elephant] = true

      provisioner.diagnose.keys.
        must_equal [:elephant, :root_path, :sudo, :zebra]
    end
  end

  describe "#logger" do

    before  { @klog = Kitchen.logger }
    after   { Kitchen.logger = @klog }

    it "returns the instance's logger if defined" do
      provisioner.send(:logger).must_equal logger
    end

    it "returns the default logger if instance's logger is not set" do
      provisioner.instance = nil
      Kitchen.logger = "yep"

      provisioner.send(:logger).must_equal Kitchen.logger
    end
  end

  [:init_command, :install_command, :prepare_command, :run_command].each do |cmd|

    it "has a #{cmd} method" do
      provisioner.public_send(cmd).must_be_nil
    end
  end

  describe "#sudo" do

    it "if :sudo is set, prepend sudo command" do
      config[:sudo] = true

      provisioner.send(:sudo, "wakka").must_equal("sudo -E wakka")
    end

    it "if :sudo is falsy, do not include sudo command" do
      config[:sudo] = false

      provisioner.send(:sudo, "wakka").must_equal("wakka")
    end
  end
end
