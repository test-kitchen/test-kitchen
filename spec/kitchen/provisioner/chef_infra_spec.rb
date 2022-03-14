#
# Author:: Fletcher Nichol (<fnichol@nichol.ca>)
#
# Copyright (C) 2014, Fletcher Nichol
# Copyright (C) Chef Software Inc.
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
require "kitchen/provisioner/chef_infra"

describe Kitchen::Provisioner::ChefInfra do
  let(:logged_output)   { StringIO.new }
  let(:logger)          { Logger.new(logged_output) }
  let(:platform)        { stub(os_type: nil) }
  let(:suite)           { stub(name: "fries") }

  let(:config) do
    { test_base_path: "/b", kitchen_root: "/r" }
  end

  let(:instance) do
    stub(
      name: "coolbeans",
      logger: logger,
      suite: suite,
      platform: platform
    )
  end

  let(:provisioner) do
    Kitchen::Provisioner::ChefInfra.new(config).finalize_config!(instance)
  end

  it "provisioner api_version is 2" do
    _(provisioner.diagnose_plugin[:api_version]).must_equal 2
  end

  it "plugin_version is set to Kitchen::VERSION" do
    _(provisioner.diagnose_plugin[:version]).must_equal Kitchen::VERSION
  end

  describe "default config" do
    describe "for unix operating systems" do
      before { platform.stubs(:os_type).returns("unix") }

      it "sets :chef_client_path to a path using :chef_omnibus_root" do
        config[:chef_omnibus_root] = "/nice/place"

        _(provisioner[:chef_client_path]).must_equal "/nice/place/bin/chef-client"
      end

      it "sets :ruby_bindir to use an Omnibus Ruby" do
        config[:chef_omnibus_root] = "/nice"

        _(provisioner[:ruby_bindir]).must_equal "/nice/embedded/bin"
      end
    end

    describe "for windows operating systems" do
      before { platform.stubs(:os_type).returns("windows") }

      it "sets :chef_client_path to a path using :chef_omnibus_root" do
        config[:chef_omnibus_root] = '$env:systemdrive\\nice\\place'

        _(provisioner[:chef_client_path]).must_equal '$env:systemdrive\\nice\\place\\bin\\chef-client.bat'
      end

      it "sets :ruby_bindir to use an Omnibus Ruby" do
        config[:chef_omnibus_root] = 'c:\\nice'

        _(provisioner[:ruby_bindir]).must_equal 'c:\\nice\\embedded\\bin'
      end
    end

    it "sets :client_rb to an empty Hash" do
      _(provisioner[:client_rb]).must_equal({})
    end

    it "sets :json_attributes to true" do
      _(provisioner[:json_attributes]).must_equal true
    end

    it "does not set :chef_zero_host" do
      _(provisioner[:chef_zero_host]).must_be_nil
    end

    it "sets :chef_zero_port to 8889" do
      _(provisioner[:chef_zero_port]).must_equal 8889
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

    describe "client.rb file" do
      let(:file) do
        IO.read(sandbox_path("client.rb")).lines.map(&:chomp)
      end

      let(:file_no_updated_resources) do
        IO.read(sandbox_path("client_no_updated_resources.rb")).lines.map(&:chomp)
      end

      it "creates a client.rb" do
        provisioner.create_sandbox

        _(sandbox_path("client.rb").file?).must_equal true
      end

      it "logs a message on info" do
        provisioner.create_sandbox

        _(logged_output.string).must_match info_line("Preparing client.rb")
      end

      it "logs a message on debug" do
        provisioner.create_sandbox

        _(logged_output.string).must_match debug_line_starting_with("Creating client.rb from {")
      end

      describe "defaults" do
        # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
        def self.common_client_rb_specs
          it "sets node_name to the instance name" do
            _(file).must_include %{node_name "#{instance.name}"}
          end

          it "sets checksum_path" do
            _(file).must_include %{checksum_path "#{base}checksums"}
          end

          it "sets file_backup_path" do
            _(file).must_include %{file_backup_path "#{base}backup"}
          end

          it "sets cookbook_path" do
            _(file).must_include %{cookbook_path } +
              %{["#{base}cookbooks", "#{base}site-cookbooks"]}
          end

          it "sets data_bag_path" do
            _(file).must_include %{data_bag_path "#{base}data_bags"}
          end

          it "sets environment_path" do
            _(file).must_include %{environment_path "#{base}environments"}
          end

          it "sets node_path" do
            _(file).must_include %{node_path "#{base}nodes"}
          end

          it "sets role_path" do
            _(file).must_include %{role_path "#{base}roles"}
          end

          it "sets client_path" do
            _(file).must_include %{client_path "#{base}clients"}
          end

          it "sets user_path" do
            _(file).must_include %{user_path "#{base}users"}
          end

          it "sets validation_key" do
            _(file).must_include %{validation_key "#{base}validation.pem"}
          end

          it "sets client_key" do
            _(file).must_include %{client_key "#{base}client.pem"}
          end

          it "sets chef_server_url" do
            _(file).must_include %{chef_server_url "http://127.0.0.1:8889"}
          end

          it "sets encrypted_data_bag_secret" do
            _(file).must_include %{encrypted_data_bag_secret } +
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

          common_client_rb_specs
        end

        describe "for windows os types with full path" do
          before do
            platform.stubs(:os_type).returns("windows")
            config[:root_path] = '\\a\\b'
            provisioner.create_sandbox
          end

          let(:base) { '\\\\a\\\\b\\\\' }

          common_client_rb_specs
        end

        describe "for windows os types with $env:TEMP prefixed paths" do
          before do
            platform.stubs(:os_type).returns("windows")
            config[:root_path] = '$env:TEMP\\a'
            provisioner.create_sandbox
          end

          let(:base) { "\#{ENV['TEMP']}\\\\a\\\\" }

          common_client_rb_specs
        end
      end

      it "supports overwriting defaults" do
        config[:client_rb] = {
          node_name: "eagles",
          user_path: "/a/b/c/u",
          client_key: "lol",
        }
        provisioner.create_sandbox

        _(file).must_include %{node_name "eagles"}
        _(file).must_include %{user_path "/a/b/c/u"}
        _(file).must_include %{client_key "lol"}
      end

      it " supports adding new configuration" do
        config[:client_rb] = {
          dark_secret: "golang",
        }
        provisioner.create_sandbox

        _(file).must_include %{dark_secret "golang"}
      end

      it "formats array values correctly" do
        config[:client_rb] = {
          foos: %w{foo1 foo2},
        }
        provisioner.create_sandbox

        _(file).must_include %{foos ["foo1", "foo2"]}
      end

      it "formats integer values correctly" do
        config[:client_rb] = {
          foo: 7,
        }
        provisioner.create_sandbox

        _(file).must_include %{foo 7}
      end

      it "formats symbol-looking string values correctly" do
        config[:client_rb] = {
          foo: ":bar",
        }
        provisioner.create_sandbox

        _(file).must_include %{foo :bar}
      end

      it "formats boolean values correctly" do
        config[:client_rb] = {
          foo: false,
          bar: true,
        }
        provisioner.create_sandbox

        _(file).must_include %{foo false}
        _(file).must_include %{bar true}
      end

      it "supports idempotency check " do
        config[:multiple_converge] = 2
        config[:enforce_idempotency] = true
        provisioner.create_sandbox

        _(file_no_updated_resources.join).must_match(/handler_file =.*chef-client-fail-if-update-handler.rb/)
      end
    end

    describe "validation.pem file" do
      it "creates file" do
        provisioner.create_sandbox

        _(sandbox_path("validation.pem").file?).must_equal true
      end

      it "logs a message on info" do
        provisioner.create_sandbox

        _(logged_output.string).must_match info_line("Preparing validation.pem")
      end

      it "logs a message on debug" do
        provisioner.create_sandbox

        _(logged_output.string).must_match debug_line_starting_with("Using a dummy validation.pem")
      end
    end

    def sandbox_path(path)
      Pathname.new(provisioner.sandbox_path).join(path)
    end
  end

  describe "#run_command" do
    let(:cmd) { provisioner.run_command }

    # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    def self.common_shell_specs
      it "sets config flag on chef-client" do
        _(cmd).must_match regexify(
          " --config #{base}client.rb", :partial_line
        )
      end

      it "sets config flag for custom root_path" do
        config[:root_path] = custom_root

        _(cmd).must_match regexify(
          " --config #{custom_base}client.rb", :partial_line
        )
      end

      it "sets log level flag on chef-client to auto by default" do
        _(cmd).must_match regexify(" --log_level auto", :partial_line)
      end

      it "set log level flag for custom level" do
        config[:log_level] = :extreme

        _(cmd).must_match regexify(" --log_level extreme", :partial_line)
      end

      it "sets force formatter flag on chef-solo" do
        _(cmd).must_match regexify(" --force-formatter", :partial_line)
      end

      it "sets no color flag on chef-solo" do
        _(cmd).must_match regexify(" --no-color", :partial_line)
      end

      it "sets json attributes flag on chef-client" do
        _(cmd).must_match regexify(
          " --json-attributes #{base}dna.json", :partial_line
        )
      end

      it "sets json attribtes flag for custom root_path" do
        config[:root_path] = custom_root

        _(cmd).must_match regexify(
          " --json-attributes #{custom_base}dna.json", :partial_line
        )
      end

      it "does not set json attributes flag if config is falsey" do
        config[:json_attributes] = false

        _(cmd).wont_match regexify(" --json-attributes ", :partial_line)
      end

      it "sets logfile flag for custom value" do
        config[:log_file] = "#{custom_base}out.log"

        _(cmd).must_match regexify(
          " --logfile #{custom_base}out.log", :partial_line
        )
      end

      it "does not set logfile flag by default" do
        _(cmd).wont_match regexify(" --logfile ", :partial_line)
      end

      it "prefixs the whole command with the command_prefix if set" do
        config[:command_prefix] = "my_prefix"

        _(cmd).must_match(/\Amy_prefix /)
      end

      it "does not prefix the command if command_prefix is not set" do
        config[:command_prefix] = nil

        _(cmd).wont_match(/\Amy_prefix /)
      end
    end
    # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

    describe "for modern Chef versions" do
      before { config[:require_chef_omnibus] = "11.10" }

      # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      def self.common_modern_shell_specs
        it "sets local mode flag on chef-client" do
          _(cmd).must_match regexify(" --local-mode", :partial_line)
        end

        it "sets chef zero port flag on chef-client" do
          _(cmd).must_match regexify(" --chef-zero-port 8889", :partial_line)
        end

        it "sets chef zero host flag for custom host" do
          config[:chef_zero_host] = "192.168.0.1"

          _(cmd).must_match regexify(" --chef-zero-host 192.168.0.1", :partial_line)
        end

        it "sets chef zero port flag for custom port" do
          config[:chef_zero_port] = 123

          _(cmd).must_match regexify(" --chef-zero-port 123", :partial_line)
        end

        it "does not set chef zero host flag when value is falsey" do
          config[:chef_zero_host] = nil

          _(cmd).wont_match regexify(" --chef-zero-host ", :partial_line)
        end

        it "does not set chef zero port flag when value is falsey" do
          config[:chef_zero_port] = nil

          _(cmd).wont_match regexify(" --chef-zero-port ", :partial_line)
        end

        it "sets profile-ruby flag when config element is set" do
          config[:profile_ruby] = true

          _(cmd).must_match regexify(
            " --profile-ruby", :partial_line
          )
        end

        it "does not set profile-ruby flag when config element is falsey" do
          config[:profile_ruby] = false

          _(cmd).wont_match regexify(" --profile-ruby", :partial_line)
        end

        it "sets slow_resource_report flag when config element is set" do
          config[:slow_resource_report] = true

          _(cmd).must_match regexify(
            " --slow-report", :partial_line
          )
        end

        it "sets slow_resource_report flag when config element is set with an integer value" do
          config[:slow_resource_report] = 1

          _(cmd).must_match regexify(
            " --slow-report 1", :partial_line
          )
        end
      end
      # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

      describe "for bourne shells" do
        before { platform.stubs(:shell_type).returns("bourne") }

        let(:base) { "/tmp/kitchen/" }
        let(:custom_base) { "/a/b/" }
        let(:custom_root) { "/a/b" }

        common_shell_specs
        common_modern_shell_specs

        it "uses bourne shell" do
          _(cmd).must_match(/\Ash -c '$/)
          _(cmd).must_match(/'\Z/)
        end

        it "ends with a single quote" do
          _(cmd).must_match(/'\Z/)
        end

        it "contains a standard second run if multiple_converge is set to 2" do
          config[:multiple_converge] = 2
          _(cmd).must_match(/chef-client.*&&.*chef-client.*/m)
          _(cmd).wont_match(/chef-client.*&&.*chef-client.*client_no_updated_resources.rb/m)
        end

        it "contains a specific second run if enforce_idempotency is set" do
          config[:multiple_converge] = 2
          config[:enforce_idempotency] = true
          _(cmd).must_match(/chef-client.*&&.*chef-client.*client_no_updated_resources.rb/m)
        end

        it "exports http_proxy & HTTP_PROXY when :http_proxy is set" do
          config[:http_proxy] = "http://proxy"

          _(cmd.lines.to_a[1..2]).must_equal([
                                            %{http_proxy="http://proxy"; export http_proxy\n},
                                            %{HTTP_PROXY="http://proxy"; export HTTP_PROXY\n},
                                          ])
        end

        it "exports https_proxy & HTTPS_PROXY when :https_proxy is set" do
          config[:https_proxy] = "https://proxy"

          _(cmd.lines.to_a[1..2]).must_equal([
                                            %{https_proxy="https://proxy"; export https_proxy\n},
                                            %{HTTPS_PROXY="https://proxy"; export HTTPS_PROXY\n},
                                          ])
        end

        it "exports all http proxy variables when both are set" do
          config[:http_proxy] = "http://proxy"
          config[:https_proxy] = "https://proxy"

          _(cmd.lines.to_a[1..4]).must_equal([
                                            %{http_proxy="http://proxy"; export http_proxy\n},
                                            %{HTTP_PROXY="http://proxy"; export HTTP_PROXY\n},
                                            %{https_proxy="https://proxy"; export https_proxy\n},
                                            %{HTTPS_PROXY="https://proxy"; export HTTPS_PROXY\n},
                                          ])
        end

        it "does no powershell PATH reloading for older chef packages" do
          _(cmd).wont_match regexify(%{[System.Environment]::})
        end

        it "uses sudo for chef-client when configured" do
          config[:chef_omnibus_root] = "/c"
          config[:sudo] = true

          _(cmd).must_match regexify("sudo -E /c/bin/chef-client ", :partial_line)
        end

        it "does not use sudo for chef-client when configured" do
          config[:chef_omnibus_root] = "/c"
          config[:sudo] = false

          _(cmd).must_match regexify("/c/bin/chef-client ", :partial_line)
          _(cmd).wont_match regexify("sudo -E /c/bin/chef-client ", :partial_line)
        end
      end

      describe "for powershell shells on windows os types" do
        before do
          platform.stubs(:shell_type).returns("powershell")
          platform.stubs(:os_type).returns("windows")
        end

        let(:base) { '$env:TEMP\\kitchen\\' }
        let(:custom_base) { '\\a\\b\\' }
        let(:custom_root) { '\\a\\b' }

        common_shell_specs
        common_modern_shell_specs

        it "contains a standard second run if multiple_converge is set to 2" do
          config[:multiple_converge] = 2
          _(cmd).must_match(/chef-client.*;.*chef-client.*/m)
          _(cmd).wont_match(/chef-client.*;.*chef-client.*client_no_updated_resources.rb/m)
        end

        it "contains a specific second run if enforce_idempotency is set" do
          config[:multiple_converge] = 2
          config[:enforce_idempotency] = true
          _(cmd).must_match(/chef-client.*;.*chef-client.*client_no_updated_resources.rb/m)
        end

        it "exports http_proxy & HTTP_PROXY when :http_proxy is set" do
          config[:http_proxy] = "http://proxy"

          _(cmd.lines.to_a[0..1]).must_equal([
                                            %{$env:http_proxy = "http://proxy"\n},
                                            %{$env:HTTP_PROXY = "http://proxy"\n},
                                          ])
        end

        it "exports https_proxy & HTTPS_PROXY when :https_proxy is set" do
          config[:https_proxy] = "https://proxy"

          _(cmd.lines.to_a[0..1]).must_equal([
                                            %{$env:https_proxy = "https://proxy"\n},
                                            %{$env:HTTPS_PROXY = "https://proxy"\n},
                                          ])
        end

        it "exports all http proxy variables when both are set" do
          config[:http_proxy] = "http://proxy"
          config[:https_proxy] = "https://proxy"

          _(cmd.lines.to_a[0..3]).must_equal([
                                            %{$env:http_proxy = "http://proxy"\n},
                                            %{$env:HTTP_PROXY = "http://proxy"\n},
                                            %{$env:https_proxy = "https://proxy"\n},
                                            %{$env:HTTPS_PROXY = "https://proxy"\n},
                                          ])
        end

        it "reloads PATH for older chef packages" do
          _(cmd).must_match regexify("$env:PATH = try {\n" \
          "[System.Environment]::GetEnvironmentVariable('PATH','Machine')\n" \
          "} catch { $env:PATH }")
        end

        it "calls the chef-client command from :chef_client_path" do
          config[:chef_client_path] = '\\r\\chef-client.bat'

          _(cmd).must_match regexify('& \\r\\chef-client.bat ', :partial_line)
        end
      end
    end
  end

  def info_line(msg)
    /^I, .* : #{Regexp.escape(msg)}$/
  end

  def debug_line_starting_with(msg)
    /^D, .* : #{Regexp.escape(msg)}/
  end

  def regexify(str, line = :whole_line)
    r = Regexp.escape(str)
    r = "^\s*#{r}$" if line == :whole_line
    Regexp.new(r)
  end
end
