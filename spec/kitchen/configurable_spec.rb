# -*- encoding: utf-8 -*-
#
# Author:: Fletcher Nichol (<fnichol@nichol.ca>)
#
# Copyright (C) 2014, Fletcher Nichol
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
require "stringio"

require "kitchen/errors"
require "kitchen/configurable"

module Kitchen

  module Thing

    class Tiny

      include Kitchen::Configurable

      def initialize(config = {})
        init_config(config)
      end
    end

    class StaticDefaults

      include Kitchen::Configurable

      default_config :beans, "kidney"
      default_config :tunables, "flimflam" => "positate"
      default_config :edible, true
      default_config :fetch_command, "curl"
      default_config :success_path, "./success"
      default_config :beans_url do |subject|
        "http://gim.me/#{subject[:beans]}"
      end
      default_config :command do |subject|
        "#{subject[:fetch_command]} #{subject[:beans_url]}"
      end
      default_config :fetch_url do |subject|
        "http://gim.me/beans-for/#{subject.instance.name}"
      end

      required_config :need_it
      required_config :a_default
      required_config :no_nuts do |attr, value, _subject|
        raise UserError, "NO NUTS FOR #{attr}!" if value == "nuts"
      end

      expand_path_for :success_path
      expand_path_for :relative_path, false
      expand_path_for :another_path
      expand_path_for :complex_path do |subject|
        subject[:something_else] == "is_set"
      end

      def initialize(config = {})
        init_config(config)
      end
    end

    class SubclassDefaults < StaticDefaults

      default_config :yea, "ya"
      default_config :fetch_command, "wget"
      default_config :fetch_url, "http://no.beans"

      required_config :a_default do |_attr, value, _subject|
        raise UserError, "Overriding a_default is fun" unless value == "please"
      end

      expand_path_for :another_path, false
    end
  end
end

describe Kitchen::Configurable do

  let(:config)    { Hash.new }
  let(:instance)  { stub(:name => "coolbeans", :to_str => "<instance>") }

  let(:subject) do
    Kitchen::Thing::Tiny.new(config).finalize_config!(instance)
  end

  describe "creation and setup" do

    it "#instance returns its instance" do
      subject.instance.must_equal instance
    end

    it "#finalize_config! raises ClientError if instance is nil" do
      proc { Kitchen::Thing::Tiny.new({}).finalize_config!(nil) }.
        must_raise(Kitchen::ClientError)
    end

    it "#finalize_config! returns self for chaining" do
      t = Kitchen::Thing::Tiny.new({})
      t.finalize_config!(instance).must_equal t
    end
  end

  describe "configuration" do

    describe "provided from the outside" do

      it "returns provided config" do
        config[:fruit] = %w[apples oranges]
        config[:cool_enough] = true

        subject[:fruit].must_equal %w[apples oranges]
        subject[:cool_enough].must_equal true
      end
    end

    describe "using static default_config statements" do

      let(:config) do
        { :need_it => true, :a_default => true }
      end

      let(:subject) do
        Kitchen::Thing::StaticDefaults.new(config).finalize_config!(instance)
      end

      it "uses defaults" do
        subject[:beans].must_equal "kidney"
        subject[:tunables]["flimflam"].must_equal "positate"
        subject[:edible].must_equal true
      end

      it "uses provided config over default_config" do
        config[:beans] = "pinto"
        config[:edible] = false

        subject[:beans].must_equal "pinto"
        subject[:edible].must_equal false
      end

      it "uses other config values to compute values" do
        subject[:beans_url].must_equal "http://gim.me/kidney"
        subject[:command].must_equal "curl http://gim.me/kidney"
      end

      it "computed value blocks have access to instance object" do
        subject[:fetch_url].must_equal "http://gim.me/beans-for/coolbeans"
      end

      it "uses provided config over default_config for computed values" do
        config[:command] = "echo listentome"
        config[:beans] = "pinto"

        subject[:command].must_equal "echo listentome"
        subject[:beans_url].must_equal "http://gim.me/pinto"
      end
    end

    describe "using inherited static default_config statements" do

      let(:config) do
        { :need_it => true, :a_default => "please" }
      end

      let(:subject) do
        Kitchen::Thing::SubclassDefaults.new(config).finalize_config!(instance)
      end

      it "contains defaults from superclass" do
        subject[:beans].must_equal "kidney"
        subject[:tunables]["flimflam"].must_equal "positate"
        subject[:edible].must_equal true
        subject[:yea].must_equal "ya"
      end

      it "uses provided config over default config" do
        config[:beans] = "pinto"
        config[:edible] = false

        subject[:beans].must_equal "pinto"
        subject[:edible].must_equal false
        subject[:yea].must_equal "ya"
        subject[:beans_url].must_equal "http://gim.me/pinto"
      end

      it "uses its own default_config over inherited default_config" do
        subject[:fetch_url].must_equal "http://no.beans"
        subject[:command].must_equal "wget http://gim.me/kidney"
      end
    end

    describe "using static required_config statements" do

      let(:config) do
        { :a_default => true }
      end

      let(:subject) do
        Kitchen::Thing::StaticDefaults.new(config).finalize_config!(instance)
      end

      it "uses a value when provided" do
        config[:need_it] = "okay"

        subject[:need_it].must_equal "okay"
      end

      it "without a block, raises a UserError if attr is nil" do
        config[:need_it] = nil

        begin
          subject
          flunk "UserError must be raised"
        rescue Kitchen::UserError => e
          attr = "Kitchen::Thing::StaticDefaults<instance>#config[:need_it]"
          e.message.must_equal "#{attr} cannot be blank"
        end
      end

      it "without a block, raises a UserError if attr is an empty string" do
        config[:need_it] = ""

        begin
          subject
          flunk "UserError must be raised"
        rescue Kitchen::UserError => e
          attr = "Kitchen::Thing::StaticDefaults<instance>#config[:need_it]"
          e.message.must_equal "#{attr} cannot be blank"
        end
      end

      it "with a block, it is saved and invoked" do
        config[:need_it] = "okay"
        config[:no_nuts] = "nuts"

        begin
          subject
          flunk "UserError must be raised"
        rescue Kitchen::UserError => e
          e.message.must_equal "NO NUTS FOR no_nuts!"
        end
      end
    end

    describe "using inherited static require_config statements" do

      let(:subject) do
        Kitchen::Thing::SubclassDefaults.new(config).finalize_config!(instance)
      end

      it "contains required config from superclass" do
        config[:a_default] = nil
        config[:need_it] = nil

        begin
          subject
          flunk "UserError must be raised"
        rescue Kitchen::UserError => e
          attr = "Kitchen::Thing::StaticDefaults<instance>#config[:need_it]"
          e.message.must_equal "#{attr} cannot be blank"
        end
      end

      it "uses its own require_config over inherited require_config" do
        config[:need_it] = true
        config[:a_default] = nil

        begin
          subject
          flunk "UserError must be raised"
        rescue Kitchen::UserError => e
          e.message.must_equal "Overriding a_default is fun"
        end
      end
    end

    describe "using static expand_path_for statements" do

      let(:config) do
        { :need_it => "a", :a_default => "b", :kitchen_root => "/tmp/yo/self" }
      end

      let(:subject) do
        Kitchen::Thing::StaticDefaults.new(config).finalize_config!(instance)
      end

      it "expands a default value" do
        subject[:success_path].must_equal "/tmp/yo/self/success"
      end

      it "uses provided config over default_config" do
        config[:success_path] = "mine"

        subject[:success_path].must_equal "/tmp/yo/self/mine"
      end

      it "leaves a full path expanded" do
        config[:success_path] = "/the/other/one"

        subject[:success_path].must_equal "/the/other/one"
      end

      it "doesn't expand path with a falsy expand_path_for value" do
        config[:relative_path] = "./rel"

        subject[:relative_path].must_equal "./rel"
      end

      it "expands a path if a lambda returns truthy" do
        config[:something_else] = "is_set"
        config[:complex_path] = "./complex"

        subject[:complex_path].must_equal "/tmp/yo/self/complex"
      end
    end

    describe "using inherited static expand_path_for statements" do

      let(:config) do
        { :need_it => "a", :a_default => "please", :kitchen_root => "/rooty" }
      end

      let(:subject) do
        Kitchen::Thing::SubclassDefaults.new(config).finalize_config!(instance)
      end

      it "contains expand_path_for from superclass" do
        subject[:success_path].must_equal "/rooty/success"
      end

      it "uses its own expand_path_for over inherited expand_path_for" do
        config[:another_path] = "./pp"

        subject[:another_path].must_equal "./pp"
      end
    end

    it "#config_keys returns an array of config key names" do
      subject = Kitchen::Thing::Tiny.new(:ice_cream => "dragon")

      subject.config_keys.sort.must_equal [:ice_cream]
    end
  end

  describe "#diagnose" do

    it "returns an empty hash for no config" do
      subject.diagnose.must_equal Hash.new
    end

    it "returns a hash of config" do
      config[:alpha] = "beta"
      subject.diagnose.must_equal(:alpha => "beta")
    end

    it "returns a hash with sorted keys" do
      config[:zebra] = true
      config[:elephant] = true

      subject.diagnose.keys.must_equal [:elephant, :zebra]
    end
  end

  describe "#calculate_path" do

    let(:config) do
      { :test_base_path => "/the/basest" }
    end

    let(:suite) do
      stub(:name => "ultimate")
    end

    let(:instance) do
      stub(:name => "coolbeans", :to_str => "<instance>", :suite => suite)
    end

    let(:subject) do
      Kitchen::Thing::Tiny.new(config).finalize_config!(instance)
    end

    before do
      FakeFS.activate!
    end

    after do
      FakeFS.deactivate!
      FakeFS::FileSystem.clear
    end

    describe "for directories" do

      before do
        FileUtils.mkdir_p(File.join(Dir.pwd, "winner"))
        FileUtils.mkdir_p("/the/basest/winner")
        FileUtils.mkdir_p("/the/basest/ultimate/winner")
      end

      it "prefers a path containing base path and suite name if it exists" do
        subject.calculate_path("winner").
          must_equal "/the/basest/ultimate/winner"
      end

      it "prefers a path containing base path if it exists" do
        FileUtils.rm_rf("/the/basest/ultimate/winner")

        subject.calculate_path("winner").must_equal "/the/basest/winner"
      end

      it "prefers a path in the current working directory if it exists" do
        FileUtils.rm_rf("/the/basest/ultimate/winner")
        FileUtils.rm_rf("/the/basest/winner")
        pwd_dir = File.join(Dir.pwd, "winner")

        subject.calculate_path("winner").must_equal pwd_dir
      end

      it "raises a UserError if test_base_path key is not set" do
        config.delete(:test_base_path)

        proc { subject.calculate_path("winner") }.must_raise Kitchen::UserError
      end

      it "uses a custom base path" do
        FileUtils.mkdir_p("/custom/ultimate/winner")

        subject.calculate_path("winner", :base_path => "/custom").
          must_equal "/custom/ultimate/winner"
      end
    end

    describe "for files" do

      before do
        FileUtils.mkdir_p(Dir.pwd)
        FileUtils.touch(File.join(Dir.pwd, "winner"))
        FileUtils.mkdir_p("/the/basest")
        FileUtils.touch(File.join("/the/basest", "winner"))
        FileUtils.mkdir_p("/the/basest/ultimate")
        FileUtils.touch(File.join("/the/basest/ultimate", "winner"))
      end

      it "prefers a path containing base path and suite name if it exists" do
        subject.calculate_path("winner", :type => :file).
          must_equal "/the/basest/ultimate/winner"
      end

      it "prefers a path containing base path if it exists" do
        FileUtils.rm_rf("/the/basest/ultimate/winner")

        subject.calculate_path("winner", :type => :file).
          must_equal "/the/basest/winner"
      end

      it "prefers a path in the current working directory if it exists" do
        FileUtils.rm_rf("/the/basest/ultimate/winner")
        FileUtils.rm_rf("/the/basest/winner")
        pwd_dir = File.join(Dir.pwd, "winner")

        subject.calculate_path("winner", :type => :file).must_equal pwd_dir
      end

      it "raises a UserError if test_base_path key is not set" do
        config.delete(:test_base_path)

        proc { subject.calculate_path("winner") }.must_raise Kitchen::UserError
      end

      it "uses a custom base path" do
        FileUtils.mkdir_p("/custom/ultimate")
        FileUtils.touch(File.join("/custom/ultimate", "winner"))

        subject.calculate_path("winner", :type => :file, :base_path => "/custom").
          must_equal "/custom/ultimate/winner"
      end
    end
  end
end
