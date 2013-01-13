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

require 'simplecov'
SimpleCov.adapters.define 'gem' do
  command_name 'Specs'

  add_filter '/spec/'
  add_filter '/lib/vendor/'

  add_group 'Libraries', '/lib/'
end
SimpleCov.start 'gem'

require 'fakefs/spec_helpers'
require 'logger'
require 'minitest/autorun'
require 'ostruct'
require 'stringio'

require 'jamie'
require 'jamie/driver/dummy'

# Nasty hack to redefine IO.read in terms of File#read for fakefs
class IO
  def self.read(*args)
    File.open(args[0], "rb") { |f| f.read(args[1]) }
  end
end

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

describe Jamie::Config::Collection do

  let(:collection) do
    Jamie::Config::Collection.new([
      obj('one'), obj('two', 'a'), obj('two', 'b'), obj('three')
    ])
  end

  it "transparently wraps an Array" do
    collection.must_be_instance_of Array
  end

  describe "#get" do

    it "returns a single object by its name" do
      collection.get('three').must_equal obj('three')
    end

    it "returns the first occurance of an object by its name" do
      collection.get('two').must_equal obj('two', 'a')
    end

    it "returns nil if an object cannot be found by its name" do
      collection.get('nope').must_be_nil
    end
  end

  describe "#get_all" do

    it "returns a Collection of objects whose name matches the regex" do
      result = collection.get_all(/(one|three)/)
      result.size.must_equal 2
      result[0].must_equal obj('one')
      result[1].must_equal obj('three')
      result.get_all(/one/).size.must_equal 1
    end

    it "returns an empty Collection if on matches are found" do
      result = collection.get_all(/noppa/)
      result.must_equal []
      result.get("nahuh").must_be_nil
    end
  end

  describe "#as_name" do

    it "returns an Array of names as strings" do
      collection.as_names.must_equal %w{one two two three}
    end
  end

  private

  def obj(name, extra = nil)
    OpenStruct.new(:name => name, :extra => extra)
  end
end

describe Jamie::Suite do

  let(:opts) do ; { :name => 'suitezy', :run_list => [ 'doowah' ] } ; end
  let(:suite) { Jamie::Suite.new(opts) }

  it "raises an ArgumentError if name is missing" do
    opts.delete(:name)
    proc { Jamie::Suite.new(opts) }.must_raise Jamie::ClientError
  end

  it "raises an ArgumentError if run_list is missing" do
    opts.delete(:run_list)
    proc { Jamie::Suite.new(opts) }.must_raise Jamie::ClientError
  end

  it "returns an empty Hash given no attributes" do
    suite.attributes.must_equal Hash.new
  end

  it "returns nil given no data_bags_path" do
    suite.data_bags_path.must_be_nil
  end

  it "returns nil given no roles_path" do
    suite.roles_path.must_be_nil
  end

  it "returns attributes from constructor" do
    opts.merge!({ :attributes => { :a => 'b' }, :data_bags_path => 'crazy',
                  :roles_path => 'town' })
    suite.name.must_equal 'suitezy'
    suite.run_list.must_equal [ 'doowah' ]
    suite.attributes.must_equal({ :a => 'b' })
    suite.data_bags_path.must_equal 'crazy'
    suite.roles_path.must_equal 'town'
  end
end

describe Jamie::Platform do

  let(:opts) do ; { :name => 'plata' } ; end
  let(:platform) { Jamie::Platform.new(opts) }

  it "raises an ArgumentError if name is missing" do
    opts.delete(:name)
    proc { Jamie::Platform.new(opts) }.must_raise Jamie::ClientError
  end

  it "returns an empty Array given no run_list" do
    platform.run_list.must_equal []
  end

  it "returns an empty Hash given no attributes" do
    platform.attributes.must_equal Hash.new
  end

  it "returns attributes from constructor" do
    opts.merge!({ :run_list => [ 'a', 'b' ], :attributes => { :c => 'd' }})
    platform.name.must_equal 'plata'
    platform.run_list.must_equal [ 'a', 'b' ]
    platform.attributes.must_equal({ :c => 'd' })
  end
end

describe Jamie::Instance do

  let(:suite) do
    Jamie::Suite.new({ :name => 'suite',
      :run_list => 'suite_list', :attributes => { :s => 'ss' } })
  end

  let(:platform) do
    Jamie::Platform.new({ :name => 'platform',
      :run_list => 'platform_list', :attributes => { :p => 'pp' } })
  end

  let(:driver) { Jamie::Driver::Dummy.new({}) }

  let(:jr) { Jamie::Jr.new(suite.name) }

  let(:opts) do
    { :suite => suite, :platform => platform, :driver => driver, :jr => jr }
  end

  let(:instance) { Jamie::Instance.new(opts) }

  before do
    Celluloid.logger = Logger.new(StringIO.new)
  end

  it "raises an ArgumentError if suite is missing" do
    opts.delete(:suite)
    proc { Jamie::Instance.new(opts) }.must_raise Jamie::ClientError
  end

  it "raises an ArgumentError if platform is missing" do
    opts.delete(:platform)
    proc { Jamie::Instance.new(opts) }.must_raise Jamie::ClientError
  end

  it "returns suite" do
    instance.suite.must_equal suite
  end

  it "returns platform" do
    instance.platform.must_equal platform
  end

  it "returns an instance of Jr" do
    instance.jr.must_be_instance_of Jamie::Jr
  end

  describe "#name" do

    def combo(suite_name, platform_name)
      opts[:suite] = Jamie::Suite.new(
        :name => suite_name, :run_list => []
      )
      opts[:platform] = Jamie::Platform.new(
        :name => platform_name
      )
      Jamie::Instance.new(opts)
    end

    it "combines the suite and platform names with a dash" do
      combo('suite', 'platform').name.must_equal "suite-platform"
    end

    it "squashes periods" do
      combo('suite.ness', 'platform').name.must_equal "suiteness-platform"
      combo('suite', 'platform.s').name.must_equal "suite-platforms"
      combo('s.s.', '.p.p').name.must_equal "ss-pp"
    end

    it "transforms underscores to dashes" do
      combo('suite_ness', 'platform').name.must_equal "suite-ness-platform"
      combo('suite', 'platform-s').name.must_equal "suite-platform-s"
      combo('_s__s_', 'pp_').name.must_equal "-s--s--pp-"
    end
  end

  describe "#run_list" do

    def combo(suite_list, platform_list)
      opts[:suite] = Jamie::Suite.new(
        :name => 'suite', :run_list => suite_list
      )
      opts[:platform] = Jamie::Platform.new(
        :name => 'platform', :run_list => platform_list
      )
      Jamie::Instance.new(opts)
    end

    it "combines the platform then suite run_lists" do
      combo(%w{s1 s2}, %w{p1 p2}).run_list.must_equal %w{p1 p2 s1 s2}
    end

    it "uses the suite run_list only when platform run_list is empty" do
      combo(%w{sa sb}, nil).run_list.must_equal %w{sa sb}
    end

    it "returns an emtpy Array if both run_lists are empty" do
      combo([], nil).run_list.must_equal []
    end
  end

  describe "#attributes" do

    def combo(suite_attrs, platform_attrs)
      opts[:suite] = Jamie::Suite.new(
        :name => 'suite', :run_list => [], :attributes => suite_attrs
      )
      opts[:platform] = Jamie::Platform.new(
        :name => 'platform', :attributes => platform_attrs
      )
      Jamie::Instance.new(opts)
    end

    it "merges suite and platform hashes together" do
      combo(
        { :suite => { :s1 => 'sv1' } },
        { :suite => { :p1 => 'pv1' }, :platform => 'pp' }
      ).attributes.must_equal({
        :suite => { :s1 => 'sv1', :p1 => 'pv1' },
        :platform => 'pp'
      })
    end

    it "merges suite values over platform values" do
      combo(
        { :common => { :c1 => 'xxx' } },
        { :common => { :c1 => 'cv1', :c2 => 'cv2' } },
      ).attributes.must_equal({
        :common => { :c1 => 'xxx', :c2 => 'cv2' }
      })
    end
  end

  it "#dna combines attributes with the run_list" do
    instance.dna.must_equal({ :s => 'ss', :p => 'pp',
      :run_list => [ 'platform_list', 'suite_list' ] })
  end
end
