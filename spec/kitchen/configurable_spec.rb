#
# Author:: Fletcher Nichol (<fnichol@nichol.ca>)
#
# Copyright (C) 2014, Fletcher Nichol
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require_relative "../spec_helper"
require "stringio"

require "kitchen"
require "kitchen/errors"
require "kitchen/configurable"

module Kitchen
  module Thing
    class Tiny
      include Kitchen::Configurable

      attr_reader :instance

      def initialize(config = {})
        init_config(config)
        @instance = config[:instance]
      end
    end

    class Versioned < Tiny
      plugin_version "1.8.17"
    end

    class StaticDefaults
      include Kitchen::Configurable

      default_config :beans, "kidney"
      default_config :tunables, "flimflam" => "positate"
      default_config :edible, true
      default_config :fetch_command, "curl"
      default_config :success_path, "./success"
      default_config :bunch_of_paths, %w{./a ./b ./c}
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
      expand_path_for :bunch_of_paths
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
  let(:config)    { {} }
  let(:platform)  { stub }
  let(:instance) do
    stub(name: "coolbeans", to_str: "<instance>", platform: platform)
  end

  let(:subject) do
    Kitchen::Thing::Tiny.new(config).finalize_config!(instance)
  end

  describe "creation and setup" do
    it "#instance returns its instance" do
      _(subject.instance).must_equal instance
    end

    it "#finalize_config! raises ClientError if instance is nil" do
      _ { Kitchen::Thing::Tiny.new({}).finalize_config!(nil) }
        .must_raise(Kitchen::ClientError)
    end

    it "#finalize_config! returns self for chaining" do
      t = Kitchen::Thing::Tiny.new({})
      _(t.finalize_config!(instance)).must_equal t
    end
  end

  describe "configuration" do
    describe "provided from the outside" do
      it "returns provided config" do
        config[:fruit] = %w{apples oranges}
        config[:cool_enough] = true

        _(subject[:fruit]).must_equal %w{apples oranges}
        _(subject[:cool_enough]).must_equal true
      end
    end

    describe "using static default_config statements" do
      let(:config) do
        { need_it: true, a_default: true }
      end

      let(:subject) do
        Kitchen::Thing::StaticDefaults.new(config).finalize_config!(instance)
      end

      it "uses defaults" do
        _(subject[:beans]).must_equal "kidney"
        _(subject[:tunables]["flimflam"]).must_equal "positate"
        _(subject[:edible]).must_equal true
      end

      it "uses provided config over default_config" do
        config[:beans] = "pinto"
        config[:edible] = false

        _(subject[:beans]).must_equal "pinto"
        _(subject[:edible]).must_equal false
      end

      it "uses other config values to compute values" do
        _(subject[:beans_url]).must_equal "http://gim.me/kidney"
        _(subject[:command]).must_equal "curl http://gim.me/kidney"
      end

      it "computed value blocks have access to instance object" do
        _(subject[:fetch_url]).must_equal "http://gim.me/beans-for/coolbeans"
      end

      it "uses provided config over default_config for computed values" do
        config[:command] = "echo listentome"
        config[:beans] = "pinto"

        _(subject[:command]).must_equal "echo listentome"
        _(subject[:beans_url]).must_equal "http://gim.me/pinto"
      end
    end

    describe "using inherited static default_config statements" do
      let(:config) do
        { need_it: true, a_default: "please" }
      end

      let(:subject) do
        Kitchen::Thing::SubclassDefaults.new(config).finalize_config!(instance)
      end

      it "contains defaults from superclass" do
        _(subject[:beans]).must_equal "kidney"
        _(subject[:tunables]["flimflam"]).must_equal "positate"
        _(subject[:edible]).must_equal true
        _(subject[:yea]).must_equal "ya"
      end

      it "uses provided config over default config" do
        config[:beans] = "pinto"
        config[:edible] = false

        _(subject[:beans]).must_equal "pinto"
        _(subject[:edible]).must_equal false
        _(subject[:yea]).must_equal "ya"
        _(subject[:beans_url]).must_equal "http://gim.me/pinto"
      end

      it "uses its own default_config over inherited default_config" do
        _(subject[:fetch_url]).must_equal "http://no.beans"
        _(subject[:command]).must_equal "wget http://gim.me/kidney"
      end
    end

    describe "using static required_config statements" do
      let(:config) do
        { a_default: true }
      end

      let(:subject) do
        Kitchen::Thing::StaticDefaults.new(config).finalize_config!(instance)
      end

      it "uses a value when provided" do
        config[:need_it] = "okay"

        _(subject[:need_it]).must_equal "okay"
      end

      it "without a block, raises a UserError if attr is nil" do
        config[:need_it] = nil

        begin
          subject
          flunk "UserError must be raised"
        rescue Kitchen::UserError => e
          attr = "Kitchen::Thing::StaticDefaults<instance>#config[:need_it]"
          _(e.message).must_equal "#{attr} cannot be blank"
        end
      end

      it "without a block, raises a UserError if attr is an empty string" do
        config[:need_it] = ""

        begin
          subject
          flunk "UserError must be raised"
        rescue Kitchen::UserError => e
          attr = "Kitchen::Thing::StaticDefaults<instance>#config[:need_it]"
          _(e.message).must_equal "#{attr} cannot be blank"
        end
      end

      it "with a block, it is saved and invoked" do
        config[:need_it] = "okay"
        config[:no_nuts] = "nuts"

        begin
          subject
          flunk "UserError must be raised"
        rescue Kitchen::UserError => e
          _(e.message).must_equal "NO NUTS FOR no_nuts!"
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
          _(e.message).must_equal "#{attr} cannot be blank"
        end
      end

      it "uses its own require_config over inherited require_config" do
        config[:need_it] = true
        config[:a_default] = nil

        begin
          subject
          flunk "UserError must be raised"
        rescue Kitchen::UserError => e
          _(e.message).must_equal "Overriding a_default is fun"
        end
      end
    end

    describe "using static expand_path_for statements" do
      let(:config) do
        { need_it: "a", a_default: "b", kitchen_root: "/tmp/yo/self" }
      end

      let(:subject) do
        Kitchen::Thing::StaticDefaults.new(config).finalize_config!(instance)
      end

      it "expands a default value" do
        _(subject[:success_path]).must_equal os_safe_root_path("/tmp/yo/self/success")
      end

      it "uses provided config over default_config" do
        config[:success_path] = "mine"

        _(subject[:success_path]).must_equal os_safe_root_path("/tmp/yo/self/mine")
      end

      it "leaves a full path expanded" do
        config[:success_path] = "/the/other/one"

        _(subject[:success_path]).must_equal os_safe_root_path("/the/other/one")
      end

      it "expands all items if path is an array" do
        paths = %w{
          /tmp/yo/self/a /tmp/yo/self/b /tmp/yo/self/c
        }
        os_safe_paths = paths.collect { |path| os_safe_root_path(path) }
        _(subject[:bunch_of_paths]).must_equal os_safe_paths
      end

      it "doesn't expand path with a falsy expand_path_for value" do
        config[:relative_path] = "./rel"

        _(subject[:relative_path]).must_equal "./rel"
      end

      it "expands a path if a lambda returns truthy" do
        config[:something_else] = "is_set"
        config[:complex_path] = "./complex"

        _(subject[:complex_path]).must_equal os_safe_root_path("/tmp/yo/self/complex")
      end

      it "leaves a nil config value as nil" do
        config[:success_path] = nil

        _(subject[:success_path]).must_be_nil
      end

      it "leaves a false config value as false" do
        config[:success_path] = false

        _(subject[:success_path]).must_equal false
      end
    end

    describe "using inherited static expand_path_for statements" do
      let(:config) do
        { need_it: "a", a_default: "please", kitchen_root: "/rooty" }
      end

      let(:subject) do
        Kitchen::Thing::SubclassDefaults.new(config).finalize_config!(instance)
      end

      it "contains expand_path_for from superclass" do
        _(subject[:success_path]).must_equal os_safe_root_path("/rooty/success")
      end

      it "uses its own expand_path_for over inherited expand_path_for" do
        config[:another_path] = "./pp"

        _(subject[:another_path]).must_equal "./pp"
      end
    end

    it "#config_keys returns an array of config key names" do
      subject = Kitchen::Thing::Tiny.new(ice_cream: "dragon")

      _(subject.config_keys.sort).must_equal [:ice_cream]
    end
  end

  it "#name returns the name of the plugin" do
    _(subject.name).must_equal "Tiny"
  end

  describe "#diagnose" do
    it "returns an empty hash for no config" do
      _(subject.diagnose).must_equal({})
    end

    it "returns a hash of config" do
      config[:alpha] = "beta"
      _(subject.diagnose).must_equal(alpha: "beta")
    end

    it "returns a hash with sorted keys" do
      config[:zebra] = true
      config[:elephant] = true

      _(subject.diagnose.keys).must_equal %i{elephant zebra}
    end
  end

  describe "#diagnose_plugin" do
    it "returns a plugin hash for a plugin without version" do
      _(subject.diagnose_plugin).must_equal(
        name: "Tiny", class: "Kitchen::Thing::Tiny",
        version: nil, api_version: nil
      )
    end

    it "returns a plugin hash for a plugin with version" do
      subject = Kitchen::Thing::Versioned.new(config).finalize_config!(instance)
      _(subject.diagnose_plugin).must_equal(
        name: "Versioned", class: "Kitchen::Thing::Versioned",
        version: "1.8.17", api_version: nil
      )
    end
  end

  describe "#calculate_path" do
    let(:config) do
      { test_base_path: "/the/basest" }
    end

    let(:suite) do
      stub(name: "ultimate")
    end

    let(:instance) do
      stub(name: "coolbeans", to_str: "<instance>", suite: suite)
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
        _(subject.calculate_path("winner"))
          .must_equal "/the/basest/ultimate/winner"
      end

      it "prefers a path containing base path if it exists" do
        FileUtils.rm_rf("/the/basest/ultimate/winner")

        _(subject.calculate_path("winner")).must_equal "/the/basest/winner"
      end

      it "prefers a path in the current working directory if it exists" do
        FileUtils.rm_rf("/the/basest/ultimate/winner")
        FileUtils.rm_rf("/the/basest/winner")
        pwd_dir = File.join(Dir.pwd, "winner")

        _(subject.calculate_path("winner")).must_equal pwd_dir
      end

      it "raises a UserError if test_base_path key is not set" do
        config.delete(:test_base_path)

        _ { subject.calculate_path("winner") }.must_raise Kitchen::UserError
      end

      it "uses a custom base path" do
        FileUtils.mkdir_p("/custom/ultimate/winner")

        _(subject.calculate_path("winner", base_path: "/custom"))
          .must_equal "/custom/ultimate/winner"
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
        _(subject.calculate_path("winner", type: :file))
          .must_equal "/the/basest/ultimate/winner"
      end

      it "prefers a path containing base path if it exists" do
        FileUtils.rm_rf("/the/basest/ultimate/winner")

        _(subject.calculate_path("winner", type: :file))
          .must_equal "/the/basest/winner"
      end

      it "prefers a path in the current working directory if it exists" do
        FileUtils.rm_rf("/the/basest/ultimate/winner")
        FileUtils.rm_rf("/the/basest/winner")
        pwd_dir = File.join(Dir.pwd, "winner")

        _(subject.calculate_path("winner", type: :file))
          .must_equal pwd_dir
      end

      it "raises a UserError if test_base_path key is not set" do
        config.delete(:test_base_path)

        _ { subject.calculate_path("winner") }.must_raise Kitchen::UserError
      end

      it "uses a custom base path" do
        FileUtils.mkdir_p("/custom/ultimate")
        FileUtils.touch(File.join("/custom/ultimate", "winner"))

        _(subject.calculate_path("winner", type: :file, base_path: "/custom"))
          .must_equal "/custom/ultimate/winner"
      end
    end
  end

  describe "#remote_path_join" do
    it "returns unix style path separators for unix os_type" do
      platform.stubs(:os_type).returns("unix")

      _(subject.remote_path_join("a", "b", "c"))
        .must_equal "a/b/c"
    end

    it "returns windows style path separators for windows os_type" do
      platform.stubs(:os_type).returns("windows")

      _(subject.remote_path_join("a", "b", "c"))
        .must_equal 'a\\b\\c'
    end

    it "accepts combinations of strings and arrays" do
      platform.stubs(:os_type).returns("unix")

      _(subject.remote_path_join(%w{a b}, "c", %w{d e}))
        .must_equal "a/b/c/d/e"
    end

    it "accepts a single array" do
      platform.stubs(:os_type).returns("windows")

      _(subject.remote_path_join(%w{a b}))
        .must_equal 'a\\b'
    end

    it "converts all windows path separators to unix for unix os_type" do
      platform.stubs(:os_type).returns("unix")

      _(subject.remote_path_join('\\a\\b', "c/d"))
        .must_equal "/a/b/c/d"
    end

    it "converts all unix path separators to windows for windows os_type" do
      platform.stubs(:os_type).returns("windows")

      _(subject.remote_path_join("/a/b", 'c\\d'))
        .must_equal '\\a\\b\\c\\d'
    end
  end

  describe "#windows_os?" do
    it "for windows type platform returns true" do
      platform.stubs(:os_type).returns("windows")

      _(subject.windows_os?).must_equal true
    end

    it "for unix type platform returns false" do
      platform.stubs(:os_type).returns("unix")

      _(subject.windows_os?).must_equal false
    end

    it "for newfangled type platform return false" do
      platform.stubs(:os_type).returns("internet_cat")

      _(subject.windows_os?).must_equal false
    end

    it "for unset type platform returns false" do
      platform.stubs(:os_type).returns(nil)

      _(subject.windows_os?).must_equal false
    end
  end

  describe "#unix_os?" do
    it "for windows type platform returns false" do
      platform.stubs(:os_type).returns("windows")

      _(subject.unix_os?).must_equal false
    end

    it "for unix type platform returns true" do
      platform.stubs(:os_type).returns("unix")

      _(subject.unix_os?).must_equal true
    end

    it "for newfangled type platform return false" do
      platform.stubs(:os_type).returns("internet_cat")

      _(subject.unix_os?).must_equal false
    end

    it "for unset type platform returns true" do
      platform.stubs(:os_type).returns(nil)

      _(subject.unix_os?).must_equal true
    end
  end

  describe "#powershell_shell?" do
    it "for powershell type shell returns true" do
      platform.stubs(:shell_type).returns("powershell")

      _(subject.powershell_shell?).must_equal true
    end

    it "for bourne type shell returns false" do
      platform.stubs(:shell_type).returns("bourne")

      _(subject.powershell_shell?).must_equal false
    end

    it "for newfangled type shell return false" do
      platform.stubs(:shell_type).returns("internet_cat")

      _(subject.powershell_shell?).must_equal false
    end

    it "for unset type shell returns false" do
      platform.stubs(:shell_type).returns(nil)

      _(subject.powershell_shell?).must_equal false
    end
  end

  describe "#bourne_shell?" do
    it "for powershell type shell returns false" do
      platform.stubs(:shell_type).returns("powershell")

      _(subject.bourne_shell?).must_equal false
    end

    it "for bourne type shell returns true" do
      platform.stubs(:shell_type).returns("bourne")

      _(subject.bourne_shell?).must_equal true
    end

    it "for newfangled type shell return false" do
      platform.stubs(:shell_type).returns("internet_cat")

      _(subject.bourne_shell?).must_equal false
    end

    it "for unset type shell returns true" do
      platform.stubs(:shell_type).returns(nil)

      _(subject.bourne_shell?).must_equal true
    end
  end

  describe "#shell_env_var" do
    it "for powershell type shells returns a powershell environment variable" do
      platform.stubs(:shell_type).returns("powershell")

      _(subject.send(:shell_env_var, "foo", "bar"))
        .must_equal %{$env:foo = "bar"}
    end

    it "for bourne type shells returns a bourne environment variable" do
      platform.stubs(:shell_type).returns("bourne")

      _(subject.send(:shell_env_var, "foo", "bar"))
        .must_equal %{foo="bar"; export foo}
    end
  end

  describe "#shell_var" do
    it "for powershell type shells returns a powershell variable" do
      platform.stubs(:shell_type).returns("powershell")

      _(subject.send(:shell_var, "foo", "bar")).must_equal %{$foo = "bar"}
    end

    it "for bourne type shells returns a bourne variable" do
      platform.stubs(:shell_type).returns("bourne")

      _(subject.send(:shell_var, "foo", "bar")).must_equal %{foo="bar"}
    end
  end

  describe "#wrap_shell_code" do
    let(:cmd) { subject.send(:wrap_shell_code, "mkdir foo") }

    before do
      @original_env = ENV.to_hash
      ENV.replace("http_proxy"  => nil, "HTTP_PROXY"  => nil,
                  "https_proxy" => nil, "HTTPS_PROXY" => nil,
                  "ftp_proxy"   => nil, "FTP_PROXY"   => nil,
                  "no_proxy"    => nil, "NO_PROXY"    => nil,
                  "CI"          => nil)
    end

    after do
      ENV.clear
      ENV.replace(@original_env)
    end

    describe "for bourne shells" do
      before { platform.stubs(:shell_type).returns("bourne") }

      it "uses bourne shell (sh)" do
        _(cmd).must_equal(outdent!(<<-CODE.chomp))
          sh -c '
          TEST_KITCHEN="1"; export TEST_KITCHEN
          mkdir foo
          '
        CODE
      end

      it "exports http_proxy & HTTP_PROXY when :http_proxy is set" do
        config[:http_proxy] = "http://proxy"

        _(cmd).must_equal(outdent!(<<-CODE.chomp))
          sh -c '
          http_proxy="http://proxy"; export http_proxy
          HTTP_PROXY="http://proxy"; export HTTP_PROXY
          TEST_KITCHEN="1"; export TEST_KITCHEN
          mkdir foo
          '
        CODE
      end

      it "exports https_proxy & HTTPS_PROXY when :https_proxy is set" do
        config[:https_proxy] = "https://proxy"

        _(cmd).must_equal(outdent!(<<-CODE.chomp))
          sh -c '
          https_proxy="https://proxy"; export https_proxy
          HTTPS_PROXY="https://proxy"; export HTTPS_PROXY
          TEST_KITCHEN="1"; export TEST_KITCHEN
          mkdir foo
          '
        CODE
      end

      it "exports ftp_proxy & FTP_PROXY when :ftp_proxy is set" do
        config[:ftp_proxy] = "ftp://proxy"

        _(cmd).must_equal(outdent!(<<-CODE.chomp))
          sh -c '
          ftp_proxy="ftp://proxy"; export ftp_proxy
          FTP_PROXY="ftp://proxy"; export FTP_PROXY
          TEST_KITCHEN="1"; export TEST_KITCHEN
          mkdir foo
          '
        CODE
      end

      it "exports all http proxy variables when all are set" do
        config[:http_proxy] = "http://proxy"
        config[:https_proxy] = "https://proxy"
        config[:ftp_proxy] = "ftp://proxy"
        config[:no_proxy] = "http://no"

        _(cmd).must_equal(outdent!(<<-CODE.chomp))
          sh -c '
          http_proxy="http://proxy"; export http_proxy
          HTTP_PROXY="http://proxy"; export HTTP_PROXY
          https_proxy="https://proxy"; export https_proxy
          HTTPS_PROXY="https://proxy"; export HTTPS_PROXY
          ftp_proxy="ftp://proxy"; export ftp_proxy
          FTP_PROXY="ftp://proxy"; export FTP_PROXY
          no_proxy="http://no"; export no_proxy
          NO_PROXY="http://no"; export NO_PROXY
          TEST_KITCHEN="1"; export TEST_KITCHEN
          mkdir foo
          '
        CODE
      end

      it "exports http_proxy & HTTP_PROXY from workstation when :http_proxy isn't set" do
        ENV["http_proxy"] = "http://proxy"
        ENV["HTTP_PROXY"] = "http://proxy"

        _(cmd).must_equal(outdent!(<<-CODE.chomp))
          sh -c '
          http_proxy="http://proxy"; export http_proxy
          HTTP_PROXY="http://proxy"; export HTTP_PROXY
          TEST_KITCHEN="1"; export TEST_KITCHEN
          mkdir foo
          '
        CODE
      end

      it "exports https_proxy & HTTPS_PROXY from workstation when :https_proxy isn't set" do
        ENV["https_proxy"] = "https://proxy"
        ENV["HTTPS_PROXY"] = "https://proxy"

        _(cmd).must_equal(outdent!(<<-CODE.chomp))
          sh -c '
          https_proxy="https://proxy"; export https_proxy
          HTTPS_PROXY="https://proxy"; export HTTPS_PROXY
          TEST_KITCHEN="1"; export TEST_KITCHEN
          mkdir foo
          '
        CODE
      end

      it "does not export http_proxy or HTTP_PROXY when :http_proxy is empty" do
        ENV["http_proxy"] = "http://proxy"
        ENV["HTTP_PROXY"] = "http://proxy"
        config[:http_proxy] = ""

        _(cmd).must_equal(outdent!(<<-CODE.chomp))
          sh -c '
          TEST_KITCHEN="1"; export TEST_KITCHEN
          mkdir foo
          '
        CODE
      end

      it "does not export https_proxy or HTTPS_PROXY when :https_proxy is empty" do
        ENV["https_proxy"] = "https://proxy"
        ENV["HTTPS_PROXY"] = "https://proxy"
        config[:https_proxy] = ""

        _(cmd).must_equal(outdent!(<<-CODE.chomp))
          sh -c '
          TEST_KITCHEN="1"; export TEST_KITCHEN
          mkdir foo
          '
        CODE
      end

      it "exports ftp_proxy & FTP_PROXY from workstation when :ftp_proxy isn't set" do
        ENV["ftp_proxy"] = "ftp://proxy"
        ENV["FTP_PROXY"] = "ftp://proxy"

        _(cmd).must_equal(outdent!(<<-CODE.chomp))
          sh -c '
          ftp_proxy="ftp://proxy"; export ftp_proxy
          FTP_PROXY="ftp://proxy"; export FTP_PROXY
          TEST_KITCHEN="1"; export TEST_KITCHEN
          mkdir foo
          '
        CODE
      end

      it "does not export ftp_proxy or FTP_PROXY when :ftp_proxy is empty" do
        config[:ftp_proxy] = ""

        _(cmd).must_equal(outdent!(<<-CODE.chomp))
          sh -c '
          TEST_KITCHEN="1"; export TEST_KITCHEN
          mkdir foo
          '
        CODE
      end

      it "exports no_proxy & NO_PROXY from workstation when http_proxy is set from workstation" do
        ENV["http_proxy"] = "http://proxy"
        ENV["HTTP_PROXY"] = "http://proxy"
        ENV["no_proxy"]   = "http://no"
        ENV["NO_PROXY"]   = "http://no"

        _(cmd).must_equal(outdent!(<<-CODE.chomp))
          sh -c '
          http_proxy="http://proxy"; export http_proxy
          HTTP_PROXY="http://proxy"; export HTTP_PROXY
          no_proxy="http://no"; export no_proxy
          NO_PROXY="http://no"; export NO_PROXY
          TEST_KITCHEN="1"; export TEST_KITCHEN
          mkdir foo
          '
        CODE
      end

      it "exports no_proxy & NO_PROXY from workstation when https_proxy is set from workstation" do
        ENV["https_proxy"] = "https://proxy"
        ENV["HTTPS_PROXY"] = "https://proxy"
        ENV["no_proxy"]   = "http://no"
        ENV["NO_PROXY"]   = "http://no"

        _(cmd).must_equal(outdent!(<<-CODE.chomp))
          sh -c '
          https_proxy="https://proxy"; export https_proxy
          HTTPS_PROXY="https://proxy"; export HTTPS_PROXY
          no_proxy="http://no"; export no_proxy
          NO_PROXY="http://no"; export NO_PROXY
          TEST_KITCHEN="1"; export TEST_KITCHEN
          mkdir foo
          '
        CODE
      end

      it "exports no_proxy & NO_PROXY from workstation when ftp_proxy is set from workstation" do
        ENV["ftp_proxy"]  = "ftp://proxy"
        ENV["FTP_PROXY"]  = "ftp://proxy"
        ENV["no_proxy"]   = "http://no"
        ENV["NO_PROXY"]   = "http://no"

        _(cmd).must_equal(outdent!(<<-CODE.chomp))
          sh -c '
          ftp_proxy="ftp://proxy"; export ftp_proxy
          FTP_PROXY="ftp://proxy"; export FTP_PROXY
          no_proxy="http://no"; export no_proxy
          NO_PROXY="http://no"; export NO_PROXY
          TEST_KITCHEN="1"; export TEST_KITCHEN
          mkdir foo
          '
        CODE
      end

      it "exports CI when CI is set" do
        ENV["CHEF_LICENSE"] = nil
        ENV["CI"] = "1"

        _(cmd).must_equal(outdent!(<<-CODE.chomp))
          sh -c '
          TEST_KITCHEN="1"; export TEST_KITCHEN
          CI="1"; export CI
          mkdir foo
          '
        CODE
      end

      it "exports FOO when TKENV_FOO is set" do
        ENV["CHEF_LICENSE"] = nil
        ENV["TKENV_FOO"] = "BAR"

        _(cmd).must_equal(outdent!(<<-CODE.chomp))
          sh -c '
          TEST_KITCHEN="1"; export TEST_KITCHEN
          FOO="BAR"; export FOO
          mkdir foo
          '
        CODE
      end

      it "exports CHEF_LICENSE when CHEF_LICENSE is set" do
        ENV["CHEF_LICENSE"] = "FOO"

        _(cmd).must_equal(outdent!(<<-CODE.chomp))
          sh -c '
          TEST_KITCHEN="1"; export TEST_KITCHEN
          CHEF_LICENSE="FOO"; export CHEF_LICENSE
          mkdir foo
          '
        CODE
      end
    end

    describe "for powershell shells" do
      before { platform.stubs(:shell_type).returns("powershell") }

      it "uses powershell shell" do
        _(cmd).must_equal("$env:TEST_KITCHEN = \"1\"\nmkdir foo")
      end

      it "exports http_proxy & HTTP_PROXY when :http_proxy is set" do
        config[:http_proxy] = "http://proxy"

        _(cmd).must_equal(outdent!(<<-CODE.chomp))
          $env:http_proxy = "http://proxy"
          $env:HTTP_PROXY = "http://proxy"
          $env:TEST_KITCHEN = "1"
          mkdir foo
        CODE
      end

      it "exports https_proxy & HTTPS_PROXY when :https_proxy is set" do
        config[:https_proxy] = "https://proxy"

        _(cmd).must_equal(outdent!(<<-CODE.chomp))
          $env:https_proxy = "https://proxy"
          $env:HTTPS_PROXY = "https://proxy"
          $env:TEST_KITCHEN = "1"
          mkdir foo
        CODE
      end

      it "exports ftp_proxy & FTP_PROXY when :ftp_proxy is set" do
        config[:ftp_proxy] = "ftp://proxy"

        _(cmd).must_equal(outdent!(<<-CODE.chomp))
          $env:ftp_proxy = "ftp://proxy"
          $env:FTP_PROXY = "ftp://proxy"
          $env:TEST_KITCHEN = "1"
          mkdir foo
        CODE
      end

      it "exports all http proxy variables when all are set" do
        config[:http_proxy] = "http://proxy"
        config[:https_proxy] = "https://proxy"
        config[:ftp_proxy] = "ftp://proxy"

        _(cmd).must_equal(outdent!(<<-CODE.chomp))
          $env:http_proxy = "http://proxy"
          $env:HTTP_PROXY = "http://proxy"
          $env:https_proxy = "https://proxy"
          $env:HTTPS_PROXY = "https://proxy"
          $env:ftp_proxy = "ftp://proxy"
          $env:FTP_PROXY = "ftp://proxy"
          $env:TEST_KITCHEN = "1"
          mkdir foo
        CODE
      end

      it "exports http_proxy & HTTP_PROXY from workstation when :http_proxy isn't set" do
        ENV["http_proxy"] = "http://proxy"
        ENV["HTTP_PROXY"] = "http://proxy"

        _(cmd).must_equal(outdent!(<<-CODE.chomp))
          $env:http_proxy = "http://proxy"
          $env:HTTP_PROXY = "http://proxy"
          $env:TEST_KITCHEN = "1"
          mkdir foo
        CODE
      end

      it "exports https_proxy & HTTPS_PROXY from workstation when :https_proxy isn't set" do
        ENV["https_proxy"] = "https://proxy"
        ENV["HTTPS_PROXY"] = "https://proxy"

        _(cmd).must_equal(outdent!(<<-CODE.chomp))
          $env:https_proxy = "https://proxy"
          $env:HTTPS_PROXY = "https://proxy"
          $env:TEST_KITCHEN = "1"
          mkdir foo
        CODE
      end

      it "exports ftp_proxy & FTP_PROXY from workstation when :ftp_proxy isn't set" do
        ENV["ftp_proxy"] = "ftp://proxy"
        ENV["FTP_PROXY"] = "ftp://proxy"

        _(cmd).must_equal(outdent!(<<-CODE.chomp))
          $env:ftp_proxy = "ftp://proxy"
          $env:FTP_PROXY = "ftp://proxy"
          $env:TEST_KITCHEN = "1"
          mkdir foo
        CODE
      end

      it "exports no_proxy & NO_PROXY from workstation when http_proxy is set from workstation" do
        ENV["http_proxy"] = "http://proxy"
        ENV["HTTP_PROXY"] = "http://proxy"
        ENV["no_proxy"]   = "http://no"
        ENV["NO_PROXY"]   = "http://no"

        _(cmd).must_equal(outdent!(<<-CODE.chomp))
          $env:http_proxy = "http://proxy"
          $env:HTTP_PROXY = "http://proxy"
          $env:no_proxy = "http://no"
          $env:NO_PROXY = "http://no"
          $env:TEST_KITCHEN = "1"
          mkdir foo
        CODE
      end

      it "exports no_proxy & NO_PROXY from workstation when https_proxy is set from workstation" do
        ENV["https_proxy"] = "https://proxy"
        ENV["HTTPS_PROXY"] = "https://proxy"
        ENV["no_proxy"]   = "http://no"
        ENV["NO_PROXY"]   = "http://no"

        _(cmd).must_equal(outdent!(<<-CODE.chomp))
          $env:https_proxy = "https://proxy"
          $env:HTTPS_PROXY = "https://proxy"
          $env:no_proxy = "http://no"
          $env:NO_PROXY = "http://no"
          $env:TEST_KITCHEN = "1"
          mkdir foo
        CODE
      end

      it "exports no_proxy & NO_PROXY from workstation when ftp_proxy is set from workstation" do
        ENV["ftp_proxy"] = "ftp://proxy"
        ENV["FTP_PROXY"] = "ftp://proxy"
        ENV["no_proxy"]   = "http://no"
        ENV["NO_PROXY"]   = "http://no"

        _(cmd).must_equal(outdent!(<<-CODE.chomp))
          $env:ftp_proxy = "ftp://proxy"
          $env:FTP_PROXY = "ftp://proxy"
          $env:no_proxy = "http://no"
          $env:NO_PROXY = "http://no"
          $env:TEST_KITCHEN = "1"
          mkdir foo
        CODE
      end

      it "exports CI when CI is set" do
        ENV["CHEF_LICENSE"] = nil
        ENV["CI"] = "1"

        _(cmd).must_equal(outdent!(<<-CODE.chomp))
          $env:TEST_KITCHEN = "1"
          $env:CI = "1"
          mkdir foo
        CODE
      end

      it "exports FOO when TKENV_FOO is set" do
        ENV["CHEF_LICENSE"] = nil
        ENV["TKENV_FOO"] = "BAR"

        _(cmd).must_equal(outdent!(<<-CODE.chomp))
          $env:TEST_KITCHEN = "1"
          $env:FOO = "BAR"
          mkdir foo
        CODE
      end

      it "exports CHEF_LICENSE when CHEF_LICENSE is set" do
        ENV["CHEF_LICENSE"] = "FOO"

        _(cmd).must_equal(outdent!(<<-CODE.chomp))
          $env:TEST_KITCHEN = "1"
          $env:CHEF_LICENSE = "FOO"
          mkdir foo
        CODE
      end
    end
  end

  it "has a default verify dependencies method" do
    _(subject.verify_dependencies).must_be_nil
  end

  describe "#logger" do
    before  { @klog = Kitchen.logger }
    after   { Kitchen.logger = @klog }

    it "returns the instance's logger" do
      logger = stub("logger")
      instance = stub(logger: logger)
      subject = Kitchen::Thing::Tiny.new(config.merge(instance: instance))
      _(subject.send(:logger)).must_equal logger
    end

    it "returns the default logger if instance's logger is not set" do
      subject = Kitchen::Thing::Tiny.new(config)
      Kitchen.logger = "yep"

      _(subject.send(:logger)).must_equal Kitchen.logger
    end
  end

  def outdent!(*args)
    Kitchen::Util.outdent!(*args)
  end
end
