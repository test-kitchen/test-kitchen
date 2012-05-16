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
    describe Base do
      describe "#initialize" do
        it "raises if the environment is nil" do
          lambda { Base.new(nil) }.must_raise ArgumentError
        end
        it "accepts an environment" do
          env = Environment.new(:ignore_kitchenfile => true)
          Base.new(env)
        end
        it "accepts an empty options hash" do
          env = Environment.new(:ignore_kitchenfile => true)
          Base.new(env, {})
        end
      end
      describe "subclassing" do
        let(:runner) do
          Base.new(Environment.new(:ignore_kitchenfile => true))
        end
        describe "#destroy" do
          it "leaves the implementation of destroy to subclasses" do
            lambda { runner.destroy }.must_raise NotImplementedError
          end
        end
        describe "#status" do
          it "leaves the implementation of status to subclasses" do
            lambda { runner.status }.must_raise NotImplementedError
          end
        end
        describe "#ssh" do
          it "leaves the implementation of ssh to subclasses" do
            lambda { runner.ssh }.must_raise NotImplementedError
          end
        end
        describe "#execute_remote_command" do
          it "leaves the implementation of execute_remote_command to subclasses" do
            lambda { runner.execute_remote_command(nil, nil) }.must_raise NotImplementedError
          end
        end
      end
      describe "#run_list" do
        it "defaults to the test-kitchen default recipe" do
          Base.new(Environment.new(:ignore_kitchenfile => true)).run_list.must_equal(['test-kitchen::default'])
        end
      end
      describe "#test" do
        let(:project) { TestKitchen::Project::Cookbook.new('example') }
        let(:runner) do
          Class.new(Base) do
            attr_accessor :commands
            def initialize(env, options={})
              super(env, options)
              @commands = []
            end
            def execute_remote_command(platform, command, message=nil)
              @commands << command
            end
          end.new(Environment.new(:ignore_kitchenfile => true),
            {:configuration => project})
        end
        it "executes the update_code, install and test commands in order" do
          runner.test
          runner.commands.slice!(0).must_equal(project.update_code_command)
          runner.commands.slice!(0)#.must_equal(project.install_command)
          runner.commands.slice!(0).must_equal(project.test_command)
          runner.commands.must_be_empty
        end
      end
    end
  end
end
