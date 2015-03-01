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

require "kitchen/busser"
# @TODO: this can be remove once Kitchen::DEFAULT_TEST_DIR is removed
require "kitchen"

describe Kitchen::Busser do

  let(:suite_name)  { "germany" }
  let(:config)      { Hash.new }

  let(:busser) do
    Kitchen::Busser.new(suite_name, config)
  end

  describe ".new" do

    it "raises a ClientError if a suite name is not provided" do
      proc {
        Kitchen::Busser.new(nil, config)
      }.must_raise Kitchen::ClientError
    end

    it "raises a UserError if the suite name is 'helper'" do
      proc {
        Kitchen::Busser.new("helper", config)
      }.must_raise Kitchen::UserError
    end
  end

  it "#name returns the name of the suite" do
    busser.name.must_equal "germany"
  end

  it "#config_keys returns an array of config key names" do
    busser.config_keys.sort.must_equal [
      :busser_bin, :kitchen_root, :root_path, :ruby_bindir, :sudo,
      :suite_name, :test_base_path, :version
    ]
  end

  describe "configuration" do

    it ":kitchen_root defaults to current directory" do
      busser[:kitchen_root].must_equal Dir.pwd
    end

    it ":test_base_path defaults to an expanded path" do
      busser[:test_base_path].must_equal File.join(Dir.pwd, "test/integration")
    end

    it ":suite_name defaults to the passed in suite name" do
      busser[:suite_name].must_equal "germany"
    end

    it ":sudo defaults to true" do
      busser[:sudo].must_equal true
    end

    it ":ruby_bindir defaults the an Omnibus Chef installation" do
      busser[:ruby_bindir].must_equal "/opt/chef/embedded/bin"
    end

    it ":root_path defaults to '/tmp/busser'" do
      busser[:root_path].must_equal "/tmp/busser"
    end

    it ":version defaults to 'busser'" do
      busser[:version].must_equal "busser"
    end

    it ":busser_bin defaults to a binstub under :root_path" do
      config[:root_path] = "/beep"

      busser[:busser_bin].must_equal "/beep/bin/busser"
    end
  end

  describe "#diagnose" do

    it "returns a hash with sorted keys" do
      busser.diagnose.keys.must_equal [
        :busser_bin, :kitchen_root, :root_path, :ruby_bindir, :sudo,
        :suite_name, :test_base_path, :version
      ]
    end
  end

  describe "#setup_cmd" do

    before do
      @root = Dir.mktmpdir
      config[:test_base_path] = @root
    end

    after do
      FileUtils.remove_entry(@root)
    end

    let(:cmd) { busser.setup_cmd }

    describe "with no suite test files" do

      it "returns nil" do
        cmd.must_equal nil
      end
    end

    describe "with suite test files" do

      before do
        base = "#{config[:test_base_path]}/germany"

        FileUtils.mkdir_p "#{base}/mondospec"
        File.open("#{base}/mondospec/charlie", "wb") { |f| f.write("charlie") }
        FileUtils.mkdir_p "#{base}/minispec"
        File.open("#{base}/minispec/beta", "wb") { |f| f.write("beta") }
        FileUtils.mkdir_p "#{base}/abba"
        File.open("#{base}/abba/alpha", "wb") { |f| f.write("alpha") }

        config[:ruby_bindir] = "/r"
      end

      it "uses bourne shell" do
        cmd.must_match(/\Ash -c '$/)
        cmd.must_match(/'\Z/)
      end

      it "sets the BUSSER_ROOT environment variable" do
        config[:root_path] = "/r"

        cmd.must_match regexify(%{BUSSER_ROOT="/r"}, :partial_line)
      end

      it "sets the GEM_HOME environment variable" do
        config[:root_path] = "/r"

        cmd.must_match regexify(%{GEM_HOME="/r/gems" }, :partial_line)
      end

      it "sets the GEM_PATH environment variable" do
        config[:root_path] = "/r"

        cmd.must_match regexify(%{GEM_PATH="/r/gems" }, :partial_line)
      end

      it "sets the GEM_CACHE environment variable" do
        config[:root_path] = "/r"

        cmd.must_match regexify(%{GEM_CACHE="/r/gems/cache" }, :partial_line)
      end

      it "exports all the environment variables" do
        cmd.must_match regexify(
          "export BUSSER_ROOT GEM_HOME GEM_PATH GEM_CACHE", :partial_line)
      end

      it "checks if busser is installed" do
        cmd.must_match regexify(
          %{if ! sudo -E /r/gem list busser -i >/dev/null;}, :partial_line)
      end

      describe "installing busser" do

        it "installs the latest busser gem by default" do
          cmd.must_match regexify(
            %{sudo -E /r/gem install busser --no-rdoc --no-ri}, :partial_line)
        end

        it "installs a specific busser version gem" do
          config[:version] = "4.0.7"

          cmd.must_match regexify(
            %{sudo -E /r/gem install busser --version 4.0.7 --no-rdoc --no-ri},
            :partial_line)
        end

        it "installs a specific busser version gem with @ syntax" do
          config[:version] = "busser@1.2.3"

          cmd.must_match regexify(
            %{sudo -E /r/gem install busser --version 1.2.3 --no-rdoc --no-ri},
            :partial_line)
        end

        it "installs an arbitrary gem and version with @ syntax" do
          config[:version] = "foo@9.0.1"

          cmd.must_match regexify(
            %{sudo -E /r/gem install foo --version 9.0.1 --no-rdoc --no-ri},
            :partial_line)
        end
      end

      it "calculates RubyGem's bindir" do
        cmd.must_match regexify(
          %{gem_bindir=`/r/ruby -rrubygems -e "puts Gem.bindir"`},
          :partial_line)
      end

      it "runs busser setup from the installed gem_bindir binstub" do
        cmd.must_match regexify(
          %{sudo -E ${gem_bindir}/busser setup}, :partial_line)
      end

      it "runs busser plugin install with the :busser_bindir command" do
        config[:busser_bin] = "/b/b"

        cmd.must_match regexify(
          %{sudo -E /b/b plugin install } +
            %{busser-abba busser-minispec busser-mondospec},
          :partial_line)
      end
    end
  end

  describe "#sync_cmd" do

    before do
      @root = Dir.mktmpdir
      config[:test_base_path] = @root
    end

    after do
      FileUtils.remove_entry(@root)
    end

    let(:cmd) { busser.sync_cmd }

    describe "with no suite test files" do

      it "returns nil" do
        cmd.must_equal nil
      end
    end

    describe "with suite test files" do

      before do
        base = "#{config[:test_base_path]}/germany"
        hbase = "#{config[:test_base_path]}/helpers"

        files.map { |f, md| [File.join(base, f), md] }.each do |f, md|
          create_file(f, md[:content], md[:perms])
        end
        helper_files.map { |f, md| [File.join(hbase, f), md] }.each do |f, md|
          create_file(f, md[:content], md[:perms])
        end

        config[:ruby_bindir] = "/r"
      end

      let(:files) do
        {
          "mondospec/charlie" => {
            :content => "charlie",
            :perms => "0764",
            :base64 => "Y2hhcmxpZQ==",
            :md5 => "bf779e0933a882808585d19455cd7937"
          },
          "minispec/beta" => {
            :content => "beta",
            :perms => "0644",
            :base64 => "YmV0YQ==",
            :md5 => "987bcab01b929eb2c07877b224215c92"
          },
          "abba/alpha" => {
            :content => "alpha",
            :perms => "0440",
            :base64 => "YWxwaGE=",
            :md5 => "2c1743a391305fbf367df8e4f069f9f9"
          }
        }
      end

      let(:helper_files) do
        {
          "minispec/spec_helper" => {
            :content => "helping",
            :perms => "0644",
            :base64 => "aGVscGluZw==",
            :md5 => "111c081293c11cb7c2ac6fbf841805cb"
          },
          "abba/common" => {
            :content => "yeppers",
            :perms => "0664",
            :base64 => "eWVwcGVycw==",
            :md5 => "7c3157de4890b1abcb7a6a3695eb6dd2"
          }
        }
      end

      it "uses bourne shell" do
        cmd.must_match(/\Ash -c '$/)
        cmd.must_match(/'\Z/)
      end

      it "sets the BUSSER_ROOT environment variable" do
        config[:root_path] = "/r"

        cmd.must_match regexify(%{BUSSER_ROOT="/r"}, :partial_line)
      end

      it "sets the GEM_HOME environment variable" do
        config[:root_path] = "/r"

        cmd.must_match regexify(%{GEM_HOME="/r/gems" }, :partial_line)
      end

      it "sets the GEM_PATH environment variable" do
        config[:root_path] = "/r"

        cmd.must_match regexify(%{GEM_PATH="/r/gems" }, :partial_line)
      end

      it "sets the GEM_CACHE environment variable" do
        config[:root_path] = "/r"

        cmd.must_match regexify(%{GEM_CACHE="/r/gems/cache" }, :partial_line)
      end

      it "exports all the environment variables" do
        cmd.must_match regexify(
          "export BUSSER_ROOT GEM_HOME GEM_PATH GEM_CACHE", :partial_line)
      end

      it "logs a message for each file" do
        config[:busser_bin] = "/b/busser"

        files.each do |f, md|
          cmd.must_match regexify([
            %{echo "Uploading `sudo -E /b/busser suite path`/#{f}},
            %{(mode=#{md[:perms]})"}
          ].join(" "))
        end
      end

      it "logs a message for each helper file" do
        config[:busser_bin] = "/b/busser"

        helper_files.each do |f, md|
          cmd.must_match regexify([
            %{echo "Uploading `sudo -E /b/busser suite path`/#{f}},
            %{(mode=#{md[:perms]})"}
          ].join(" "))
        end
      end

      it "base64 encodes each file for deserializing with busser" do
        config[:busser_bin] = "/b/busser"

        files.each do |f, md|
          cmd.must_match regexify([
            %{echo "#{md[:base64]}" | sudo -E /b/busser deserialize},
            %{--destination=`sudo -E /b/busser suite path`/#{f}},
            %{--md5sum=#{md[:md5]} --perms=#{md[:perms]}}
          ].join(" "))
        end
      end

      it "base64 encodes each helper file for deserializing with busser" do
        config[:busser_bin] = "/b/busser"

        helper_files.each do |f, md|
          cmd.must_match regexify([
            %{echo "#{md[:base64]}" | sudo -E /b/busser deserialize},
            %{--destination=`sudo -E /b/busser suite path`/#{f}},
            %{--md5sum=#{md[:md5]} --perms=#{md[:perms]}}
          ].join(" "))
        end
      end

      def create_file(file, content, perms)
        FileUtils.mkdir_p(File.dirname(file))
        File.open(file, "wb") { |f| f.write(content) }
        FileUtils.chmod(perms.to_i(8), file)
      end
    end
  end

  describe "#run_cmd" do

    before do
      @root = Dir.mktmpdir
      config[:test_base_path] = @root
    end

    after do
      FileUtils.remove_entry(@root)
    end

    let(:cmd) { busser.run_cmd }

    describe "with no suite test files" do

      it "returns nil" do
        cmd.must_equal nil
      end
    end

    describe "with suite test files" do

      before do
        base = "#{config[:test_base_path]}/germany"

        FileUtils.mkdir_p "#{base}/mondospec"
        File.open("#{base}/mondospec/charlie", "wb") { |f| f.write("charlie") }
        FileUtils.mkdir_p "#{base}/minispec"
        File.open("#{base}/minispec/beta", "wb") { |f| f.write("beta") }
        FileUtils.mkdir_p "#{base}/abba"
        File.open("#{base}/abba/alpha", "wb") { |f| f.write("alpha") }

        config[:ruby_bindir] = "/r"
      end

      it "uses bourne shell" do
        cmd.must_match(/\Ash -c '$/)
        cmd.must_match(/'\Z/)
      end

      it "sets the BUSSER_ROOT environment variable" do
        config[:root_path] = "/r"

        cmd.must_match regexify(%{BUSSER_ROOT="/r"}, :partial_line)
      end

      it "sets the GEM_HOME environment variable" do
        config[:root_path] = "/r"

        cmd.must_match regexify(%{GEM_HOME="/r/gems" }, :partial_line)
      end

      it "sets the GEM_PATH environment variable" do
        config[:root_path] = "/r"

        cmd.must_match regexify(%{GEM_PATH="/r/gems" }, :partial_line)
      end

      it "sets the GEM_CACHE environment variable" do
        config[:root_path] = "/r"

        cmd.must_match regexify(%{GEM_CACHE="/r/gems/cache" }, :partial_line)
      end

      it "exports all the environment variables" do
        cmd.must_match regexify(
          "export BUSSER_ROOT GEM_HOME GEM_PATH GEM_CACHE", :partial_line)
      end

      it "uses sudo for busser test when configured" do
        config[:sudo] = true
        config[:busser_bin] = "/p/b"

        cmd.must_match regexify("sudo -E /p/b test", :partial_line)
      end

      it "does not use sudo for busser test when configured" do
        config[:sudo] = false
        config[:busser_bin] = "/p/b"

        cmd.must_match regexify("/p/b test", :partial_line)
        cmd.wont_match regexify("sudo -E /p/b test", :partial_line)
      end
    end
  end

  def regexify(str, line = :whole_line)
    r = Regexp.escape(str)
    r = "^\s*#{r}$" if line == :whole_line
    Regexp.new(r)
  end
end
