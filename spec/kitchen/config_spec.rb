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

require_relative '../spec_helper'

require 'kitchen'
require 'kitchen/logging'
require 'kitchen/collection'
require 'kitchen/config'
require 'kitchen/driver'
require 'kitchen/instance'
require 'kitchen/platform'
require 'kitchen/provisioner'
require 'kitchen/suite'
require 'kitchen/util'

module Kitchen

  class DummyLoader

    def read
      @data || Hash.new
    end

    def data=(hash)
      @data = hash
    end
  end
end

describe Kitchen::Config do

  let(:loader)  { Kitchen::DummyLoader.new }
  let(:config)  { Kitchen::Config.new(opts) }

  let(:opts) do
    { :loader => loader, :kitchen_root => "/tmp/that/place",
      :log_root => "/tmp/logs", :test_base_path => "/testing/yo",
      :log_level => :debug }
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

  describe "#platforms" do

    it "returns an array of platforms" do
      stub_data!(
        :platforms => [
          { :name => 'one' },
          { :name => 'two' }
        ]
      )

      config.platforms.size.must_equal 2
      config.platforms[0].name.must_equal 'one'
      config.platforms[1].name.must_equal 'two'
    end

    it "returns an empty Array if no platforms are given" do
      stub_data!({})

      config.platforms.must_equal []
    end
  end

  describe "#suites" do

    it "returns an array of suites" do
      stub_data!(
        :suites => [
          { :name => 'one' },
          { :name => 'two' }
        ]
      )

      config.suites.size.must_equal 2
      config.suites[0].name.must_equal 'one'
      config.suites[1].name.must_equal 'two'
    end

    it "returns an empty Array if no suites are given" do
      stub_data!({})

      config.suites.must_equal []
    end
  end

  describe "#instances" do

    it "returns an empty Array if no suites and platforms are given" do
      stub_data!({})

      config.instances.must_equal []
    end

    it "returns an array of instances" do
      skip "much more needed here"

      stub_data!(
        :platforms => [
          { :name => "p1" },
          { :name => "p2" }
        ],
        :suites => [
          { :name => 's1' },
          { :name => 's2' }
        ]
      )

      config.instances
    end
  end

  def stub_data!(hash)
    loader.data = hash
  end
end
