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

require_relative "../../spec_helper"

require "kitchen/errors"
require "kitchen/util"
require "kitchen/loader/yaml"

class Yamled
  attr_accessor :foo
end

describe Kitchen::Loader::YAML do
  let(:loader) do
    Kitchen::Loader::YAML.new(project_config: "/tmp/.kitchen.yml")
  end

  before do
    FakeFS.activate!
    FileUtils.mkdir_p("/tmp")
  end

  after do
    FakeFS.deactivate!
    FakeFS::FileSystem.clear
  end

  describe ".initialize" do
    it "sets project_config based on Dir.pwd by default" do
      stub_file(File.join(Dir.pwd, "kitchen.yml"), {})
      loader = Kitchen::Loader::YAML.new

      loader.diagnose[:project_config][:filename]
        .must_equal File.expand_path(File.join(Dir.pwd, "kitchen.yml"))
    end

    it "when kitchen.yml not present, falls back to .kitchen.yml" do
      stub_file(File.join(Dir.pwd, ".kitchen.yml"), {})
      loader = Kitchen::Loader::YAML.new

      loader.diagnose[:project_config][:filename]
        .must_equal File.expand_path(File.join(Dir.pwd, ".kitchen.yml"))
    end

    it "prefers kitchen.yml to .kitchen.yml" do
      stub_file(File.join(Dir.pwd, "kitchen.yml"), {})
      loader = Kitchen::Loader::YAML.new

      loader.diagnose[:project_config][:filename]
        .must_equal File.expand_path(File.join(Dir.pwd, "kitchen.yml"))
    end

    it "errors when kitchen.yml and .kitchen.yml are both present" do
      stub_file(File.join(Dir.pwd, "kitchen.yml"), {})
      stub_file(File.join(Dir.pwd, ".kitchen.yml"), {})
      proc { Kitchen::Loader::YAML.new }.must_raise Kitchen::UserError
    end

    it "sets project_config from parameter, if given" do
      stub_file("/tmp/crazyfunkytown.file", {})
      loader = Kitchen::Loader::YAML.new(
        project_config: "/tmp/crazyfunkytown.file")

      loader.diagnose[:project_config][:filename]
        .must_match %r{/tmp/crazyfunkytown.file$}
    end

    it "sets local_config based on Dir.pwd by default" do
      stub_file(File.join(Dir.pwd, ".kitchen.local.yml"), {})
      loader = Kitchen::Loader::YAML.new

      loader.diagnose[:local_config][:filename]
        .must_equal File.expand_path(File.join(Dir.pwd, ".kitchen.local.yml"))
    end

    it "sets local_config based on location of project_config by default" do
      stub_file("/tmp/.kitchen.local.yml", {})
      loader = Kitchen::Loader::YAML.new(
        project_config: "/tmp/.kitchen.yml")

      loader.diagnose[:local_config][:filename]
        .must_match %r{/tmp/.kitchen.local.yml$}
    end

    it "errors if both visible and hidden copies of default local_config exist" do
      stub_file("/tmp/kitchen.local.yml", {})
      stub_file("/tmp/.kitchen.local.yml", {})
      proc { Kitchen::Loader::YAML.new(project_config: "/tmp/.kitchen.yml") }
        .must_raise Kitchen::UserError
    end

    it "sets local_config from parameter, if given" do
      stub_file("/tmp/crazyfunkytown.file", {})
      loader = Kitchen::Loader::YAML.new(
        local_config: "/tmp/crazyfunkytown.file")

      loader.diagnose[:local_config][:filename]
        .must_match %r{/tmp/crazyfunkytown.file$}
    end

    it "sets global_config based on ENV['HOME'] by default" do
      stub_file(File.join(ENV["HOME"], ".kitchen/config.yml"), {})
      loader = Kitchen::Loader::YAML.new

      loader.diagnose[:global_config][:filename].must_equal File.expand_path(
        File.join(ENV["HOME"], ".kitchen/config.yml"))
    end

    it "sets global_config from parameter, if given" do
      stub_file("/tmp/crazyfunkytown.file", {})
      loader = Kitchen::Loader::YAML.new(
        global_config: "/tmp/crazyfunkytown.file")

      loader.diagnose[:global_config][:filename]
        .must_match %r{/tmp/crazyfunkytown.file$}
    end
  end

  describe "#read" do
    it "returns a hash of kitchen.yml with symbolized keys" do
      stub_yaml!(
        "foo" => "bar"
      )

      loader.read.must_equal(foo: "bar")
    end

    it "deep merges in kitchen.local.yml configuration with kitchen.yml" do
      stub_yaml!("common" => { "xx" => 1 },
                 "a" => "b"
                )
      stub_yaml!(
                {
                  "common" => { "yy" => 2 },
                  "c" => "d",
                },
                  ".kitchen.local.yml"
                )

      loader.read.must_equal(
        a: "b",
        c: "d",
        common: { xx: 1, yy: 2 }
      )
    end

    it "deep merges in a global config file with all other configs" do
      stub_yaml!("common" => { "xx" => 1 },
                 "a" => "b"
                )
      stub_yaml!(
                {
                  "common" => { "yy" => 2 },
                  "c" => "d",
                },
                  ".kitchen.local.yml"
                )
      stub_global!(
        "common" => { "zz" => 3 },
        "e" => "f"
      )

      loader.read.must_equal(
        a: "b",
        c: "d",
        e: "f",
        common: { xx: 1, yy: 2, zz: 3 }
      )
    end

    it "merges kitchen.yml over configuration in global config" do
      stub_global!(
        "common" => { "thekey" => "nope" }
      )
      stub_yaml!("common" => { "thekey" => "yep" })

      loader.read.must_equal(common: { thekey: "yep" })
    end

    it "merges kitchen.local.yml over configuration in kitchen.yml" do
      stub_yaml!("common" => { "thekey" => "nope" })
      stub_yaml!(
                  { "common" => { "thekey" => "yep" } },
                  ".kitchen.local.yml"
                )

      loader.read.must_equal(common: { thekey: "yep" })
    end

    it "merges kitchen.local.yml over both kitchen.yml and global config" do
      stub_yaml!("common" => { "thekey" => "nope" })
      stub_yaml!(
                  { "common" => { "thekey" => "yep" } },
                  ".kitchen.local.yml"
                )
      stub_global!(
        "common" => { "thekey" => "kinda" }
      )

      loader.read.must_equal(common: { thekey: "yep" })
    end

    NORMALIZED_KEYS = {
      "driver" => "name",
      "provisioner" => "name",
      "busser" => "version",
    }.freeze

    NORMALIZED_KEYS.each do |key, default_key|
      describe "normalizing #{key} config hashes" do
        it "merges local with #{key} string value over yaml with hash value" do
          stub_yaml!(key => { "dakey" => "ya" })
          stub_yaml!(
                      { key => "namey" },
                      ".kitchen.local.yml"
                    )

          loader.read.must_equal(
            key.to_sym => { default_key.to_sym => "namey", :dakey => "ya" }
          )
        end

        it "merges local with #{key} hash value over yaml with string value" do
          stub_yaml!(key => "namey")
          stub_yaml!(
                      { key => { "dakey" => "ya" } },
                      ".kitchen.local.yml"
                    )

          loader.read.must_equal(
            key.to_sym => { default_key.to_sym => "namey", :dakey => "ya" }
          )
        end

        it "merges local with #{key} nil value over yaml with hash value" do
          stub_yaml!(key => { "dakey" => "ya" })
          stub_yaml!(
                      { key => nil },
                      ".kitchen.local.yml"
                    )

          loader.read.must_equal(
            key.to_sym => { dakey: "ya" }
          )
        end

        it "merges local with #{key} hash value over yaml with nil value" do
          stub_yaml!(key => "namey")
          stub_yaml!(
                      { key => nil },
                      ".kitchen.local.yml"
                    )

          loader.read.must_equal(
            key.to_sym => { default_key.to_sym => "namey" }
          )
        end

        it "merges global with #{key} string value over yaml with hash value" do
          stub_yaml!(key => { "dakey" => "ya" })
          stub_global!(
            key => "namey"
          )

          loader.read.must_equal(
            key.to_sym => { default_key.to_sym => "namey", :dakey => "ya" }
          )
        end

        it "merges global with #{key} hash value over yaml with string value" do
          stub_yaml!(key => "namey")
          stub_global!(
            key => { "dakey" => "ya" }
          )

          loader.read.must_equal(
            key.to_sym => { default_key.to_sym => "namey", :dakey => "ya" }
          )
        end

        it "merges global with #{key} nil value over yaml with hash value" do
          stub_yaml!(key => { "dakey" => "ya" })
          stub_global!(
            key => nil
          )

          loader.read.must_equal(
            key.to_sym => { dakey: "ya" }
          )
        end

        it "merges global with #{key} hash value over yaml with nil value" do
          stub_yaml!(key => nil)
          stub_global!(
            key => { "dakey" => "ya" }
          )

          loader.read.must_equal(
            key.to_sym => { dakey: "ya" }
          )
        end

        it "merges global, local, over yaml with mixed hash, string, nil values" do
          stub_yaml!(key => nil)
          stub_yaml!(
                      { key => "namey" },
                      ".kitchen.local.yml"
                    )
          stub_global!(
            key => { "dakey" => "ya" }
          )

          loader.read.must_equal(
            key.to_sym => { default_key.to_sym => "namey", :dakey => "ya" }
          )
        end
      end
    end

    it "handles a kitchen.local.yml with no yaml elements" do
      stub_yaml!("a" => "b")
      stub_yaml!({}, ".kitchen.local.yml")

      loader.read.must_equal(a: "b")
    end

    it "handles a kitchen.yml with no yaml elements" do
      stub_yaml!({})
      stub_yaml!(
        { "a" => "b" },
        ".kitchen.local.yml"
      )

      loader.read.must_equal(a: "b")
    end

    it "handles a kitchen.yml with yaml elements that parse as nil" do
      stub_yaml!(nil)
      stub_yaml!(
        { "a" => "b" },
        ".kitchen.local.yml"
      )

      loader.read.must_equal(a: "b")
    end

    it "raises an UserError if the config_file does not exist" do
      proc { loader.read }.must_raise Kitchen::UserError
    end

    it "arbitrary objects aren't deserialized in kitchen.yml" do
      FileUtils.mkdir_p "/tmp"
      File.open("/tmp/.kitchen.yml", "wb") do |f|
        f.write <<-YAML.gsub(/^ {10}/, "")
          --- !ruby/object:Yamled
          foo: bar
        YAML
      end

      proc { loader.read }.must_raise Kitchen::UserError
    end

    it "arbitrary objects aren't deserialized in kitchen.local.yml" do
      FileUtils.mkdir_p "/tmp"
      File.open("/tmp/.kitchen.local.yml", "wb") do |f|
        f.write <<-YAML.gsub(/^ {10}/, "")
          --- !ruby/object:Yamled
          wakka: boop
        YAML
      end
      stub_yaml!({})

      proc { loader.read }.must_raise Kitchen::UserError
    end

    it "raises a UserError if kitchen.yml cannot be parsed" do
      FileUtils.mkdir_p "/tmp"
      File.open("/tmp/.kitchen.yml", "wb") { |f| f.write "&*%^*" }

      err = proc { loader.read }.must_raise Kitchen::UserError
      err.message.must_match Regexp.new(
        "Error parsing ([a-zA-Z]:)?/tmp/.kitchen.yml")
    end

    it "raises a UserError if kitchen.yml cannot be parsed" do
      FileUtils.mkdir_p "/tmp"
      File.open("/tmp/.kitchen.yml", "wb") { |f| f.write "uhoh" }

      err = proc { loader.read }.must_raise Kitchen::UserError
      err.message.must_match Regexp.new(
        "Error parsing ([a-zA-Z]:)?/tmp/.kitchen.yml")
    end

    it "handles a kitchen.yml if it is a commented out YAML document" do
      FileUtils.mkdir_p "/tmp"
      File.open("/tmp/.kitchen.yml", "wb") { |f| f.write '#---\n' }

      loader.read.must_equal({})
    end

    it "raises a UserError if kitchen.local.yml cannot be parsed" do
      FileUtils.mkdir_p "/tmp"
      File.open("/tmp/.kitchen.local.yml", "wb") { |f| f.write "&*%^*" }
      stub_yaml!({})

      proc { loader.read }.must_raise Kitchen::UserError
    end

    it "evaluates kitchen.yml through erb before loading by default" do
      FileUtils.mkdir_p "/tmp"
      File.open("/tmp/.kitchen.yml", "wb") do |f|
        f.write <<-'YAML'.gsub(/^ {10}/, "")
          ---
          name: <%= "AHH".downcase + "choo" %>
        YAML
      end

      loader.read.must_equal(name: "ahhchoo")
    end

    it "accepts kitchen.yml with alias" do
      FileUtils.mkdir_p "/tmp"
      File.open("/tmp/.kitchen.yml", "wb") do |f|
        f.write <<-'YAML'.gsub(/^ {10}/, "")
          ---
          xxx: &k
            foo: bar
          yyy: *k
        YAML
      end

      loader.read[:yyy].must_equal(foo: "bar")
    end

    it "raises a UserError if there is an ERB processing error" do
      FileUtils.mkdir_p "/tmp"
      File.open("/tmp/.kitchen.yml", "wb") do |f|
        f.write <<-'YAML'.gsub(/^ {10}/, "")
          ---
          <%= poop %>: yep
        YAML
      end

      err = proc { loader.read }.must_raise Kitchen::UserError
      err.message.must_match Regexp.new(
        "Error parsing ERB content in ([a-zA-Z]:)?/tmp/.kitchen.yml")
    end

    it "evaluates kitchen.local.yml through erb before loading by default" do
      FileUtils.mkdir_p "/tmp"
      File.open("/tmp/.kitchen.local.yml", "wb") do |f|
        f.write <<-'YAML'.gsub(/^ {10}/, "")
          ---
          <% %w{noodle mushroom}.each do |kind| %>
            <%= kind %>: soup
          <% end %>
        YAML
      end
      stub_yaml!("spinach" => "salad")

      loader.read.must_equal(
        spinach: "salad",
        noodle: "soup",
        mushroom: "soup"
      )
    end

    it "skips evaluating kitchen.yml through erb if disabled" do
      loader = Kitchen::Loader::YAML.new(
        project_config: "/tmp/.kitchen.yml", process_erb: false)
      FileUtils.mkdir_p "/tmp"
      File.open("/tmp/.kitchen.yml", "wb") do |f|
        f.write <<-'YAML'.gsub(/^ {10}/, "")
          ---
          name: <%= "AHH".downcase %>
        YAML
      end

      loader.read.must_equal(name: '<%= "AHH".downcase %>')
    end

    it "skips evaluating kitchen.local.yml through erb if disabled" do
      loader = Kitchen::Loader::YAML.new(
        project_config: "/tmp/.kitchen.yml", process_erb: false)
      FileUtils.mkdir_p "/tmp"
      File.open("/tmp/.kitchen.local.yml", "wb") do |f|
        f.write <<-'YAML'.gsub(/^ {10}/, "")
          ---
          name: <%= "AHH".downcase %>
        YAML
      end
      stub_yaml!({})

      loader.read.must_equal(name: '<%= "AHH".downcase %>')
    end

    it "skips kitchen.local.yml if disabled" do
      loader = Kitchen::Loader::YAML.new(
        project_config: "/tmp/.kitchen.yml", process_local: false)
      stub_yaml!("a" => "b")
      stub_yaml!(
        { "superawesomesauceadditions" => "enabled, yo" },
        ".kitchen.local.yml"
      )

      loader.read.must_equal(a: "b")
    end

    it "skips the global config if disabled" do
      loader = Kitchen::Loader::YAML.new(
        project_config: "/tmp/.kitchen.yml", process_global: false)
      stub_yaml!("a" => "b")
      stub_global!(
        "superawesomesauceadditions" => "enabled, yo"
      )

      loader.read.must_equal(a: "b")
    end
  end

  describe "#diagnose" do
    it "returns a Hash" do
      stub_yaml!({})

      loader.diagnose.must_be_kind_of(Hash)
    end

    it "contains erb processing information when true" do
      stub_yaml!({})

      loader.diagnose[:process_erb].must_equal true
    end

    it "contains erb processing information when false" do
      stub_yaml!({})
      loader = Kitchen::Loader::YAML.new(
        project_config: "/tmp/.kitchen.yml", process_erb: false)

      loader.diagnose[:process_erb].must_equal false
    end

    it "contains local processing information when true" do
      stub_yaml!({})

      loader.diagnose[:process_local].must_equal true
    end

    it "contains local processing information when false" do
      stub_yaml!({})
      loader = Kitchen::Loader::YAML.new(
        project_config: "/tmp/.kitchen.yml", process_local: false)

      loader.diagnose[:process_local].must_equal false
    end

    it "contains global processing information when true" do
      stub_yaml!({})

      loader.diagnose[:process_global].must_equal true
    end

    it "contains global processing information when false" do
      stub_yaml!({})
      loader = Kitchen::Loader::YAML.new(
        project_config: "/tmp/.kitchen.yml", process_global: false)

      loader.diagnose[:process_global].must_equal false
    end

    describe "for yaml files" do
      before do
        stub_yaml!("from_project" => "project",
                   "common" => { "p" => "pretty" }
                  )
        stub_yaml!({
            "from_local" => "local",
            "common" => { "l" => "looky" },
          },
          ".kitchen.local.yml"
        )
        stub_global!(
          "from_global" => "global",
          "common" => { "g" => "goody" }
        )
      end

      it "global config contains a filename" do
        loader.diagnose[:global_config][:filename]
          .must_equal File.join(ENV["HOME"].tr('\\', "/"), ".kitchen/config.yml")
      end

      it "global config contains raw data" do
        loader.diagnose[:global_config][:raw_data].must_equal(
          "from_global" => "global",
          "common" => { "g" => "goody" }
        )
      end

      it "project config contains a filename" do
        loader.diagnose[:project_config][:filename]
          .must_match %r{/tmp/.kitchen.yml$}
      end

      it "project config contains raw data" do
        loader.diagnose[:project_config][:raw_data].must_equal(
          "from_project" => "project",
          "common" => { "p" => "pretty" }
        )
      end

      it "local config contains a filename" do
        loader.diagnose[:local_config][:filename]
          .must_match %r{/tmp/.kitchen.local.yml$}
      end

      it "local config contains raw data" do
        loader.diagnose[:local_config][:raw_data].must_equal(
          "from_local" => "local",
          "common" => { "l" => "looky" }
        )
      end

      it "combined config contains a nil filename" do
        loader.diagnose[:combined_config][:filename]
          .must_be_nil
      end

      it "combined config contains raw data" do
        loader.diagnose[:combined_config][:raw_data].must_equal(
          "from_global" => "global",
          "from_project" => "project",
          "from_local" => "local",
          "common" => {
            "g" => "goody",
            "p" => "pretty",
            "l" => "looky",
          }
        )
      end

      describe "for global on error" do
        before do
          FileUtils.mkdir_p(File.join(ENV["HOME"], ".kitchen"))
          File.open(File.join(ENV["HOME"], ".kitchen/config.yml"), "wb") do |f|
            f.write "&*%^*"
          end
        end

        it "uses an error hash with the raw file contents" do
          loader.diagnose[:global_config][:raw_data][:error][:raw_file]
            .must_equal "&*%^*"
        end

        it "uses an error hash with the exception" do
          loader.diagnose[:global_config][:raw_data][:error][:exception]
            .must_match(/Kitchen::UserError/)
        end

        it "uses an error hash with the exception message" do
          loader.diagnose[:global_config][:raw_data][:error][:message]
            .must_match(/Error parsing/)
        end

        it "uses an error hash with the exception backtrace" do
          loader.diagnose[:global_config][:raw_data][:error][:backtrace]
            .must_be_kind_of Array
        end
      end

      describe "for project on error" do
        before do
          File.open("/tmp/.kitchen.yml", "wb") do |f|
            f.write "&*%^*"
          end
        end

        it "uses an error hash with the raw file contents" do
          loader.diagnose[:project_config][:raw_data][:error][:raw_file]
            .must_equal "&*%^*"
        end

        it "uses an error hash with the exception" do
          loader.diagnose[:project_config][:raw_data][:error][:exception]
            .must_match(/Kitchen::UserError/)
        end

        it "uses an error hash with the exception message" do
          loader.diagnose[:project_config][:raw_data][:error][:message]
            .must_match(/Error parsing/)
        end

        it "uses an error hash with the exception backtrace" do
          loader.diagnose[:project_config][:raw_data][:error][:backtrace]
            .must_be_kind_of Array
        end
      end

      describe "for local on error" do
        before do
          File.open("/tmp/.kitchen.local.yml", "wb") do |f|
            f.write "&*%^*"
          end
        end

        it "uses an error hash with the raw file contents" do
          loader.diagnose[:local_config][:raw_data][:error][:raw_file]
            .must_equal "&*%^*"
        end

        it "uses an error hash with the exception" do
          loader.diagnose[:local_config][:raw_data][:error][:exception]
            .must_match(/Kitchen::UserError/)
        end

        it "uses an error hash with the exception message" do
          loader.diagnose[:local_config][:raw_data][:error][:message]
            .must_match(/Error parsing/)
        end

        it "uses an error hash with the exception backtrace" do
          loader.diagnose[:local_config][:raw_data][:error][:backtrace]
            .must_be_kind_of Array
        end
      end

      describe "for combined on error" do
        before do
          File.open("/tmp/.kitchen.yml", "wb") do |f|
            f.write "&*%^*"
          end
        end

        it "uses an error hash with nil raw file contents" do
          loader.diagnose[:combined_config][:raw_data][:error][:raw_file]
            .must_be_nil
        end

        it "uses an error hash with the exception" do
          loader.diagnose[:combined_config][:raw_data][:error][:exception]
            .must_match(/Kitchen::UserError/)
        end

        it "uses an error hash with the exception message" do
          loader.diagnose[:combined_config][:raw_data][:error][:message]
            .must_match(/Error parsing/)
        end

        it "uses an error hash with the exception backtrace" do
          loader.diagnose[:combined_config][:raw_data][:error][:backtrace]
            .must_be_kind_of Array
        end
      end
    end
  end

  private

  def stub_file(path, hash)
    FileUtils.mkdir_p(File.dirname(path))
    File.open(path, "wb") { |f| f.write(hash.to_yaml) }
  end

  def stub_yaml!(hash, name = ".kitchen.yml")
    stub_file(File.join("/tmp", name), hash)
  end

  def stub_global!(hash)
    stub_file(File.join(File.expand_path(ENV["HOME"]),
                        ".kitchen", "config.yml"), hash)
  end
end
