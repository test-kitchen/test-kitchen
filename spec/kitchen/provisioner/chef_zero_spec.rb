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
require "kitchen/provisioner/chef_zero"

describe Kitchen::Provisioner::ChefZero do

  let(:logged_output)   { StringIO.new }
  let(:logger)          { Logger.new(logged_output) }

  let(:config) do
    { :test_base_path => "/b", :kitchen_root => "/r", :log_level => :info }
  end

  let(:suite) do
    stub(:name => "fries")
  end

  let(:instance) do
    stub(:name => "coolbeans", :logger => logger, :suite => suite)
  end

  let(:provisioner) do
    Kitchen::Provisioner::ChefZero.new(config).finalize_config!(instance)
  end

  describe "default config" do

    it "sets :client_rb to an empty Hash" do
      provisioner[:client_rb].must_equal Hash.new
    end

    it "sets :ruby_bindir to use an Omnibus Ruby" do
      provisioner[:ruby_bindir].must_equal "/opt/chef/embedded/bin"
    end

    it "sets :json_attributes to true" do
      provisioner[:json_attributes].must_equal true
    end

    it "sets :chef_zero_port to 8889" do
      provisioner[:chef_zero_port].must_equal 8889
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
        IO.read(sandbox_path("client.rb")).lines.map { |l| l.chomp }
      end

      it "creates a client.rb" do
        provisioner.create_sandbox

        sandbox_path("client.rb").file?.must_equal true
      end

      it "logs a message on info" do
        provisioner.create_sandbox

        logged_output.string.must_match info_line("Preparing client.rb")
      end

      it "logs a message on debug" do
        provisioner.create_sandbox

        logged_output.string.
          must_match debug_line_starting_with("Creating client.rb from {")
      end

      describe "defaults" do

        before { provisioner.create_sandbox }

        it "sets node_name to the instance name" do
          file.must_include %{node_name "#{instance.name}"}
        end

        it "sets checksum_path" do
          file.must_include %{checksum_path "/tmp/kitchen/checksums"}
        end

        it "sets file_backup_path" do
          file.must_include %{file_backup_path "/tmp/kitchen/backup"}
        end

        it "sets cookbook_path" do
          file.must_include %{cookbook_path } +
            %{["/tmp/kitchen/cookbooks", "/tmp/kitchen/site-cookbooks"]}
        end

        it "sets data_bag_path" do
          file.must_include %{data_bag_path "/tmp/kitchen/data_bags"}
        end

        it "sets environment_path" do
          file.must_include %{environment_path "/tmp/kitchen/environments"}
        end

        it "sets node_path" do
          file.must_include %{node_path "/tmp/kitchen/nodes"}
        end

        it "sets role_path" do
          file.must_include %{role_path "/tmp/kitchen/roles"}
        end

        it "sets client_path" do
          file.must_include %{client_path "/tmp/kitchen/clients"}
        end

        it "sets user_path" do
          file.must_include %{user_path "/tmp/kitchen/users"}
        end

        it "sets validation_key" do
          file.must_include %{validation_key "/tmp/kitchen/validation.pem"}
        end

        it "sets client_key" do
          file.must_include %{client_key "/tmp/kitchen/client.pem"}
        end

        it "sets chef_server_url" do
          file.must_include %{chef_server_url "http://127.0.0.1:8889"}
        end

        it "sets encrypted_data_bag_secret" do
          file.must_include %{encrypted_data_bag_secret } +
            %{"/tmp/kitchen/encrypted_data_bag_secret"}
        end
      end

      it "supports overwriting defaults" do
        config[:client_rb] = {
          :node_name => "eagles",
          :user_path => "/a/b/c/u",
          :client_key => "lol"
        }
        provisioner.create_sandbox

        file.must_include %{node_name "eagles"}
        file.must_include %{user_path "/a/b/c/u"}
        file.must_include %{client_key "lol"}
      end

      it " supports adding new configuration" do
        config[:client_rb] = {
          :dark_secret => "golang"
        }
        provisioner.create_sandbox

        file.must_include %{dark_secret "golang"}
      end

      it "formats array values correctly" do
        config[:client_rb] = {
          :foos => %w[foo1 foo2]
        }
        provisioner.create_sandbox

        file.must_include %{foos ["foo1", "foo2"]}
      end

      it "formats integer values correctly" do
        config[:client_rb] = {
          :foo => 7
        }
        provisioner.create_sandbox

        file.must_include %{foo 7}
      end

      it "formats symbol values correctly" do
        config[:client_rb] = {
          :foo => :bar
        }
        provisioner.create_sandbox

        file.must_include %{foo :bar}
      end

      it "formats boolean values correctly" do
        config[:client_rb] = {
          :foo => false,
          :bar => true
        }
        provisioner.create_sandbox

        file.must_include %{foo false}
        file.must_include %{bar true}
      end
    end

    describe "validation.pem file" do

      it "creates file" do
        provisioner.create_sandbox

        sandbox_path("validation.pem").file?.must_equal true
      end

      it "logs a message on info" do
        provisioner.create_sandbox

        logged_output.string.must_match info_line("Preparing validation.pem")
      end

      it "logs a message on debug" do
        provisioner.create_sandbox

        logged_output.string.
          must_match debug_line_starting_with("Using a dummy validation.pem")
      end
    end

    describe "chef-client-zero.rb file" do

      describe "for modern Chef versions" do

        before { config[:require_chef_omnibus] = "11.10" }

        it "does not create the file" do
          provisioner.create_sandbox

          sandbox_path("chef-client-zero.rb").file?.must_equal false
        end
      end

      describe "for old Chef versions" do

        before { config[:require_chef_omnibus] = "10.20" }

        it "creates the file when using an old Chef version" do
          provisioner.create_sandbox

          sandbox_path("chef-client-zero.rb").file?.must_equal true
        end

        it "logs a message on info" do
          provisioner.create_sandbox

          logged_output.string.
            must_match info_line("Preparing chef-client-zero.rb")
        end

        it "logs a message on debug" do
          provisioner.create_sandbox

          logged_output.string.must_match debug_line_starting_with(
            "Using a vendored chef-client-zero.rb")
        end
      end
    end

    def sandbox_path(path)
      Pathname.new(provisioner.sandbox_path).join(path)
    end
  end

  describe "#prepare_command" do

    let(:cmd) { provisioner.prepare_command }

    describe "for modern Chef versions" do

      before { config[:require_chef_omnibus] = "11.10" }

      it "returns nil" do
        cmd.must_equal nil
      end
    end

    describe "for old Chef versions" do

      before do
        config[:require_chef_omnibus] = "10.20"
        config[:ruby_bindir] = "/rbd"
      end

      it "uses bourne shell" do
        cmd.must_match(/\Ash -c '$/)
        cmd.must_match(/'\Z/)
      end

      it "sets the CHEF_REPO_PATH environment variable" do
        config[:root_path] = "/r"

        cmd.must_match regexify(%{CHEF_REPO_PATH="/r" }, :partial_line)
      end

      it "sets the GEM_HOME environment variable" do
        config[:root_path] = "/r"

        cmd.must_match regexify(
          %{GEM_HOME="/r/chef-client-zero-gems" }, :partial_line)
      end

      it "sets the GEM_PATH environment variable" do
        config[:root_path] = "/r"

        cmd.must_match regexify(
          %{GEM_PATH="/r/chef-client-zero-gems" }, :partial_line)
      end

      it "sets the GEM_CACHE environment variable" do
        config[:root_path] = "/r"

        cmd.must_match regexify(
          %{GEM_CACHE="/r/chef-client-zero-gems/cache" }, :partial_line)
      end

      it "exports all the environment variables" do
        cmd.must_match regexify(
          "export CHEF_REPO_PATH GEM_HOME GEM_PATH GEM_CACHE;", :partial_line)
      end

      it "checks if chef-zero is installed" do
        cmd.must_match regexify(
          %{if ! sudo -E /rbd/gem list chef-zero -i >/dev/null; then})
      end

      it "installs the chef gem" do
        cmd.must_match regexify(
          %{sudo -E /rbd/gem install chef --no-ri --no-rdoc --conservative})
      end
    end
  end

  describe "#run_command" do

    let(:cmd) { provisioner.run_command }

    describe "for modern Chef versions" do

      before { config[:require_chef_omnibus] = "11.10" }

      it "uses bourne shell" do
        cmd.must_match(/\Ash -c '$/)
        cmd.must_match(/'\Z/)
      end

      it "uses sudo for chef-client when configured" do
        config[:sudo] = true

        cmd.must_match regexify("sudo -E chef-client ", :partial_line)
      end

      it "does not use sudo for chef-client when configured" do
        config[:sudo] = false

        cmd.must_match regexify("chef-client ", :partial_line)
        cmd.wont_match regexify("sudo -E chef-client ", :partial_line)
      end

      it "sets local mode flag on chef-client" do
        cmd.must_match regexify(" --local-mode", :partial_line)
      end

      it "sets config flag on chef-client" do
        cmd.must_match regexify(
          " --config /tmp/kitchen/client.rb", :partial_line)
      end

      it "sets config flag for custom root_path" do
        config[:root_path] = "/a/b"

        cmd.must_match regexify(" --config /a/b/client.rb", :partial_line)
      end

      it "sets log level flag on chef-client to auto by default" do
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

      it "sets chef zero port flag on chef-client" do
        cmd.must_match regexify(" --chef-zero-port 8889", :partial_line)
      end

      it "sets chef zero port flag for custom port" do
        config[:chef_zero_port] = 123

        cmd.must_match regexify(" --chef-zero-port 123", :partial_line)
      end

      it "does not set chef zero port flag when value is falsey" do
        config[:chef_zero_port] = nil

        cmd.wont_match regexify(" --chef-zero-port ", :partial_line)
      end

      it "sets json attributes flag on chef-client" do
        cmd.must_match regexify(
          " --json-attributes /tmp/kitchen/dna.json", :partial_line)
      end

      it "sets json attribtes flag for custom root_path" do
        config[:root_path] = "/booyah"

        cmd.must_match regexify(
          " --json-attributes /booyah/dna.json", :partial_line)
      end

      it "does not set json attributes flag if config is falsey" do
        config[:json_attributes] = false

        cmd.wont_match regexify(" --json-attributes ", :partial_line)
      end

      it "does not set logfile flag by default" do
        cmd.wont_match regexify(" --logfile ", :partial_line)
      end

      it "sets logfile flag for custom value" do
        config[:log_file] = "/a/out.log"

        cmd.must_match regexify(" --logfile /a/out.log", :partial_line)
      end
    end

    describe "for old Chef versions" do

      before do
        config[:require_chef_omnibus] = "10.20"
        config[:ruby_bindir] = "/r/bin"
      end

      it "uses bourne shell" do
        cmd.must_match(/\Ash -c '$/)
        cmd.must_match(/'\Z/)
      end

      it "uses sudo for ruby when configured" do
        config[:root_path] = "/x"
        config[:sudo] = true

        cmd.must_match regexify(
          "sudo -E /r/bin/ruby /x/chef-client-zero.rb ", :partial_line)
      end

      it "does not use sudo for ruby when configured" do
        config[:root_path] = "/x"
        config[:sudo] = false

        cmd.must_match regexify(
          "/r/bin/ruby /x/chef-client-zero.rb ", :partial_line)
        cmd.wont_match regexify(
          "sudo -E /r/bin/ruby /x/chef-client-zero.rb ", :partial_line)
      end

      it "does not set local mode flag" do
        cmd.wont_match regexify(" --local-mode", :partial_line)
      end

      it "sets config flag on chef-client" do
        cmd.must_match regexify(
          " --config /tmp/kitchen/client.rb", :partial_line)
      end

      it "sets config flag for custom root_path" do
        config[:root_path] = "/a/b"

        cmd.must_match regexify(" --config /a/b/client.rb", :partial_line)
      end

      it "sets log level flag on chef-client to auto by default" do
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

      it "sets json attributes flag on chef-client" do
        cmd.must_match regexify(
          " --json-attributes /tmp/kitchen/dna.json", :partial_line)
      end

      it "sets json attribtes flag for custom root_path" do
        config[:root_path] = "/booyah"

        cmd.must_match regexify(
          " --json-attributes /booyah/dna.json", :partial_line)
      end

      it "does not set json attributes flag if config is falsey" do
        config[:json_attributes] = false

        cmd.wont_match regexify(" --json-attributes ", :partial_line)
      end

      it "does not set logfile flag by default" do
        cmd.wont_match regexify(" --logfile ", :partial_line)
      end

      it "sets logfile flag for custom value" do
        config[:log_file] = "/a/out.log"

        cmd.must_match regexify(" --logfile /a/out.log", :partial_line)
      end

      it "sets the CHEF_REPO_PATH environment variable" do
        config[:root_path] = "/r"

        cmd.must_match regexify(%{CHEF_REPO_PATH="/r" }, :partial_line)
      end

      it "sets the GEM_HOME environment variable" do
        config[:root_path] = "/r"

        cmd.must_match regexify(
          %{GEM_HOME="/r/chef-client-zero-gems" }, :partial_line)
      end

      it "sets the GEM_PATH environment variable" do
        config[:root_path] = "/r"

        cmd.must_match regexify(
          %{GEM_PATH="/r/chef-client-zero-gems" }, :partial_line)
      end

      it "sets the GEM_CACHE environment variable" do
        config[:root_path] = "/r"

        cmd.must_match regexify(
          %{GEM_CACHE="/r/chef-client-zero-gems/cache" }, :partial_line)
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
