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
  let(:config)  { Kitchen::Config.new(:loader => loader) }

  before do
    FakeFS.activate!
    FileUtils.mkdir_p("/tmp")
  end

  after do
    FakeFS.deactivate!
    FakeFS::FileSystem.clear
  end

  describe "#platforms" do

    it "returns platforms loaded from a kitchen.yml" do
      stub_data!({ :platforms => [{ :name => 'one' }, { :name => 'two' }] })

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

    it "returns suites loaded from a kitchen.yml" do
      stub_data!({ :suites => [
        { :name => 'one', :run_list => [] },
        { :name => 'two', :run_list => [] },
      ] })

      config.suites.size.must_equal 2
      config.suites[0].name.must_equal 'one'
      config.suites[1].name.must_equal 'two'
    end

    it "returns an empty Array if no suites are given" do
      stub_data!({})

      config.suites.must_equal []
    end

    def cheflike_suite(suite)
      suite.extend(Kitchen::Suite::Cheflike)
    end

    it "returns a suite with nil for data_bags_path by default" do
      stub_data!({ :suites => [{ :name => 'one', :run_list => [] }] })
      cheflike_suite(config.suites.first).data_bags_path.must_be_nil
    end

    it "returns a suite with a common data_bags_path set" do
      stub_data!({ :suites => [{ :name => 'one', :run_list => [] }] })
      config.test_base_path = "/tmp/base"
      FileUtils.mkdir_p "/tmp/base/data_bags"

      cheflike_suite(config.suites.first).data_bags_path.
        must_equal "/tmp/base/data_bags"
    end

    it "returns a suite with a suite-specific data_bags_path set" do
      stub_data!({ :suites => [{ :name => 'cool', :run_list => [] }] })
      config.test_base_path = "/tmp/base"
      FileUtils.mkdir_p "/tmp/base/cool/data_bags"

      cheflike_suite(config.suites.first).data_bags_path.
        must_equal "/tmp/base/cool/data_bags"
    end

    it "returns a suite with a custom data_bags_path set" do
      stub_data!({ :suites => [{ :name => 'one', :run_list => [],
        :data_bags_path => 'shared/data_bags' }] })
      config.kitchen_root = "/tmp/base"
      FileUtils.mkdir_p "/tmp/base/shared/data_bags"

      cheflike_suite(config.suites.first).data_bags_path.
        must_equal "/tmp/base/shared/data_bags"
    end

    it "returns a suite with an absolute data_bags_path set" do
      stub_data!({ :suites => [{ :name => 'one', :run_list => [],
        :data_bags_path => '/shared/data_bags' }] })
      config.kitchen_root = "/tmp/base"
      FileUtils.mkdir_p "/shared/data_bags"
      FileUtils.mkdir_p "/tmp/base/shared/data_bags"

      cheflike_suite(config.suites.first).data_bags_path.
        must_equal "/shared/data_bags"
    end

    it "returns a suite with nil for roles_path by default" do
      stub_data!({ :suites => [{ :name => 'one', :run_list => [] }] })

      cheflike_suite(config.suites.first).roles_path.must_be_nil
    end

    it "returns a suite with a common roles_path set" do
      stub_data!({ :suites => [{ :name => 'one', :run_list => [] }] })
      config.test_base_path = "/tmp/base"
      FileUtils.mkdir_p "/tmp/base/roles"

      cheflike_suite(config.suites.first).roles_path.
        must_equal "/tmp/base/roles"
    end

    it "returns a suite with a suite-specific roles_path set" do
      stub_data!({ :suites => [{ :name => 'mysuite', :run_list => [] }] })
      config.test_base_path = "/tmp/base"
      FileUtils.mkdir_p "/tmp/base/mysuite/roles"

      cheflike_suite(config.suites.first).roles_path.
        must_equal "/tmp/base/mysuite/roles"
    end

    it "returns a suite with a custom roles_path set" do
      stub_data!({ :suites => [{ :name => 'one', :run_list => [],
        :roles_path => 'shared/roles' }] })
      config.kitchen_root = "/tmp/base"
      FileUtils.mkdir_p "/tmp/base/shared/roles"

      cheflike_suite(config.suites.first).roles_path.
        must_equal "/tmp/base/shared/roles"
    end

    it "returns a suite with nil for data_path by default" do
      stub_data!({ :suites => [{ :name => 'one', :run_list => [] }] })
      cheflike_suite(config.suites.first).data_path.must_be_nil
    end

    it "returns a suite with a common data_path set" do
      stub_data!({ :suites => [{ :name => 'one', :run_list => [] }] })
      config.test_base_path = "/tmp/base"
      FileUtils.mkdir_p "/tmp/base/data"

      cheflike_suite(config.suites.first).data_path.
        must_equal "/tmp/base/data"
    end

    it "returns a suite with a suite-specific data_path set" do
      stub_data!({ :suites => [{ :name => 'cool', :run_list => [] }] })
      config.test_base_path = "/tmp/base"
      FileUtils.mkdir_p "/tmp/base/cool/data"

      cheflike_suite(config.suites.first).data_path.
        must_equal "/tmp/base/cool/data"
    end

    it "returns a suite with a custom data_path set" do
      stub_data!({ :suites => [{ :name => 'one', :run_list => [],
        :data_path => 'shared/data' }] })
      config.kitchen_root = "/tmp/base"
      FileUtils.mkdir_p "/tmp/base/shared/data"

      cheflike_suite(config.suites.first).data_path.
        must_equal "/tmp/base/shared/data"
    end

    it "returns a suite with an absolute data_path set" do
      stub_data!({ :suites => [{ :name => 'one', :run_list => [],
        :data_path => '/shared/data' }] })
      config.kitchen_root = "/tmp/base"
      FileUtils.mkdir_p "/shared/data"
      FileUtils.mkdir_p "/tmp/base/shared/data"

      cheflike_suite(config.suites.first).data_path.
        must_equal "/shared/data"
    end

    it "returns a suite with nil for environments_path by default" do
      stub_data!({ :suites => [{ :name => 'one', :run_list => [] }] })
      cheflike_suite(config.suites.first).environments_path.must_be_nil
    end

    it "returns a suite with a common environments_path set" do
      stub_data!({ :suites => [{ :name => 'one', :run_list => [] }] })
      config.test_base_path = "/tmp/base"
      FileUtils.mkdir_p "/tmp/base/environments"

      cheflike_suite(config.suites.first).environments_path.
        must_equal "/tmp/base/environments"
    end

    it "returns a suite with a suite-specific environments_path set" do
      stub_data!({ :suites => [{ :name => 'cool', :run_list => [] }] })
      config.test_base_path = "/tmp/base"
      FileUtils.mkdir_p "/tmp/base/cool/environments"

      cheflike_suite(config.suites.first).environments_path.
        must_equal "/tmp/base/cool/environments"
    end

    it "returns a suite with a custom environments_path set" do
      stub_data!({ :suites => [{ :name => 'one', :run_list => [],
        :environments_path => 'shared/environments' }] })
      config.kitchen_root = "/tmp/base"
      FileUtils.mkdir_p "/tmp/base/shared/environments"

      cheflike_suite(config.suites.first).environments_path.
        must_equal "/tmp/base/shared/environments"
    end

    it "returns a suite with an absolute environments_path set" do
      stub_data!({ :suites => [{ :name => 'one', :run_list => [],
        :environments_path => '/shared/environments' }] })
      config.kitchen_root = "/tmp/base"
      FileUtils.mkdir_p "/shared/environments"
      FileUtils.mkdir_p "/tmp/base/shared/environments"

      cheflike_suite(config.suites.first).environments_path.
        must_equal "/shared/environments"
    end
  end

  describe "#instances" do

    it "returns instances loaded from a kitchen.yml" do
      stub_data!({
        :platforms => [
          { :name => 'p1' },
          { :name => 'p2' },
        ],
        :suites => [
          { :name => 's1', :run_list => [] },
          { :name => 's2', :run_list => [] },
          { :name => 's3', :run_list => [], :excludes => ['p1'] }
        ]
      })
      config.instances.size.must_equal 5
      instance_names = config.instances.map { |i| i.name }
      instance_names.must_equal %w{s1-p1 s1-p2 s2-p1 s2-p2 s3-p2}
    end

    it "returns an instance containing a driver instance" do
      stub_data!({
        :platforms => [{ :name => 'platform', :driver_plugin => 'dummy' }],
        :suites => [{ :name => 'suite', :run_list => [] }]
      })
      config.instances.first.driver.must_be_instance_of Kitchen::Driver::Dummy
    end

    it "returns an instance with a driver initialized with kitchen_root" do
      config.kitchen_root = "/tmp"
      stub_data!({
        :platforms => [{ :name => 'platform', :driver_plugin => 'dummy' }],
        :suites => [{ :name => 'suite', :run_list => [] }]
      })
      config.instances.first.driver[:kitchen_root].must_equal "/tmp"
    end

    it "returns an instance with a driver initialized with passed in config" do
      stub_data!({
        :platforms => [
          { :name => 'platform', :driver_plugin => 'dummy',
            :driver_config => { :foo => 'bar' }
          }
        ],
        :suites => [{ :name => 'suite', :run_list => [] }]
      })
      config.instances.first.driver[:foo].must_equal "bar"
    end
  end

  describe "#log_level" do

    it "returns a default log_level of info" do
      config.log_level.must_equal :info
    end

    it "returns an overridden log_level" do
      config.log_level = :error
      config.log_level.must_equal :error
    end
  end

  private

  def stub_data!(hash)
    loader.data = hash
  end
end
