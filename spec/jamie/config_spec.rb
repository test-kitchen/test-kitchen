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

describe Jamie::Config do
  include FakeFS::SpecHelpers

  let(:config) { Jamie::Config.new("/tmp/.jamie.yml") }

  before do
    FileUtils.mkdir_p("/tmp")
  end

  describe "#platforms" do

    it "returns platforms loaded from a jamie.yml" do
      stub_yaml!({'platforms' => [ { 'name' => 'one' }, { 'name' => 'two' } ]})
      config.platforms.size.must_equal 2
      config.platforms[0].name.must_equal 'one'
      config.platforms[1].name.must_equal 'two'
    end

    it "returns an empty Array if no platforms are given" do
      stub_yaml!({})
      config.platforms.must_equal []
    end
  end

  describe "#suites" do

    it "returns suites loaded from a jamie.yml" do
      stub_yaml!({'suites' => [
        { 'name' => 'one', 'run_list' => [] },
        { 'name' => 'two', 'run_list' => [] },
      ]})
      config.suites.size.must_equal 2
      config.suites[0].name.must_equal 'one'
      config.suites[1].name.must_equal 'two'
    end

    it "returns an empty Array if no suites are given" do
      stub_yaml!({})
      config.suites.must_equal []
    end

    it "returns a suite with nil for data_bags_path by default" do
      stub_yaml!({'suites' => [ { 'name' => 'one', 'run_list' => [] } ]})
      config.suites.first.data_bags_path.must_be_nil
    end

    it "retuns a suite with a common data_bags_path set" do
      stub_yaml!({'suites' => [ { 'name' => 'one', 'run_list' => [] } ]})
      config.test_base_path = "/tmp/base"
      FileUtils.mkdir_p "/tmp/base/data_bags"
      config.suites.first.data_bags_path.must_equal "/tmp/base/data_bags"
    end

    it "retuns a suite with a suite-specific data_bags_path set" do
      stub_yaml!({'suites' => [ { 'name' => 'cool', 'run_list' => [] } ]})
      config.test_base_path = "/tmp/base"
      FileUtils.mkdir_p "/tmp/base/cool/data_bags"
      config.suites.first.data_bags_path.must_equal "/tmp/base/cool/data_bags"
    end

    it "returns a suite with nil for roles_path by default" do
      stub_yaml!({'suites' => [ { 'name' => 'one', 'run_list' => [] } ]})
      config.suites.first.roles_path.must_be_nil
    end

    it "returns a suite with a common roles_path set" do
      stub_yaml!({'suites' => [ { 'name' => 'one', 'run_list' => [] } ]})
      config.test_base_path = "/tmp/base"
      FileUtils.mkdir_p "/tmp/base/roles"
      config.suites.first.roles_path.must_equal "/tmp/base/roles"
    end

    it "returns a suite with a suite-specific roles_path set" do
      stub_yaml!({'suites' => [ { 'name' => 'mysuite', 'run_list' => [] } ]})
      config.test_base_path = "/tmp/base"
      FileUtils.mkdir_p "/tmp/base/mysuite/roles"
      config.suites.first.roles_path.must_equal "/tmp/base/mysuite/roles"
    end
  end

  describe "#instances" do

    it "returns instances loaded from a jamie.yml" do
      stub_yaml!({
        'platforms' => [
          { 'name' => 'p1' },
          { 'name' => 'p2' },
        ],
        'suites' => [
          { 'name' => 's1', 'run_list' => [] },
          { 'name' => 's2', 'run_list' => [] },
        ]
      })
      config.instances.size.must_equal 4
      config.instances.map { |i| i.name }.must_equal %w{s1-p1 s1-p2 s2-p1 s2-p2}
    end

    it "returns an instance containing a driver instance" do
      stub_yaml!({
        'platforms' => [ { 'name' => 'platform', 'driver_plugin' => 'dummy' } ],
        'suites' => [ { 'name' => 'suite', 'run_list' => [] }]
      })
      config.instances.first.driver.must_be_instance_of Jamie::Driver::Dummy
    end

    it "returns an instance with a driver initialized with jamie_root" do
      stub_yaml!({
        'platforms' => [ { 'name' => 'platform', 'driver_plugin' => 'dummy' } ],
        'suites' => [ { 'name' => 'suite', 'run_list' => [] }]
      })
      config.instances.first.driver[:jamie_root].must_equal "/tmp"
    end

    it "returns an instance with a driver initialized with passed in config" do
      stub_yaml!({
        'platforms' => [
          { 'name' => 'platform', 'driver_plugin' => 'dummy',
            'driver_config' => { 'foo' => 'bar' } }
        ],
        'suites' => [ { 'name' => 'suite', 'run_list' => [] }]
      })
      config.instances.first.driver[:foo].must_equal "bar"
    end
  end

  describe "jamie.local.yml" do

    it "merges in configuration with jamie.yml" do
      stub_yaml!(".jamie.yml", {
        'platforms' => [ { 'name' => 'p1', 'driver_plugin' => 'dummy' } ],
        'suites' => [ { 'name' => 's1', 'run_list' => [] } ]
      })
      stub_yaml!(".jamie.local.yml", {
        'driver_config' => { 'foo' => 'bar' }
      })
      config.instances.first.driver[:foo].must_equal 'bar'
    end

    it "merges over configuration in jamie.yml" do
      stub_yaml!(".jamie.yml", {
        'driver_config' => { 'foo' => 'nope' },
        'platforms' => [ { 'name' => 'p1', 'driver_plugin' => 'dummy' } ],
        'suites' => [ { 'name' => 's1', 'run_list' => [] } ]
      })
      stub_yaml!(".jamie.local.yml", {
        'driver_config' => { 'foo' => 'bar' }
      })
      config.instances.first.driver[:foo].must_equal 'bar'
    end
  end

  describe "erb filtering" do

    it "evaluates jamie.yml through erb before loading" do
      FileUtils.mkdir_p "/tmp"
      File.open("/tmp/.jamie.yml", "wb") do |f|
        f.write <<-YAML.gsub(/^ {10}/, '')
          ---
          driver_plugin: dummy
          platforms:
          - name: <%= "AHH".downcase + "choo" %>
        YAML
      end
      config.platforms.first.name.must_equal "ahhchoo"
    end

    it "evaluates jamie.local.yml through erb before loading" do
      stub_yaml!({
        'platforms' => [ { 'name' => 'p1', 'driver_plugin' => 'dummy' } ],
        'suites' => [ { 'name' => 's1', 'run_list' => [] } ]
      })
      FileUtils.mkdir_p "/tmp"
      File.open("/tmp/.jamie.local.yml", "wb") do |f|
        f.write <<-YAML.gsub(/^ {10}/, '')
          ---
          driver_config:
          <% %w{noodle mushroom}.each do |kind| %>
            <%= kind %>: soup
          <% end %>
        YAML
      end
      config.instances.first.driver[:noodle].must_equal "soup"
      config.instances.first.driver[:mushroom].must_equal "soup"
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

  def stub_yaml!(name = ".jamie.yml", hash)
    FileUtils.mkdir_p "/tmp"
    File.open("/tmp/#{name}", "wb") { |f| f.write(hash.to_yaml) }
  end
end
