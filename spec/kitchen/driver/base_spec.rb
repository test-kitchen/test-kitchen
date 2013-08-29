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

    class StaticDefaults < Base

      default_config :beans, "kidney"
      default_config :tunables, { 'flimflam' => 'positate' }
      default_config :edible, true
    end

    class ComputedDefaults < Base

      default_config :beans, "kidney"
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
  end
end

describe Kitchen::Driver::Base do

  let(:logged_output) { StringIO.new }
  let(:logger)        { Logger.new(logged_output) }
  let(:config)        { Hash.new }
  let(:state)         { Hash.new }

  let(:instance) do
    stub(:name => "coolbeans", :logger => logger, :to_str => "instance")
  end

  describe "user config" do

    let(:driver) do
      d = Kitchen::Driver::Base.new(config)
      d.instance = instance
      d
    end

    it "injects config into driver" do
      config[:fruit] = %w{apples oranges}
      config[:cool_enough] = true

      driver[:fruit].must_equal ['apples', 'oranges']
      driver[:cool_enough].must_equal true
    end
  end

  describe "static default config" do

    let(:driver) do
      d = Kitchen::Driver::StaticDefaults.new(config)
      d.instance = instance
      d
    end

    it "uses default config" do
      driver[:beans].must_equal "kidney"
      driver[:tunables]['flimflam'].must_equal 'positate'
      driver[:edible].must_equal true
    end

    it "uses user config over default config" do
      config[:beans] = "pinto"
      config[:edible] = false

      driver[:beans].must_equal "pinto"
      driver[:edible].must_equal false
    end
  end

  describe "computed default config" do

    let(:driver) do
      d = Kitchen::Driver::ComputedDefaults.new(config)
      d.instance = instance
      d
    end

    it "uses computed config" do
      driver[:beans_url].must_equal "http://gim.me/kidney"
      driver[:command].must_equal "curl http://gim.me/kidney"
    end

    it "has access to instance object" do
      driver[:fetch_url].must_equal "http://gim.me/beans-for/coolbeans"
    end

    it "uses user config over default config" do
      config[:command] = "echo listentome"

      driver[:command].must_equal "echo listentome"
    end
  end
end
