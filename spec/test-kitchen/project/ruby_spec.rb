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
    describe Ruby do
      describe "#install_command" do
        it "runs bundle install in the project directory" do
          project = Ruby.new('foo')
          project.install_command.must_equal 'cd /test-kitchen/test && bundle install'
        end
        it "uses rvm to switch to the selected runtime" do
          project = Ruby.new('foo')
          project.install_command('1.9.3').must_equal 'cd /test-kitchen/test && rvm use 1.9.3 && bundle install'
        end
      end
      describe "#test_command" do
        it "runs the install script in the project directory" do
          project = Ruby.new('foo')
          project.test_command.must_equal 'cd /test-kitchen/test && rspec spec'
        end
        it "runs the test script under the correct runtime" do
          project = Ruby.new('foo')
          project.test_command('1.9.3').must_equal 'cd /test-kitchen/test && rvm use 1.9.3 && rspec spec'
        end
      end
      describe "#runtimes" do
        it "defaults to ruby 1.9.2 if the language is ruby" do
          project = Ruby.new('foo')
          project.language = 'ruby'
          project.runtimes.must_equal ['1.9.2']
        end
      end
    end
  end
end
