#
# Author:: Noah Kantrowitz
#
# Copyright (C) 2016, Noah Kantrowitz
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

require_relative "../../../spec_helper"
require "kitchen/provisioner/chef/policyfile"

describe Kitchen::Provisioner::Chef::Policyfile do
  let(:policyfile) { "" }
  let(:path) { "" }
  let(:license) { "" }
  let(:null_logger) do
    stub(fatal: nil, error: nil, warn: nil, info: nil,
         debug: nil, banner: nil)
  end
  let(:described_object) do
    Kitchen::Provisioner::Chef::Policyfile.new(policyfile, path, license: license, logger: null_logger)
  end
  let(:os) { "" }
  before do
    @original_rbconfig = RbConfig::CONFIG
    verbose = $VERBOSE
    $VERBOSE = nil
    RbConfig.const_set(:CONFIG, "host_os" => os)
    $VERBOSE = verbose
  end
  after do
    verbose = $VERBOSE
    $VERBOSE = nil
    RbConfig.const_set(:CONFIG, @original_rbconfig)
    $VERBOSE = verbose
  end

  # rubocop:disable Layout/LineLength
  describe "#resolve" do
    subject { described_object.resolve }

    describe "on Unix with chef" do
      before do
        described_object.expects(:which).with("chef-cli").returns(false)
        described_object.expects(:which).with("chef").returns("chef")
      end

      let(:os) { "linux-gnu" }

      describe "with simple paths" do
        let(:policyfile) { "/home/user/cookbook/Policyfile.rb" }
        let(:path) { "/tmp/kitchen/cookbooks" }
        let(:license) { "accept" }
        it do
          described_object.expects(:run_command).with("chef export /home/user/cookbook/Policyfile.rb /tmp/kitchen/cookbooks --force --chef-license accept")
          subject
        end
      end

      describe "with Jenkins-y paths" do
        let(:policyfile) { "/home/jenkins/My Chef Cookbook/workspace/current/Policyfile.rb" }
        let(:path) { "/tmp/kitchen/cookbooks" }
        let(:license) { "accept-silent" }
        it do
          described_object.expects(:run_command).with("chef export /home/jenkins/My\\ Chef\\ Cookbook/workspace/current/Policyfile.rb /tmp/kitchen/cookbooks --force --chef-license accept-silent")
          subject
        end
      end

      describe "with simple paths given accept-no-persist " do
        let(:policyfile) { "/home/user/cookbook/Policyfile.rb" }
        let(:path) { "/tmp/kitchen/cookbooks" }
        let(:license) { "accept-no-persist" }
        it do
          described_object.expects(:run_command).with("chef export /home/user/cookbook/Policyfile.rb /tmp/kitchen/cookbooks --force --chef-license accept-no-persist")
          subject
        end
      end

      describe "with simple paths and product_name is not chef " do
        let(:policyfile) { "/home/user/cookbook/Policyfile.rb" }
        let(:path) { "/tmp/kitchen/cookbooks" }
        let(:license) { nil }
        it do
          described_object.expects(:run_command).with("chef export /home/user/cookbook/Policyfile.rb /tmp/kitchen/cookbooks --force ")
          subject
        end
      end
    end

    describe "on Unix with chef-cli" do
      before do
        described_object.expects(:which).with("chef-cli").returns("chef-cli")
      end

      let(:os) { "linux-gnu" }

      describe "with simple paths" do
        let(:policyfile) { "/home/user/cookbook/Policyfile.rb" }
        let(:path) { "/tmp/kitchen/cookbooks" }
        let(:license) { "accept" }
        it do
          described_object.expects(:run_command).with("chef-cli export /home/user/cookbook/Policyfile.rb /tmp/kitchen/cookbooks --force --chef-license accept")
          subject
        end
      end

      describe "with Jenkins-y paths" do
        let(:policyfile) { "/home/jenkins/My Chef Cookbook/workspace/current/Policyfile.rb" }
        let(:path) { "/tmp/kitchen/cookbooks" }
        let(:license) { "accept-silent" }
        it do
          described_object.expects(:run_command).with("chef-cli export /home/jenkins/My\\ Chef\\ Cookbook/workspace/current/Policyfile.rb /tmp/kitchen/cookbooks --force --chef-license accept-silent")
          subject
        end
      end

      describe "with Jenkins-y paths" do
        let(:policyfile) { "/home/jenkins/My Chef Cookbook/workspace/current/Policyfile.rb" }
        let(:path) { "/tmp/kitchen/cookbooks" }
        let(:license) { "accept-no-persist" }
        it do
          described_object.expects(:run_command).with("chef-cli export /home/jenkins/My\\ Chef\\ Cookbook/workspace/current/Policyfile.rb /tmp/kitchen/cookbooks --force --chef-license accept-no-persist")
          subject
        end
      end
    end

    describe "on Windows with chef" do
      before do
        described_object.expects(:which).with("chef-cli").returns(false)
        described_object.expects(:which).with("chef").returns("chef")
      end

      let(:os) { "mswin" }

      describe "with simple paths" do
        let(:policyfile) { 'C:\\cookbook\\Policyfile.rb' }
        let(:path) { 'C:\\Temp\\kitchen\\cookbooks' }
        let(:license) { "accept" }
        it do
          described_object.expects(:run_command).with('chef export C:\\cookbook\\Policyfile.rb C:\\Temp\\kitchen\\cookbooks --force --chef-license accept')
          subject
        end
      end

      describe "with Jenkins-y paths" do
        let(:policyfile) { 'C:\\Program Files\\Jenkins\\My Chef Cookbook\\workspace\\current\\Policyfile.rb' }
        let(:path) { 'C:\\Temp\\kitchen\\cookbooks' }
        let(:license) { "accept-silent" }
        it do
          described_object.expects(:run_command).with('chef export "C:\\\\Program\\ Files\\\\Jenkins\\\\My\\ Chef\\ Cookbook\\\\workspace\\\\current\\\\Policyfile.rb" C:\\Temp\\kitchen\\cookbooks --force --chef-license accept-silent')
          subject
        end
      end

      describe "with Jenkins-y paths" do
        let(:policyfile) { 'C:\\Program Files\\Jenkins\\My Chef Cookbook\\workspace\\current\\Policyfile.rb' }
        let(:path) { 'C:\\Temp\\kitchen\\cookbooks' }
        let(:license) { "accept-no-persist" }
        it do
          described_object.expects(:run_command).with('chef export "C:\\\\Program\\ Files\\\\Jenkins\\\\My\\ Chef\\ Cookbook\\\\workspace\\\\current\\\\Policyfile.rb" C:\\Temp\\kitchen\\cookbooks --force --chef-license accept-no-persist')
          subject
        end
      end
    end

    describe "on Windows with chef-cli" do
      before do
        described_object.expects(:which).with("chef-cli").returns("chef-cli")
      end

      let(:os) { "mswin" }

      describe "with simple paths" do
        let(:policyfile) { 'C:\\cookbook\\Policyfile.rb' }
        let(:path) { 'C:\\Temp\\kitchen\\cookbooks' }
        let(:license) { "accept" }
        it do
          described_object.expects(:run_command).with('chef-cli export C:\\cookbook\\Policyfile.rb C:\\Temp\\kitchen\\cookbooks --force --chef-license accept')
          subject
        end
      end

      describe "with Jenkins-y paths" do
        let(:policyfile) { 'C:\\Program Files\\Jenkins\\My Chef Cookbook\\workspace\\current\\Policyfile.rb' }
        let(:path) { 'C:\\Temp\\kitchen\\cookbooks' }
        let(:license) { "accept-silent" }
        it do
          described_object.expects(:run_command).with('chef-cli export "C:\\\\Program\\ Files\\\\Jenkins\\\\My\\ Chef\\ Cookbook\\\\workspace\\\\current\\\\Policyfile.rb" C:\\Temp\\kitchen\\cookbooks --force --chef-license accept-silent')
          subject
        end
      end

      describe "with Jenkins-y paths" do
        let(:policyfile) { 'C:\\Program Files\\Jenkins\\My Chef Cookbook\\workspace\\current\\Policyfile.rb' }
        let(:path) { 'C:\\Temp\\kitchen\\cookbooks' }
        let(:license) { "accept-no-persist" }
        it do
          described_object.expects(:run_command).with('chef-cli export "C:\\\\Program\\ Files\\\\Jenkins\\\\My\\ Chef\\ Cookbook\\\\workspace\\\\current\\\\Policyfile.rb" C:\\Temp\\kitchen\\cookbooks --force --chef-license accept-no-persist')
          subject
        end
      end
    end

    describe "failure to resolve paths" do
      before do
        described_object.expects(:which).with("chef-cli").returns(false)
        described_object.expects(:which).with("chef").returns(false)
      end

      let(:os) { "linux-gnu" }

      let(:policyfile) { "/home/user/cookbook/Policyfile.rb" }
      let(:path) { "/tmp/kitchen/cookbooks" }
      it do
        null_logger.expects(:fatal)
        _ { subject }.must_raise Kitchen::UserError
      end
    end
  end

  describe "#compile" do
    subject { described_object.compile }

    describe "on Unix with chef-cli" do
      before do
        described_object.expects(:which).with("chef-cli").returns("chef-cli")
      end

      let(:os) { "linux-gnu" }

      describe "with simple paths" do
        let(:policyfile) { "/home/user/cookbook/Policyfile.rb" }
        let(:license) { "accept" }
        it do
          described_object.expects(:run_command).with("chef-cli install /home/user/cookbook/Policyfile.rb --chef-license accept")
          subject
        end
      end

      describe "with Jenkins-y paths" do
        let(:policyfile) { "/home/jenkins/My Chef Cookbook/workspace/current/Policyfile.rb" }
        let(:license) { "accept-silent" }
        it do
          described_object.expects(:run_command).with('chef-cli install /home/jenkins/My\\ Chef\\ Cookbook/workspace/current/Policyfile.rb --chef-license accept-silent')
          subject
        end
      end

      describe "with Jenkins-y paths" do
        let(:policyfile) { "/home/jenkins/My Chef Cookbook/workspace/current/Policyfile.rb" }
        let(:license) { "accept-no-persist" }
        it do
          described_object.expects(:run_command).with('chef-cli install /home/jenkins/My\\ Chef\\ Cookbook/workspace/current/Policyfile.rb --chef-license accept-no-persist')
          subject
        end
      end
    end

    describe "on Windows with chef-cli" do
      before do
        described_object.expects(:which).with("chef-cli").returns("chef-cli")
      end

      let(:os) { "mswin" }

      describe "with simple paths" do
        let(:policyfile) { 'C:\\cookbook\\Policyfile.rb' }
        let(:license) { "accept" }
        it do
          described_object.expects(:run_command).with('chef-cli install C:\\cookbook\\Policyfile.rb --chef-license accept')
          subject
        end
      end

      describe "with Jenkins-y paths" do
        let(:policyfile) { 'C:\\Program Files\\Jenkins\\My Chef Cookbook\\workspace\\current\\Policyfile.rb' }
        let(:license) { "accept-silent" }
        it do
          described_object.expects(:run_command).with('chef-cli install "C:\\\\Program\\ Files\\\\Jenkins\\\\My\\ Chef\\ Cookbook\\\\workspace\\\\current\\\\Policyfile.rb" --chef-license accept-silent')
          subject
        end
      end

      describe "with Jenkins-y paths" do
        let(:policyfile) { 'C:\\Program Files\\Jenkins\\My Chef Cookbook\\workspace\\current\\Policyfile.rb' }
        let(:license) { "accept-no-persist" }
        it do
          described_object.expects(:run_command).with('chef-cli install "C:\\\\Program\\ Files\\\\Jenkins\\\\My\\ Chef\\ Cookbook\\\\workspace\\\\current\\\\Policyfile.rb" --chef-license accept-no-persist')
          subject
        end
      end
    end

    describe "on Unix with chef" do
      before do
        described_object.expects(:which).with("chef-cli").returns(false)
        described_object.expects(:which).with("chef").returns("chef")
      end

      let(:os) { "linux-gnu" }

      describe "with simple paths" do
        let(:policyfile) { "/home/user/cookbook/Policyfile.rb" }
        let(:license) { "accept" }
        it do
          described_object.expects(:run_command).with("chef install /home/user/cookbook/Policyfile.rb --chef-license accept")
          subject
        end
      end

      describe "with Jenkins-y paths" do
        let(:policyfile) { "/home/jenkins/My Chef Cookbook/workspace/current/Policyfile.rb" }
        let(:license) { "accept-silent" }
        it do
          described_object.expects(:run_command).with('chef install /home/jenkins/My\\ Chef\\ Cookbook/workspace/current/Policyfile.rb --chef-license accept-silent')
          subject
        end
      end

      describe "with Jenkins-y paths" do
        let(:policyfile) { "/home/jenkins/My Chef Cookbook/workspace/current/Policyfile.rb" }
        let(:license) { "accept-no-persist" }
        it do
          described_object.expects(:run_command).with('chef install /home/jenkins/My\\ Chef\\ Cookbook/workspace/current/Policyfile.rb --chef-license accept-no-persist')
          subject
        end
      end
    end

    describe "on Windows with chef" do
      before do
        described_object.expects(:which).with("chef-cli").returns(false)
        described_object.expects(:which).with("chef").returns("chef")
      end

      let(:os) { "mswin" }

      describe "with simple paths" do
        let(:policyfile) { 'C:\\cookbook\\Policyfile.rb' }
        let(:license) { "accept" }
        it do
          described_object.expects(:run_command).with('chef install C:\\cookbook\\Policyfile.rb --chef-license accept')
          subject
        end
      end

      describe "with Jenkins-y paths" do
        let(:policyfile) { 'C:\\Program Files\\Jenkins\\My Chef Cookbook\\workspace\\current\\Policyfile.rb' }
        let(:license) { "accept-silent" }
        it do
          described_object.expects(:run_command).with('chef install "C:\\\\Program\\ Files\\\\Jenkins\\\\My\\ Chef\\ Cookbook\\\\workspace\\\\current\\\\Policyfile.rb" --chef-license accept-silent')
          subject
        end
      end

      describe "with Jenkins-y paths" do
        let(:policyfile) { 'C:\\Program Files\\Jenkins\\My Chef Cookbook\\workspace\\current\\Policyfile.rb' }
        let(:license) { "accept-no-persist" }
        it do
          described_object.expects(:run_command).with('chef install "C:\\\\Program\\ Files\\\\Jenkins\\\\My\\ Chef\\ Cookbook\\\\workspace\\\\current\\\\Policyfile.rb" --chef-license accept-no-persist')
          subject
        end
      end
    end
  end
  # rubocop:enable Layout/LineLength
end
