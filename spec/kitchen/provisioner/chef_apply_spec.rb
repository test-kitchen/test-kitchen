# -*- encoding: utf-8 -*-
#
# Author:: SAWANOBORI Yukihiko <sawanoboriyu@higanworks.com>)
#
# Copyright (C) 2015, HiganWorks LLC
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
require "kitchen/provisioner/chef_apply"

describe Kitchen::Provisioner::ChefApply do

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
    Kitchen::Provisioner::ChefApply.new(config).finalize_config!(instance)
  end

  it "provisioner api_version is 2" do
    provisioner.diagnose_plugin[:api_version].must_equal 2
  end

  it "plugin_version is set to Kitchen::VERSION" do
    provisioner.diagnose_plugin[:version].must_equal Kitchen::VERSION
  end

  describe "default config" do

    it "sets :chef_apply_path to a path using :chef_omnibus_root" do
      config[:chef_omnibus_root] = "/nice/place"

      provisioner[:chef_apply_path].must_equal "/nice/place/bin/chef-apply"
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
  end

  describe "#run_command" do

    before do
      config[:run_list] = %w[appry_recipe1 appry_recipe2]
    end

    let(:cmd) { provisioner.run_command }

    describe "for bourne shells" do

      before { platform.stubs(:shell_type).returns("bourne") }

      it "uses bourne shell" do
        cmd.must_match(/\Ash -c '$/)
        cmd.must_match(/'\Z/)
      end

      it "uses sudo for chef-apply when configured" do
        config[:chef_omnibus_root] = "/c"
        config[:sudo] = true

        cmd.must_match regexify("sudo -E /c/bin/chef-apply apply/appry_recipe1.rb ", :partial_line)
        cmd.must_match regexify("sudo -E /c/bin/chef-apply apply/appry_recipe2.rb ", :partial_line)
      end

      it "does not use sudo for chef-apply when configured" do
        config[:chef_omnibus_root] = "/c"
        config[:sudo] = false

        cmd.must_match regexify("chef-apply apply/appry_recipe1.rb ", :partial_line)
        cmd.must_match regexify("chef-apply apply/appry_recipe2.rb ", :partial_line)
        cmd.wont_match regexify("sudo -E /c/bin/chef-apply ")
      end

      it "sets log level flag on chef-apply to auto by default" do
        cmd.must_match regexify(" --log_level auto", :partial_line)
      end

      it "set log level flag for custom level" do
        config[:log_level] = :extreme

        cmd.must_match regexify(" --log_level extreme", :partial_line)
      end

      it "sets no color flag on chef-apply" do
        cmd.must_match regexify(" --no-color", :partial_line)
      end
    end
  end

  def regexify(str, line = :whole_line)
    r = Regexp.escape(str)
    r = "^\s*#{r}$" if line == :whole_line
    Regexp.new(r)
  end
end
