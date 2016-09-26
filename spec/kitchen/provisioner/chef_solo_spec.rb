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
require "kitchen/provisioner/chef_solo"

describe Kitchen::Provisioner::ChefSolo do

  let(:logged_output)   { StringIO.new }
  let(:logger)          { Logger.new(logged_output) }
  let(:platform)        { stub(:os_type => nil) }
  let(:suite)           { stub(:name => "fries") }

  let(:config) do
    { :test_base_path => "/b", :kitchen_root => "/r" }
  end

  let(:instance) do
    stub(
      :name => "coolbeans",
      :logger => logger,
      :suite => suite,
      :platform => platform
    )
  end

  let(:provisioner) do
    Kitchen::Provisioner::ChefSolo.new(config).finalize_config!(instance)
  end

  it "provisioner api_version is 2" do
    provisioner.diagnose_plugin[:api_version].must_equal 2
  end

  it "plugin_version is set to Kitchen::VERSION" do
    provisioner.diagnose_plugin[:version].must_equal Kitchen::VERSION
  end

  describe "default config" do

    describe "for unix operating systems" do

      before { platform.stubs(:os_type).returns("unix") }

      it "sets :chef_solo_path to a path using :chef_omnibus_root" do
        config[:chef_omnibus_root] = "/nice/place"

        provisioner[:chef_solo_path].must_equal "/nice/place/bin/chef-solo"
      end
    end

    describe "for windows operating systems" do

      before { platform.stubs(:os_type).returns("windows") }

      it "sets :chef_solo_path to a path using :chef_omnibus_root" do
        config[:chef_omnibus_root] = "$env:systemdrive\\nice\\place"

        provisioner[:chef_solo_path].
          must_equal "$env:systemdrive\\nice\\place\\bin\\chef-solo.bat"
      end
    end

    it "sets :solo_rb to an empty Hash" do
      provisioner[:solo_rb].must_equal Hash.new
    end
  end

  describe "#create_sandbox" do

    before do
      @root = Dir.mktmpdir
      config[:kitchen_root] = @root
    end

    after do
      FileUtils.remove_entry(@root)
      begin
        provisioner.cleanup_sandbox
      rescue # rubocop:disable Lint/HandleExceptions
      end
    end

    describe "solo.rb file" do

      let(:file) do
        IO.read(sandbox_path("solo.rb")).lines.map(&:chomp)
      end

      it "creates a solo.rb" do
        provisioner.create_sandbox

        sandbox_path("solo.rb").file?.must_equal true
      end

      it "logs a message on info" do
        provisioner.create_sandbox

        logged_output.string.must_match info_line("Preparing solo.rb")
      end

      it "logs a message on debug" do
        provisioner.create_sandbox

        logged_output.string.
          must_match debug_line_starting_with("Creating solo.rb from {")
      end

      describe "defaults" do

        # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
        def self.common_solo_rb_specs
          it "sets node_name to the instance name" do
            file.must_include %{node_name "#{instance.name}"}
          end

          it "sets checksum_path" do
            file.must_include %{checksum_path "#{base}checksums"}
          end

          it "sets file_backup_path" do
            file.must_include %{file_backup_path "#{base}backup"}
          end

          it "sets cookbook_path" do
            file.must_include %{cookbook_path } +
              %{["#{base}cookbooks", "#{base}site-cookbooks"]}
          end

          it "sets data_bag_path" do
            file.must_include %{data_bag_path "#{base}data_bags"}
          end

          it "sets environment_path" do
            file.must_include %{environment_path "#{base}environments"}
          end

          it "sets node_path" do
            file.must_include %{node_path "#{base}nodes"}
          end

          it "sets role_path" do
            file.must_include %{role_path "#{base}roles"}
          end

          it "sets client_path" do
            file.must_include %{client_path "#{base}clients"}
          end

          it "sets user_path" do
            file.must_include %{user_path "#{base}users"}
          end

          it "sets validation_key" do
            file.must_include %{validation_key "#{base}validation.pem"}
          end

          it "sets client_key" do
            file.must_include %{client_key "#{base}client.pem"}
          end

          it "sets chef_server_url" do
            file.must_include %{chef_server_url "http://127.0.0.1:8889"}
          end

          it "sets encrypted_data_bag_secret" do
            file.must_include %{encrypted_data_bag_secret } +
              %{"#{base}encrypted_data_bag_secret"}
          end
        end
        # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

        describe "for unix os types" do

          before do
            platform.stubs(:os_type).returns("unix")
            provisioner.create_sandbox
          end

          let(:base) { "/tmp/kitchen/" }

          common_solo_rb_specs
        end

        describe "for windows os types with full path" do

          before do
            platform.stubs(:os_type).returns("windows")
            config[:root_path] = "\\a\\b"
            provisioner.create_sandbox
          end

          let(:base) { "\\\\a\\\\b\\\\" }

          common_solo_rb_specs
        end

        describe "for windows os types with $env:TEMP prefixed paths" do

          before do
            platform.stubs(:os_type).returns("windows")
            config[:root_path] = "$env:TEMP\\a"
            provisioner.create_sandbox
          end

          let(:base) { "\#{ENV['TEMP']}\\\\a\\\\" }

          common_solo_rb_specs
        end
      end

      it "supports overwriting defaults" do
        config[:solo_rb] = {
          :node_name => "eagles",
          :user_path => "/a/b/c/u",
          :client_key => "lol"
        }
        provisioner.create_sandbox

        file.must_include %{node_name "eagles"}
        file.must_include %{user_path "/a/b/c/u"}
        file.must_include %{client_key "lol"}
      end

      it "supports adding new configuration" do
        config[:solo_rb] = {
          :dark_secret => "golang"
        }
        provisioner.create_sandbox

        file.must_include %{dark_secret "golang"}
      end

      it "formats array values correctly" do
        config[:solo_rb] = {
          :foos => %w[foo1 foo2]
        }
        provisioner.create_sandbox

        file.must_include %{foos ["foo1", "foo2"]}
      end

      it "formats integer values correctly" do
        config[:solo_rb] = {
          :foo => 7
        }
        provisioner.create_sandbox

        file.must_include %{foo 7}
      end

      it "formats symbol-looking string values correctly" do
        config[:solo_rb] = {
          :foo => ":bar"
        }
        provisioner.create_sandbox

        file.must_include %{foo :bar}
      end

      it "formats boolean values correctly" do
        config[:solo_rb] = {
          :foo => false,
          :bar => true
        }
        provisioner.create_sandbox

        file.must_include %{foo false}
        file.must_include %{bar true}
      end
    end

    def sandbox_path(path)
      Pathname.new(provisioner.sandbox_path).join(path)
    end
  end

  describe "#run_command" do

    let(:cmd) { provisioner.run_command }

    describe "common behavior" do

      before { platform.stubs(:shell_type).returns("fake") }

      it "prefixs the whole command with the command_prefix if set" do
        config[:command_prefix] = "my_prefix"

        cmd.must_match(/\Amy_prefix /)
      end

      it "does not prefix the command if command_prefix is not set" do
        config[:command_prefix] = nil

        cmd.wont_match(/\Amy_prefix /)
      end
    end

    describe "for bourne shells" do

      before { platform.stubs(:shell_type).returns("bourne") }

      it "uses bourne shell" do
        cmd.must_match(/\Ash -c '$/)
        cmd.must_match(/'\Z/)
      end

      it "ends with a single quote" do
        cmd.must_match(/'\Z/)
      end

      it "exports http_proxy & HTTP_PROXY when :http_proxy is set" do
        config[:http_proxy] = "http://proxy"

        cmd.lines.to_a[1..2].must_equal([
          %{http_proxy="http://proxy"; export http_proxy\n},
          %{HTTP_PROXY="http://proxy"; export HTTP_PROXY\n}
        ])
      end

      it "exports https_proxy & HTTPS_PROXY when :https_proxy is set" do
        config[:https_proxy] = "https://proxy"

        cmd.lines.to_a[1..2].must_equal([
          %{https_proxy="https://proxy"; export https_proxy\n},
          %{HTTPS_PROXY="https://proxy"; export HTTPS_PROXY\n}
        ])
      end

      it "exports all http proxy variables when both are set" do
        config[:http_proxy] = "http://proxy"
        config[:https_proxy] = "https://proxy"

        cmd.lines.to_a[1..4].must_equal([
          %{http_proxy="http://proxy"; export http_proxy\n},
          %{HTTP_PROXY="http://proxy"; export HTTP_PROXY\n},
          %{https_proxy="https://proxy"; export https_proxy\n},
          %{HTTPS_PROXY="https://proxy"; export HTTPS_PROXY\n}
        ])
      end

      it "does no powershell PATH reloading for older chef omnibus packages" do
        cmd.wont_match regexify(%{[System.Environment]::})
      end

      it "uses sudo for chef-solo when configured" do
        config[:chef_omnibus_root] = "/c"
        config[:sudo] = true

        cmd.must_match regexify("sudo -E /c/bin/chef-solo ", :partial_line)
      end

      it "does not use sudo for chef-solo when configured" do
        config[:chef_omnibus_root] = "/c"
        config[:sudo] = false

        cmd.must_match regexify("chef-solo ", :partial_line)
        cmd.wont_match regexify("sudo -E /c/bin/chef-solo ", :partial_line)
      end

      it "sets config flag on chef-solo" do
        cmd.must_match regexify(" --config /tmp/kitchen/solo.rb", :partial_line)
      end

      it "sets config flag for custom root_path" do
        config[:root_path] = "/a/b"

        cmd.must_match regexify(" --config /a/b/solo.rb", :partial_line)
      end

      it "sets json attributes flag on chef-solo" do
        cmd.must_match regexify(
          " --json-attributes /tmp/kitchen/dna.json", :partial_line)
      end

      it "sets json attribtes flag for custom root_path" do
        config[:root_path] = "/booyah"

        cmd.must_match regexify(
          " --json-attributes /booyah/dna.json", :partial_line)
      end

      it "sets log level flag on chef-solo to auto by default" do
        cmd.must_match regexify(" --log_level auto", :partial_line)
      end

      it "sets log level flag on chef-solo to info by default if running Chef < 11" do
        config[:require_chef_omnibus] = "10.34.6"
        cmd.must_match regexify(" --log_level info", :partial_line)
      end

      it "set log level flag for custom level" do
        config[:log_level] = :extreme

        cmd.must_match regexify(" --log_level extreme", :partial_line)
      end

      it "sets force formatter flag on chef-solo" do
        cmd.must_match regexify(" --force-formatter", :partial_line)
      end

      it "does not set force formatter flag on chef-solo if running Chef < 11" do
        config[:require_chef_omnibus] = "10.34.6"
        cmd.wont_match regexify(" --force-formatter", :partial_line)
      end

      it "sets no color flag on chef-solo" do
        cmd.must_match regexify(" --no-color", :partial_line)
      end

      it "does not set logfile flag by default" do
        cmd.wont_match regexify(" --logfile ", :partial_line)
      end

      it "sets logfile flag for custom value" do
        config[:log_file] = "/a/out.log"

        cmd.must_match regexify(" --logfile /a/out.log", :partial_line)
      end

      it "sets profile-ruby flag when config element is set" do
        config[:profile_ruby] = true

        cmd.must_match regexify(
          " --profile-ruby", :partial_line)
      end

      it "does not set profile-ruby flag when config element is falsey" do
        config[:profile_ruby] = false

        cmd.wont_match regexify(" --profile-ruby", :partial_line)
      end

      it "sets legacy-mode flag when config element is set" do
        config[:legacy_mode] = true

        cmd.must_match regexify(" --legacy-mode", :partial_line)
      end

      it "does not set legacy-mode flag when config element is falsey" do
        config[:legacy_mode] = false

        cmd.wont_match regexify(" --legacy-mode", :partial_line)
      end
    end

    describe "for powershell shells on windows os types" do

      before do
        platform.stubs(:shell_type).returns("powershell")
        platform.stubs(:os_type).returns("windows")
      end

      it "exports http_proxy & HTTP_PROXY when :http_proxy is set" do
        config[:http_proxy] = "http://proxy"

        cmd.lines.to_a[0..1].must_equal([
          %{$env:http_proxy = "http://proxy"\n},
          %{$env:HTTP_PROXY = "http://proxy"\n}
        ])
      end

      it "exports https_proxy & HTTPS_PROXY when :https_proxy is set" do
        config[:https_proxy] = "https://proxy"

        cmd.lines.to_a[0..1].must_equal([
          %{$env:https_proxy = "https://proxy"\n},
          %{$env:HTTPS_PROXY = "https://proxy"\n}
        ])
      end

      it "exports all http proxy variables when both are set" do
        config[:http_proxy] = "http://proxy"
        config[:https_proxy] = "https://proxy"

        cmd.lines.to_a[0..3].must_equal([
          %{$env:http_proxy = "http://proxy"\n},
          %{$env:HTTP_PROXY = "http://proxy"\n},
          %{$env:https_proxy = "https://proxy"\n},
          %{$env:HTTPS_PROXY = "https://proxy"\n}
        ])
      end

      it "reloads PATH for older chef omnibus packages" do
        cmd.must_match regexify("$env:PATH = try {\n" \
        "[System.Environment]::GetEnvironmentVariable('PATH','Machine')\n" \
        "} catch { $env:PATH }")
      end

      it "calls the chef-solo command from :chef_solo_path" do
        config[:chef_solo_path] = "\\r\\chef-solo.bat"

        cmd.must_match regexify("& \\r\\chef-solo.bat ", :partial_line)
      end

      it "sets config flag on chef-solo" do
        cmd.must_match regexify(
          " --config $env:TEMP\\kitchen\\solo.rb", :partial_line)
      end

      it "sets config flag for custom root_path" do
        config[:root_path] = "\\a\\b"

        cmd.must_match regexify(
          " --config \\a\\b\\solo.rb", :partial_line)
      end

      it "sets json attributes flag on chef-solo" do
        cmd.must_match regexify(
          " --json-attributes $env:TEMP\\kitchen\\dna.json", :partial_line)
      end

      it "sets json attribtes flag for custom root_path" do
        config[:root_path] = "\\booyah"

        cmd.must_match regexify(
          " --json-attributes \\booyah\\dna.json", :partial_line)
      end

      it "sets log level flag on chef-solo to auto by default" do
        cmd.must_match regexify(" --log_level auto", :partial_line)
      end

      it "set log level flag for custom level" do
        config[:log_level] = :extreme

        cmd.must_match regexify(" --log_level extreme", :partial_line)
      end

      it "sets force formatter flag on chef-solo" do
        cmd.must_match regexify(" --force-formatter", :partial_line)
      end

      it "sets no color flag on chef-solo" do
        cmd.must_match regexify(" --no-color", :partial_line)
      end

      it "does not set logfile flag by default" do
        cmd.wont_match regexify(" --logfile ", :partial_line)
      end

      it "sets logfile flag for custom value" do
        config[:log_file] = "\\a\\out.log"

        cmd.must_match regexify(" --logfile \\a\\out.log", :partial_line)
      end
    end
  end

  def info_line(msg)
    %r{^I, .* : #{Regexp.escape(msg)}$}
  end

  def debug_line_starting_with(msg)
    %r{^D, .* : #{Regexp.escape(msg)}}
  end

  def regexify(str, line = :whole_line)
    r = Regexp.escape(str)
    r = "^\s*#{r}$" if line == :whole_line
    Regexp.new(r)
  end
end
