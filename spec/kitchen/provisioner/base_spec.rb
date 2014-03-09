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
require 'stringio'

require 'kitchen'

module Kitchen

  module Provisioner

    class StaticDefaults < Base

      default_config :rank, "captain"
      default_config :tunables, "foo" => "fa"
      default_config :nice, true
    end

    class SubclassDefaults < StaticDefaults

      default_config :yea, "ya"
    end

    class ComputedDefaults < Base

      default_config :beans, "kidney"
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
  end
end

describe Kitchen::Provisioner::Base do

  let(:config)          { Hash.new }
  let(:logger_io)       { StringIO.new }
  let(:instance_logger) { Kitchen::Logger.new(:logdev => logger_io) }

  let(:instance) do
    stub(:name => "coolbeans", :logger => instance_logger)
  end

  let(:provisioner) do
    p = Kitchen::Provisioner::Base.new(config)
    p.instance = instance
    p
  end

  it "#instance returns its instance" do
    provisioner.instance.must_equal instance
  end

  it "#name returns its class name as a string" do
    provisioner.name.must_equal "Base"
  end

  describe "user config" do

    before do
      config[:animals] = %w{cats dogs}
      config[:coolness] = true
    end

    it "injects config into the provisioner" do
      provisioner[:animals].must_equal %w{cats dogs}
      provisioner[:coolness].must_equal true
    end

    it ":root_path defaults to /tmp/kitchen" do
      provisioner[:root_path].must_equal "/tmp/kitchen"
    end

    it ":sudo defaults to true" do
      provisioner[:sudo].must_equal true
    end

    it "#config_keys returns the config keys" do
      provisioner.config_keys.sort.
        must_equal [:animals, :coolness, :root_path, :sudo]
    end
  end

  describe ".default_config" do

    describe "static default config" do

      let(:provisioner) do
        p = Kitchen::Provisioner::StaticDefaults.new(config)
        p.instance = instance
        p
      end

      it "uses default config" do
        provisioner[:rank].must_equal "captain"
        provisioner[:tunables]["foo"].must_equal "fa"
        provisioner[:nice].must_equal true
      end

      it "uses user config over default config" do
        config[:rank] = "commander"
        config[:nice] = :maybe

        provisioner[:rank].must_equal "commander"
        provisioner[:tunables]["foo"].must_equal "fa"
        provisioner[:nice].must_equal :maybe
      end
    end

    describe "inherited static default config" do

      let(:provisioner) do
        p = Kitchen::Provisioner::SubclassDefaults.new(config)
        p.instance = instance
        p
      end

      it "contains defaults from superclass" do
        provisioner[:rank].must_equal "captain"
        provisioner[:tunables]["foo"].must_equal "fa"
        provisioner[:nice].must_equal true
        provisioner[:yea].must_equal "ya"
      end

      it "uses user config over default config" do
        config[:rank] = "commander"
        config[:nice] = :maybe

        provisioner[:rank].must_equal "commander"
        provisioner[:tunables]["foo"].must_equal "fa"
        provisioner[:nice].must_equal :maybe
        provisioner[:yea].must_equal "ya"
      end
    end

    describe "computed default config" do

      let(:provisioner) do
        p = Kitchen::Provisioner::ComputedDefaults.new(config)
        p.instance = instance
        p
      end

      it "uses computed config" do
        provisioner[:beans_url].must_equal "http://gim.me/kidney"
        provisioner[:command].must_equal "curl http://gim.me/kidney"
      end

      it "has access to instance object" do
        provisioner[:fetch_url].must_equal "http://gim.me/beans-for/coolbeans"
      end

      it "uses user config over default config" do
        config[:command] = "echo listentome"

        provisioner[:command].must_equal "echo listentome"
      end
    end
  end

  describe "#logger" do

    it "if instance is set, use its logger" do
      provisioner.send(:logger).must_equal instance_logger
    end

    it "if instance is not set, use Kitchen.logger" do
      provisioner.instance = nil
      provisioner.send(:logger).must_equal Kitchen.logger
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
