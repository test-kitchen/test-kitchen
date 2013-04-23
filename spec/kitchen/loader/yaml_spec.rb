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

require 'kitchen/errors'
require 'kitchen/util'
require 'kitchen/loader/yaml'

class Yamled
  attr_accessor :foo
end

describe Kitchen::Loader::YAML do

  let(:loader) { Kitchen::Loader::YAML.new("/tmp/.kitchen.yml") }

  before do
    FakeFS.activate!
    FileUtils.mkdir_p("/tmp")
  end

  after do
    FakeFS.deactivate!
    FakeFS::FileSystem.clear
  end

  describe ".initialize" do

    it "sets config_file based on Dir.pwd by default" do
      loader = Kitchen::Loader::YAML.new

      loader.config_file.must_equal File.expand_path(
        File.join(Dir.pwd, '.kitchen.yml'))
    end

    it "sets config_file from parameter, if given" do
      loader = Kitchen::Loader::YAML.new('/tmp/crazyfunkytown.file')

      loader.config_file.must_equal '/tmp/crazyfunkytown.file'
    end
  end

  describe "#read" do

    it "returns a hash of kitchen.yml with symbolized keys" do
      stub_yaml!({
        'foo' => 'bar'
      })

      loader.read.must_equal({ :foo => 'bar' })
    end

    it "deep merges in kitchen.local.yml configuration with kitchen.yml" do
      stub_yaml!(".kitchen.yml", {
        'common' => { 'xx' => 1 },
        'a' => 'b'
      })
      stub_yaml!(".kitchen.local.yml", {
        'common' => { 'yy' => 2 },
        'c' => 'd'
      })

      loader.read.must_equal({
        :a => 'b',
        :c => 'd',
        :common => { :xx => 1, :yy => 2 }
      })
    end

    it "merges kitchen.local.yml over configuration in kitchen.yml" do
      stub_yaml!(".kitchen.yml", {
        'common' => { 'thekey' => 'nope' }
      })
      stub_yaml!(".kitchen.local.yml", {
        'common' => { 'thekey' => 'yep' }
      })

      loader.read.must_equal({ :common => { :thekey => 'yep' } })
    end

    it "handles a kitchen.local.yml with no yaml elements" do
      stub_yaml!(".kitchen.yml", {
        'a' => 'b'
      })
      stub_yaml!(".kitchen.local.yml", Hash.new)

      loader.read.must_equal({ :a => 'b' })
    end

    it "handles a kitchen.yml with no yaml elements" do
      stub_yaml!(".kitchen.yml", Hash.new)
      stub_yaml!(".kitchen.local.yml", {
        'a' => 'b'
      })

      loader.read.must_equal({ :a => 'b' })
    end

    it "raises an UserError if the config_file does not exist" do
      proc { loader.read }.must_raise Kitchen::UserError
    end

    it "arbitrary objects aren't deserialized in kitchen.yml" do
      FileUtils.mkdir_p "/tmp"
      File.open("/tmp/.kitchen.yml", "wb") do |f|
        f.write <<-YAML.gsub(/^ {10}/, '')
          --- !ruby/object:Yamled
          foo: bar
        YAML
      end

      loader.read.class.wont_equal Yamled
      loader.read.class.must_equal Hash
      loader.read.must_equal({ :foo => 'bar' })
    end

    it "arbitrary objects aren't deserialized in kitchen.local.yml" do
      FileUtils.mkdir_p "/tmp"
      File.open("/tmp/.kitchen.local.yml", "wb") do |f|
        f.write <<-YAML.gsub(/^ {10}/, '')
          --- !ruby/object:Yamled
          wakka: boop
        YAML
      end
      stub_yaml!(".kitchen.yml", Hash.new)

      loader.read.class.wont_equal Yamled
      loader.read.class.must_equal Hash
      loader.read.must_equal({ :wakka => 'boop' })
    end

    it "raises a UserError if kitchen.yml cannot be parsed" do
      FileUtils.mkdir_p "/tmp"
      File.open("/tmp/.kitchen.yml", "wb") { |f| f.write '&*%^*' }

      proc { loader.read }.must_raise Kitchen::UserError
    end

    it "raises a UserError if kitchen.yml cannot be parsed" do
      FileUtils.mkdir_p "/tmp"
      File.open("/tmp/.kitchen.yml", "wb") { |f| f.write 'uhoh' }

      proc { loader.read }.must_raise Kitchen::UserError
    end

    it "raises a UserError if kitchen.local.yml cannot be parsed" do
      FileUtils.mkdir_p "/tmp"
      File.open("/tmp/.kitchen.local.yml", "wb") { |f| f.write '&*%^*' }
      stub_yaml!(".kitchen.yml", Hash.new)

      proc { loader.read }.must_raise Kitchen::UserError
    end

    it "evaluates kitchen.yml through erb before loading by default" do
      FileUtils.mkdir_p "/tmp"
      File.open("/tmp/.kitchen.yml", "wb") do |f|
        f.write <<-'YAML'.gsub(/^ {10}/, '')
          ---
          name: <%= "AHH".downcase + "choo" %>
        YAML
      end

      loader.read.must_equal({ :name => "ahhchoo" })
    end

    it "evaluates kitchen.local.yml through erb before loading by default" do
      FileUtils.mkdir_p "/tmp"
      File.open("/tmp/.kitchen.local.yml", "wb") do |f|
        f.write <<-'YAML'.gsub(/^ {10}/, '')
          ---
          <% %w{noodle mushroom}.each do |kind| %>
            <%= kind %>: soup
          <% end %>
        YAML
      end
      stub_yaml!(".kitchen.yml", { 'spinach' => 'salad' })

      loader.read.must_equal({
        :spinach => 'salad',
        :noodle => 'soup',
        :mushroom => 'soup'
      })
    end

    it "skips evaluating kitchen.yml through erb if disabled" do
      loader = Kitchen::Loader::YAML.new(
        '/tmp/.kitchen.yml', :process_erb => false)
      FileUtils.mkdir_p "/tmp"
      File.open("/tmp/.kitchen.yml", "wb") do |f|
        f.write <<-'YAML'.gsub(/^ {10}/, '')
          ---
          name: <%= "AHH".downcase %>
        YAML
      end

      loader.read.must_equal({ :name => '<%= "AHH".downcase %>' })
    end

    it "skips evaluating kitchen.local.yml through erb if disabled" do
      loader = Kitchen::Loader::YAML.new(
        '/tmp/.kitchen.yml', :process_erb => false)
      FileUtils.mkdir_p "/tmp"
      File.open("/tmp/.kitchen.local.yml", "wb") do |f|
        f.write <<-'YAML'.gsub(/^ {10}/, '')
          ---
          name: <%= "AHH".downcase %>
        YAML
      end
      stub_yaml!(".kitchen.yml", Hash.new)

      loader.read.must_equal({ :name => '<%= "AHH".downcase %>' })
    end

    it "skips kitchen.local.yml if disabled" do
      loader = Kitchen::Loader::YAML.new(
        '/tmp/.kitchen.yml', :process_local => false)
      stub_yaml!(".kitchen.yml", {
        'a' => 'b'
      })
      stub_yaml!(".kitchen.local.yml", {
        'superawesomesauceadditions' => 'enabled, yo'
      })

      loader.read.must_equal({ :a => 'b' })
    end
  end

  private

  def stub_yaml!(name = ".kitchen.yml", hash)
    FileUtils.mkdir_p "/tmp"
    File.open("/tmp/#{name}", "wb") { |f| f.write(hash.to_yaml) }
  end
end
