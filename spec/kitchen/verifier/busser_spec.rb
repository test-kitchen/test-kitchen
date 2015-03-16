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

require_relative "../../spec_helper"

require "kitchen"
require "kitchen/verifier/busser"

describe Kitchen::Verifier::Busser do

  let(:logged_output) { StringIO.new }
  let(:logger)        { Logger.new(logged_output) }
  let(:config)        { Hash.new }
  let(:platform)      { stub(:os_type => nil, :shell_type => nil) }
  let(:suite)         { stub(:name => "germany") }

  let(:instance) do
    stub(
      :name => "coolbeans",
      :logger => logger,
      :platform => platform,
      :suite => suite,
      :to_str => "instance"
    )
  end

  let(:verifier) do
    Kitchen::Verifier::Busser.new(config).finalize_config!(instance)
  end

  let(:files) do
    {
      "mondospec/charlie" => {
        :content => "charlie",
        :perms => "0764"
      },
      "minispec/beta" => {
        :content => "beta",
        :perms => "0644"
      },
      "abba/alpha" => {
        :content => "alpha",
        :perms => "0440"
      }
    }
  end

  let(:helper_files) do
    {
      "minispec/spec_helper" => {
        :content => "helping",
        :perms => "0644"
      },
      "abba/common" => {
        :content => "yeppers",
        :perms => "0664"
      }
    }
  end

  before do
    @root = Dir.mktmpdir
    config[:test_base_path] = @root
  end

  after do
    FileUtils.remove_entry(@root)
  end

  # TODO: deal with this:
  # it "raises a UserError if the suite name is 'helper'" do
  #   proc {
  #     Kitchen::Busser.new("helper", config)
  #   }.must_raise Kitchen::UserError
  # end

  describe "configuration" do

    it ":ruby_bindir defaults the an Omnibus Chef installation" do
      verifier[:ruby_bindir].must_equal "/opt/chef/embedded/bin"
    end

    it ":version defaults to 'busser'" do
      verifier[:version].must_equal "busser"
    end

    it ":busser_bin defaults to a binstub under :root_path" do
      config[:root_path] = "/beep"

      verifier[:busser_bin].must_equal "/beep/bin/busser"
    end
  end

  describe "#install_command" do

    let(:cmd) { verifier.install_command }

    describe "with no suite test files" do

      it "returns nil" do
        cmd.must_equal nil
      end
    end

    describe "with suite test files" do

      before do
        create_test_files
        config[:ruby_bindir] = "/r"
      end

      it "uses bourne shell" do
        cmd.must_match(/\Ash -c '$/)
        cmd.must_match(/'\Z/)
      end

      it "ends with a single quote" do
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
          %{if ! /r/gem list busser -i >/dev/null;}, :partial_line)
      end

      describe "installing busser" do

        it "installs the latest busser gem by default" do
          cmd.must_match regexify(
            %{/r/gem install busser --no-rdoc --no-ri}, :partial_line)
        end

        it "installs a specific busser version gem" do
          config[:version] = "4.0.7"

          cmd.must_match regexify(
            %{/r/gem install busser --version 4.0.7 --no-rdoc --no-ri},
            :partial_line)
        end

        it "installs a specific busser version gem with @ syntax" do
          config[:version] = "busser@1.2.3"

          cmd.must_match regexify(
            %{/r/gem install busser --version 1.2.3 --no-rdoc --no-ri},
            :partial_line)
        end

        it "installs an arbitrary gem and version with @ syntax" do
          config[:version] = "foo@9.0.1"

          cmd.must_match regexify(
            %{/r/gem install foo --version 9.0.1 --no-rdoc --no-ri},
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
          %{${gem_bindir}/busser setup}, :partial_line)
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

  describe "#init_command" do

    let(:cmd) { verifier.init_command }

    describe "with no suite test files" do

      it "returns nil" do
        cmd.must_equal nil
      end
    end

    describe "with suite test files" do

      before do
        create_test_files
        config[:ruby_bindir] = "/r"
      end

      it "uses bourne shell" do
        cmd.must_match(/\Ash -c '$/)
        cmd.must_match(/'\Z/)
      end

      it "ends with a single quote" do
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

      it "runs busser's suite cleanup with sudo, if set" do
        config[:root_path] = "/b"
        config[:sudo] = true

        cmd.must_match regexify(%{sudo -E /b/bin/busser suite cleanup})
      end

      it "runs busser's suite cleanup without sudo, if falsey" do
        config[:root_path] = "/b"
        config[:sudo] = false

        cmd.wont_match regexify(%{sudo -E /b/bin/busser suite cleanup})
        cmd.must_match regexify(%{/b/bin/busser suite cleanup})
      end
    end
  end

  describe "#run_command" do

    let(:cmd) { verifier.run_command }

    describe "with no suite test files" do

      it "returns nil" do
        cmd.must_equal nil
      end
    end

    describe "with suite test files" do

      before do
        create_test_files
        config[:ruby_bindir] = "/r"
      end

      it "uses bourne shell" do
        cmd.must_match(/\Ash -c '$/)
        cmd.must_match(/'\Z/)
      end

      it "ends with a single quote" do
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

  describe "#create_sandbox" do

    before do
      create_test_files
    end

    it "copies each suite file into the suites directory in sandbox" do
      verifier.create_sandbox

      files.each do |f, md|
        file = sandbox_path("suites/#{f}")

        file.file?.must_equal true
        file.stat.mode.to_s(8)[2, 4].must_equal md[:perms]
        IO.read(file).must_equal md[:content]
      end
    end

    it "copies each helper file into the suites directory in sandbox" do
      verifier.create_sandbox

      helper_files.each do |f, md|
        file = sandbox_path("suites/#{f}")

        file.file?.must_equal true
        file.stat.mode.to_s(8)[2, 4].must_equal md[:perms]
        IO.read(file).must_equal md[:content]
      end
    end

    def sandbox_path(path)
      Pathname.new(verifier.sandbox_path).join(path)
    end
  end

  def create_file(file, content, perms)
    FileUtils.mkdir_p(File.dirname(file))
    File.open(file, "wb") { |f| f.write(content) }
    FileUtils.chmod(perms.to_i(8), file)
  end

  def create_test_files
    base = "#{config[:test_base_path]}/germany"
    hbase = "#{config[:test_base_path]}/helpers"

    files.map { |f, md| [File.join(base, f), md] }.each do |f, md|
      create_file(f, md[:content], md[:perms])
    end
    helper_files.map { |f, md| [File.join(hbase, f), md] }.each do |f, md|
      create_file(f, md[:content], md[:perms])
    end
  end

  def regexify(str, line = :whole_line)
    r = Regexp.escape(str)
    r = "^\s*#{r}$" if line == :whole_line
    Regexp.new(r)
  end
end
