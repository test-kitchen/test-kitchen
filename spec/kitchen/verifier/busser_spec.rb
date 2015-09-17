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
        :perms => (running_tests_on_windows? ? "0644" : "0764")
      },
      "minispec/beta" => {
        :content => "beta",
        :perms => "0644"
      },
      "abba/alpha" => {
        :content => "alpha",
        :perms => (running_tests_on_windows? ? "0444" : "0440")
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
        :perms => (running_tests_on_windows? ? "0644" : "0664")
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

  it "verifier api_version is 1" do
    verifier.diagnose_plugin[:api_version].must_equal 1
  end

  it "plugin_version is set to Kitchen::VERSION" do
    verifier.diagnose_plugin[:version].must_equal Kitchen::VERSION
  end

  describe "configuration" do

    describe "for unix operating systems" do

      before {
        platform.stubs(:os_type).returns("unix")
      }

      it ":ruby_bindir defaults the an Omnibus Chef installation" do
        verifier[:ruby_bindir].must_equal "/opt/chef/embedded/bin"
      end

      it ":busser_bin defaults to a binstub under :root_path" do
        config[:root_path] = "/beep"

        verifier[:busser_bin].must_equal "/beep/bin/busser"
      end
    end

    describe "for windows operating systems" do

      before { platform.stubs(:os_type).returns("windows") }

      it ":ruby_bindir defaults the an Omnibus Chef installation" do
        verifier[:ruby_bindir].
          must_equal "$env:systemdrive\\opscode\\chef\\embedded\\bin"
      end

      it ":busser_bin defaults to a binstub under :root_path" do
        config[:root_path] = "\\beep"

        verifier[:busser_bin].must_equal "\\beep\\bin\\busser.bat"
      end
    end

    it ":version defaults to 'busser'" do
      verifier[:version].must_equal "busser"
    end
  end

  def self.common_bourne_variable_specs
    it "uses bourne shell" do
      cmd.must_match(/\Ash -c '$/)
      cmd.must_match(/'\Z/)
    end

    it "ends with a single quote" do
      cmd.must_match(/'\Z/)
    end

    it "sets the BUSSER_ROOT environment variable" do
      cmd.must_match regexify(%{BUSSER_ROOT="/r"; export BUSSER_ROOT})
    end

    it "sets the GEM_HOME environment variable" do
      cmd.must_match regexify(%{GEM_HOME="/r/gems"; export GEM_HOME})
    end

    it "sets the GEM_PATH environment variable" do
      cmd.must_match regexify(%{GEM_PATH="/r/gems"; export GEM_PATH})
    end

    it "sets the GEM_CACHE environment variable" do
      cmd.must_match regexify(%{GEM_CACHE="/r/gems/cache"; export GEM_CACHE})
    end
  end

  def self.common_powershell_variable_specs
    it "sets the BUSSER_ROOT environment variable" do
      cmd.must_match regexify(%{$env:BUSSER_ROOT = "\\r"})
    end

    it "sets the GEM_HOME environment variable" do
      cmd.must_match regexify(%{$env:GEM_HOME = "\\r\\gems"})
    end

    it "sets the GEM_PATH environment variable" do
      cmd.must_match regexify(%{$env:GEM_PATH = "\\r\\gems"})
    end

    it "sets the GEM_CACHE environment variable" do
      cmd.must_match regexify(%{$env:GEM_CACHE = "\\r\\gems\\cache"})
    end
  end

  describe "#install_command" do

    let(:cmd) { verifier.install_command }

    describe "with no suite test files" do

      describe "for bourne shells" do

        before { platform.stubs(:shell_type).returns("bourne") }

        it "returns nil" do
          cmd.must_equal nil
        end
      end

      describe "for powershell shells on windows os types" do

        before do
          platform.stubs(:shell_type).returns("powershell")
          platform.stubs(:os_type).returns("windows")
        end

        it "returns nil" do
          cmd.must_equal nil
        end
      end
    end

    describe "with suite test files" do

      describe "for bourne shells" do

        before do
          platform.stubs(:shell_type).returns("bourne")
          create_test_files
          config[:ruby_bindir] = "/rbd"
          config[:root_path] = "/r"
        end

        common_bourne_variable_specs

        it "sets path to ruby command" do
          cmd.must_match regexify(%{ruby="/rbd/ruby"})
        end

        it "sets path to gem command" do
          cmd.must_match regexify(%{gem="/rbd/gem"})
        end

        it "sets version for busser" do
          config[:version] = "the_best"

          cmd.must_match regexify(%{version="the_best"})
        end

        it "sets gem install arguments" do
          cmd.must_match regexify(
            "gem_install_args=\"busser --no-rdoc --no-ri --no-format-executable" \
            " -n /r/bin --no-user-install\""
          )
        end

        it "prepends sudo for busser binstub command when :sudo is set" do
          cmd.must_match regexify(%{busser="sudo -E /r/bin/busser"})
        end

        it "does not sudo for busser binstub command when :sudo is falsey" do
          config[:sudo] = false

          cmd.must_match regexify(%{busser="/r/bin/busser"})
        end

        it "sets the busser plugins list" do
          cmd.must_match regexify(
            %{plugins="busser-abba busser-minispec busser-mondospec"})
        end
      end

      describe "for powershell shells on windows os types" do

        before do
          platform.stubs(:shell_type).returns("powershell")
          platform.stubs(:os_type).returns("windows")
          create_test_files
          config[:ruby_bindir] = "\\rbd"
          config[:root_path] = "\\r"
        end

        common_powershell_variable_specs

        it "sets path to ruby command" do
          cmd.must_match regexify(%{$ruby = "\\rbd\\ruby.exe"})
        end

        it "sets path to gem command" do
          cmd.must_match regexify(%{$gem = "\\rbd\\gem"})
        end

        it "sets version for busser" do
          config[:version] = "the_best"

          cmd.must_match regexify(%{$version = "the_best"})
        end

        it "sets gem install arguments" do
          cmd.must_match regexify(
            "$gem_install_args = \"busser --no-rdoc --no-ri --no-format-executable" \
            " -n \\r\\bin --no-user-install\""
          )
        end

        it "sets path to busser binstub command" do
          cmd.must_match regexify(%{$busser = "\\r\\bin\\busser.bat"})
        end

        it "sets the busser plugins list" do
          cmd.must_match regexify(
            %{$plugins = "busser-abba busser-minispec busser-mondospec"})
        end
      end
    end
  end

  describe "#init_command" do

    let(:cmd) { verifier.init_command }

    describe "with no suite test files" do

      describe "for bourne shells" do

        before { platform.stubs(:shell_type).returns("bourne") }

        it "returns nil" do
          cmd.must_equal nil
        end
      end

      describe "for powershell shells on windows os types" do

        before do
          platform.stubs(:shell_type).returns("powershell")
          platform.stubs(:os_type).returns("windows")
        end

        it "returns nil" do
          cmd.must_equal nil
        end
      end
    end

    describe "with suite test files" do

      describe "for bourne shells" do

        before do
          platform.stubs(:shell_type).returns("bourne")
          create_test_files
          config[:ruby_bindir] = "/rbd"
          config[:root_path] = "/r"
        end

        common_bourne_variable_specs

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

      describe "for powershell shells on windows os types" do

        before do
          platform.stubs(:shell_type).returns("powershell")
          platform.stubs(:os_type).returns("windows")
          create_test_files
          config[:ruby_bindir] = "\\rbd"
          config[:root_path] = "\\r"
        end

        common_powershell_variable_specs

        it "runs busser's suite cleanup" do
          config[:root_path] = "\\b"

          cmd.must_match regexify(%{& \\b\\bin\\busser.bat suite cleanup})
        end
      end
    end
  end

  describe "#run_command" do

    let(:cmd) { verifier.run_command }

    describe "with no suite test files" do

      describe "for bourne shells" do

        before { platform.stubs(:shell_type).returns("bourne") }

        it "returns nil" do
          cmd.must_equal nil
        end
      end

      describe "for powershell shells on windows os types" do

        before do
          platform.stubs(:shell_type).returns("powershell")
          platform.stubs(:os_type).returns("windows")
        end

        it "returns nil" do
          cmd.must_equal nil
        end
      end
    end

    describe "with suite test files" do

      describe "for bourne shells" do

        before do
          platform.stubs(:shell_type).returns("bourne")
          create_test_files
          config[:ruby_bindir] = "/rbd"
          config[:root_path] = "/r"
        end

        common_bourne_variable_specs

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

      describe "for powershell shells on windows os types" do

        before do
          platform.stubs(:shell_type).returns("powershell")
          platform.stubs(:os_type).returns("windows")
          create_test_files
          config[:ruby_bindir] = "\\rbd"
          config[:root_path] = "\\r"
        end

        common_powershell_variable_specs

        it "runs busser's test" do
          config[:root_path] = "\\b"

          cmd.must_match regexify(%{& \\b\\bin\\busser.bat test})
        end
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

  describe "Busser legacy behavior for code calling old method names" do

    let(:busser) { verifier }

    it "responds to #setup_cmd which calls #install_command" do
      busser.stubs(:install_command).returns("install")

      busser.setup_cmd.must_equal "install"
    end

    it "responds to #run_cmd which calls #run_command" do
      busser.stubs(:run_command).returns("run")

      busser.run_cmd.must_equal "run"
    end

    it "responds to #sync_cmd which logs a warning" do
      busser.sync_cmd

      logged_output.string.must_match warn_line_with(
        "Legacy call to #sync_cmd cannot be preserved")
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

  def warn_line_with(msg)
    %r{^W, .* : #{Regexp.escape(msg)}}
  end
end
