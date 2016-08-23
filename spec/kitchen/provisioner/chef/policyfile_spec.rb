# -*- encoding: utf-8 -*-
#
# Author:: Noah Kantrowitz
#
# Copyright (C) 2016, Noah Kantrowitz
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

require_relative "../../../spec_helper"
require "kitchen/provisioner/chef/policyfile"

describe Kitchen::Provisioner::Chef::Policyfile do
  let(:policyfile) { "" }
  let(:path) { "" }
  let(:null_logger) do
    stub(:fatal => nil, :error => nil, :warn => nil, :info => nil,
         :debug => nil, :banner => nil)
  end
  let(:described_object) do
    Kitchen::Provisioner::Chef::Policyfile.new(policyfile, path, :logger => null_logger)
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

  # rubocop:disable Metrics/LineLength
  describe "#resolve" do
    subject { described_object.resolve }

    describe "on Unix" do
      let(:os) { "linux-gnu" }

      describe "with simple paths" do
        let(:policyfile) { "/home/user/cookbook/Policyfile.rb" }
        let(:path) { "/tmp/kitchen/cookbooks" }
        it do
          described_object.expects(:run_command).with("chef export /home/user/cookbook/Policyfile.rb /tmp/kitchen/cookbooks --force")
          subject
        end
      end

      describe "with Jenkins-y paths" do
        let(:policyfile) { "/home/jenkins/My Chef Cookbook/workspace/current/Policyfile.rb" }
        let(:path) { "/tmp/kitchen/cookbooks" }
        it do
          described_object.expects(:run_command).with("chef export /home/jenkins/My\\ Chef\\ Cookbook/workspace/current/Policyfile.rb /tmp/kitchen/cookbooks --force")
          subject
        end
      end
    end

    describe "on Windows" do
      let(:os) { "mswin" }

      describe "with simple paths" do
        let(:policyfile) { "C:\\cookbook\\Policyfile.rb" }
        let(:path) { "C:\\Temp\\kitchen\\cookbooks" }
        it do
          described_object.expects(:run_command).with("chef export C:\\cookbook\\Policyfile.rb C:\\Temp\\kitchen\\cookbooks --force")
          subject
        end
      end

      describe "with Jenkins-y paths" do
        let(:policyfile) { "C:\\Program Files\\Jenkins\\My Chef Cookbook\\workspace\\current\\Policyfile.rb" }
        let(:path) { "C:\\Temp\\kitchen\\cookbooks" }
        it do
          described_object.expects(:run_command).with("chef export \"C:\\\\Program\\ Files\\\\Jenkins\\\\My\\ Chef\\ Cookbook\\\\workspace\\\\current\\\\Policyfile.rb\" C:\\Temp\\kitchen\\cookbooks --force")
          subject
        end
      end
    end
  end

  describe "#compile" do
    subject { described_object.compile }

    describe "on Unix" do
      let(:os) { "linux-gnu" }

      describe "with simple paths" do
        let(:policyfile) { "/home/user/cookbook/Policyfile.rb" }
        it do
          described_object.expects(:run_command).with("chef install /home/user/cookbook/Policyfile.rb")
          subject
        end
      end

      describe "with Jenkins-y paths" do
        let(:policyfile) { "/home/jenkins/My Chef Cookbook/workspace/current/Policyfile.rb" }
        it do
          described_object.expects(:run_command).with("chef install /home/jenkins/My\\ Chef\\ Cookbook/workspace/current/Policyfile.rb")
          subject
        end
      end
    end

    describe "on Windows" do
      let(:os) { "mswin" }

      describe "with simple paths" do
        let(:policyfile) { "C:\\cookbook\\Policyfile.rb" }
        it do
          described_object.expects(:run_command).with("chef install C:\\cookbook\\Policyfile.rb")
          subject
        end
      end

      describe "with Jenkins-y paths" do
        let(:policyfile) { "C:\\Program Files\\Jenkins\\My Chef Cookbook\\workspace\\current\\Policyfile.rb" }
        it do
          described_object.expects(:run_command).with("chef install \"C:\\\\Program\\ Files\\\\Jenkins\\\\My\\ Chef\\ Cookbook\\\\workspace\\\\current\\\\Policyfile.rb\"")
          subject
        end
      end
    end
  end
  # rubocop:enable Metrics/LineLength
end
