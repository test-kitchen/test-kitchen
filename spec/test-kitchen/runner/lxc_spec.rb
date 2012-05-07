#
# Author:: Andrew Crump (<andrew@kotirisoftware.com>)
# Copyright:: Copyright (c) 2012 Opscode, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require_relative '../../spec_helper'

require 'test-kitchen'

module TestKitchen

  module Runner
    describe LXC do
      let(:env) do
        env = Environment.new(:ignore_kitchenfile => true)
        env.platforms['ubuntu'] = Platform.new('ubuntu') do
          version '11.04' do
            box "opscode-ubuntu-11.04"
            box_url "http://example.org/opscode-ubuntu-11.04.box"
          end
        end
        env
      end

      describe "#initialize" do
        it "complains if an environment is not provided" do
          lambda { Environment.new }.must_raise ArgumentError
        end
        it "accepts an environment as a constructor argument" do
          runner = LXC.new(env)
          runner.env.must_equal env
          runner.options.must_equal({})
        end
        it "optionally accepts an options too" do
          runner = LXC.new(env, {:platform => 'ubuntu'})
          runner.env.must_equal env
          runner.options.must_equal({:platform => 'ubuntu'})
        end
        it "raises if the supported host platform is not available" do
          env = Environment.new(:ignore_kitchenfile => true)
          env.platforms['centos'] = Platform.new('centos') do
            version '5.7' do
              box "opscode-centos-5.7"
              box_url "http://example.org/opscode-centos-5.7.box"
            end
          end
          lambda{ runner = LXC.new(env, {:platform => 'foo'}) }.must_raise ArgumentError,
            "LXC host box 'ubuntu-11.04' is not available"
       end
      end
      describe "#nested_runner" do
        it "wraps a nested runner which acts as the LXC host" do
          runner = LXC.new(env, {:platform => 'ubuntu'})
          runner.nested_runner = 'foo'
          runner.nested_runner.must_equal 'foo'
        end
        it "defaults the nested runner to using vagrant" do
          skip "Vagrant runner is not test friendly"
        end
        it "sets the host platform to natty" do
          skip "Vagrant runner is not test friendly"
        end
      end
      describe "#provision" do
        let(:runner) do
          runner = LXC.new(env, {:platform => 'ubuntu'})
        end
        it "delegates the provision call to the nested runner" do
          runner.nested_runner = MiniTest::Mock.new
          runner.nested_runner.expect :provision, nil
          runner.nested_runner.expect :with_target_vms, nil, [String]
          runner.provision
          runner.nested_runner.verify
        end
        describe "delegating commands" do
          class MockRunner
            def initialize(expected_cmd)
              @expected_cmd = expected_cmd
            end
            def provision

            end
            def with_target_vms(name)
              name.must_equal 'ubuntu-11.04'
              yield 'a virtual machine'
            end
            def execute_remote_command(vm, command, log)
              @executed = true
              command.must_equal @expected_cmd
            end
            def executed_command?
              @executed ||= false
            end
          end
          it "provisions the linux container" do
            nested_runner = MockRunner.new("sudo test-kitchen-lxc provision 'ubuntu' 'example_test::default'")
            env.project = TestKitchen::Project::Cookbook.new('example')
            runner.configuration = env.project
            runner.nested_runner = nested_runner
            runner.provision
            assert runner.nested_runner.executed_command?
          end
          it "delegates commands to the remote container" do
            nested_runner = MockRunner.new("sudo test-kitchen-lxc run 'centos-6' 'ls'")
            env.project = TestKitchen::Project::Cookbook.new('example')
            runner.configuration = env.project
            runner.nested_runner = nested_runner
            runner.execute_remote_command('centos-6', 'ls')
            assert runner.nested_runner.executed_command?
          end
          it "destroys the remote container" do
            nested_runner = MockRunner.new("sudo test-kitchen-lxc destroy 'ubuntu'")
            env.project = TestKitchen::Project::Cookbook.new('example')
            runner.configuration = env.project
            runner.nested_runner = nested_runner
            runner.destroy
            assert runner.nested_runner.executed_command?
          end
        end
      end
      describe "#run_list" do
        it "expresses the dependency on the LXC recipe" do
          runner = LXC.new(env, {:platform => 'ubuntu'})
          runner.run_list.must_include 'test-kitchen::lxc'
        end
      end
      describe "#status" do
        it "raises because it is not implemented" do
          runner = LXC.new(env, {:platform => 'ubuntu'})
          lambda { runner.status }.must_raise NotImplementedError
        end
      end
    end
  end
end
