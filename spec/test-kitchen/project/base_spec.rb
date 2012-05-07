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

  module Project
    describe Base do
      describe "#initialize" do
        it "raises if a name is not provided" do
          lambda{ Base.new(nil) }.must_raise(ArgumentError)
        end
        it "raises if the name is empty" do
          lambda{ Base.new('') }.must_raise(ArgumentError)
        end
      end
      describe "#language" do
        it "defaults to ruby" do
          Base.new('foo').language.must_equal 'ruby'
        end
        it "can be set to erlang" do
          project = Base.new('foo')
          project.language = 'erlang'
          project.language.must_equal 'erlang'
        end
      end
      describe "#install" do
        it "defaults to bundle install when you are using ruby" do
          project = Base.new('foo')
          project.language = 'ruby'
          project.install.must_equal 'bundle install'
        end
        it "defaults to empty string when you are not using ruby" do
          project = Base.new('foo')
          project.language = 'erlang'
          project.install.must_equal ''
        end
        it "can be set to an arbitrary command" do
          project = Base.new('foo')
          project.install = 'make install'
          project.install.must_equal 'make install'
        end
      end
      describe "#run_list_extras" do
        it "defaults to an empty" do
          project = Base.new('foo')
          project.run_list_extras.must_be_empty
        end
        it "allows the run_list to be extended" do
          project = Base.new('foo')
          project.run_list_extras(['foo::bar'])
          project.run_list_extras.must_equal(['foo::bar'])
        end
      end
      describe "#script" do
        it "defaults to running rspec" do
          Base.new('foo').script.must_equal 'rspec spec'
        end
      end
      describe "#runtimes" do
        it "returns an empty if the language is not supported" do
          project = Base.new('foo')
          project.language = 'erlang'
          project.runtimes.must_be_empty
        end
      end
      describe "#build_matrix" do
        it "does not yield if there are no platforms"
          project = Base.new('mysql')
          project.each_build([]) do |platform,configuration|
            fail 'Should not have yielded'
          end
        end
        it "returns a row for each platform with the project if there are no configurations" do
          project = Base.new('mysql')
          project.configurations = []
          actual_matrix = []
          project.each_build(%w{ubuntu centos}) do |platform,configuration|
            actual_matrix << [platform, configuration]
          end
          actual_matrix.must_equal([
            ['ubuntu', project],
            ['centos', project]
          ])
        end
        it "returns a row for each platform if there is a single configuration" do
          project = Base.new('mysql')
          project.configurations = {'server' => 'server'}
          actual_matrix = []
          project.each_build(%w{ubuntu centos}) do |platform,configuration|
            actual_matrix << [platform, configuration]
          end
          actual_matrix.must_equal([
            ['ubuntu', 'server'],
            ['centos', 'server']
          ])
        end
        it "returns the product of platforms * configurations" do
          project = Base.new('mysql')
          project.configurations = {'client' => 'client', 'server' => 'server'}
          actual_matrix = []
          project.each_build(%w{ubuntu centos}) do |platform,configuration|
            actual_matrix << [platform, configuration]
          end
          actual_matrix.must_equal([
            ['ubuntu', 'client'],
            ['ubuntu', 'server'],
            ['centos', 'client'],
            ['centos', 'server']
          ])
        end
        it "raises if passed a nil for platforms" do
          project = Base.new('mysql')
          project.configurations = ['client', 'server']
          lambda do
            project.each_build(nil) do |platform,configuration|
              fail 'Should not yield when platforms is nil'
            end
          end.must_raise ArgumentError
        end
        it "raises if a block was not provided" do
          project = Base.new('mysql')
          project.configurations = ['client', 'server']
          lambda{ project.each_build([]) }.must_raise ArgumentError
        end
        it "removes platform exclusions from the matrix" do
          project = Base.new('mysql')
          project.configurations = {'client' => 'client', 'server' => 'server'}
          project.exclude :platform => 'amazon'
          actual_matrix = []
          project.each_build(['ubuntu', 'amazon', 'centos']) do |platform,configuration|
            actual_matrix << [platform, configuration]
          end
          actual_matrix.must_equal([
            ['ubuntu', 'client'],
            ['ubuntu', 'server'],
            ['centos', 'client'],
            ['centos', 'server']
          ])
        end
        it "removes configuration-specific exclusions from the matrix" do
          project = Base.new('mysql')
          project.configurations = {'client' => 'client', 'server' => 'server'}
          project.exclude :platform => 'amazon', :configuration => 'server'
          actual_matrix = []
          project.each_build(['ubuntu', 'amazon', 'centos']) do |platform,configuration|
            actual_matrix << [platform, configuration]
          end
          actual_matrix.must_equal([
            ['ubuntu', 'client'],
            ['ubuntu', 'server'],
            ['amazon', 'client'],
            ['centos', 'client'],
            ['centos', 'server']
          ])
        end
      end
      describe "#update_code_command" do
        it "rsyncs the code from the source root to the test root" do
          project = Base.new('foo')
          project.update_code_command.must_equal "rsync -aHv --update --progress --checksum /test-kitchen/source/ /test-kitchen/test"
        end
      end
      describe "#install_command" do
        let(:project) { Base.new('foo') }
        it "requires subclasses to implement the install command" do
          lambda { project.install_command }.must_raise NotImplementedError
        end
       describe "#test_command" do
        let(:project) { Base.new('foo') }
        it "requires subclasses to implement the test command" do
          lambda { project.test_command }.must_raise NotImplementedError
        end
      end
     end
  end
end
