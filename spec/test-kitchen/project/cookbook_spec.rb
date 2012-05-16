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

require 'test-kitchen'

module TestKitchen

  module Project
    describe Cookbook do
      describe "#each_build" do
        it "yields only supported platforms" do
          cookbook = Cookbook.new('example')
          cookbook.supported_platforms = %w{ubuntu centos}
          actual_matrix = []
          cookbook.each_build(%w{beos-5.0 centos-5.0 centos-6.2}) do |platform,configuration|
            actual_matrix << [platform, configuration]
          end
          actual_matrix.must_equal([
            ['centos-5.0', cookbook],
            ['centos-6.2', cookbook]
          ])
        end
        it "yields all platforms if the cookbook does not specify the supported platforms" do
          cookbook = Cookbook.new('example')
          cookbook.supported_platforms = []
          actual_matrix = []
          cookbook.each_build(%w{beos-5.0 centos-5.0 centos-6.2}) do |platform,configuration|
            actual_matrix << [platform, configuration]
          end
          actual_matrix.must_equal([
            ['beos-5.0', cookbook],
            ['centos-5.0', cookbook],
            ['centos-6.2', cookbook]
          ])
        end

      end
    end
    describe "#extract_supported_platforms" do
      let(:cookbook) { Cookbook.new('example') }
      it "raises if no metadata is provided" do
        lambda { cookbook.extract_supported_platforms }.must_raise ArgumentError
      end
      it "raises if the metadata is nil" do
        lambda { cookbook.extract_supported_platforms(nil) }.must_raise ArgumentError
      end
      it "returns an empty if the metadata does not parse" do
        cookbook.extract_supported_platforms(%q{
          <%= not_ruby_code %>
        }).must_be_empty
      end
      it "returns an empty if the metadata does not specify platforms" do
        cookbook.extract_supported_platforms(%q{
          maintainer       "Example Person"
          maintainer_email "example@example.org"
          license          "All rights reserved"
          description      "Installs/Configures example"
          long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
          version          "0.0.1"
        }).must_be_empty
      end
      it "returns the name of the supported platforms" do
        cookbook.extract_supported_platforms(%q{
          maintainer       "Example Person"
          maintainer_email "example@example.org"
          license          "All rights reserved"
          description      "Installs/Configures example"
          long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
          version          "0.0.1"
          supports         "ubuntu"
          supports         "centos"
        }).must_equal(%w{ubuntu centos})
      end
      it "returns the name of the supported platforms for a word list" do
        cookbook.extract_supported_platforms(%q{
          maintainer       "Example Person"
          maintainer_email "example@example.org"
          license          "All rights reserved"
          description      "Installs/Configures example"
          long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
          version          "0.0.1"
          %w{centos ubuntu debian}.each do |os|
            supports os
          end
        }).must_equal(%w{centos ubuntu debian})
      end
    end
    describe "#non_buildable_platforms" do
      let(:cookbook) { Cookbook.new('example') }
      it "returns empty if all platforms can be built" do
        cookbook.supported_platforms = 'centos', 'ubuntu'
        cookbook.non_buildable_platforms(
          ['centos-6.2', 'ubuntu-10.04']).must_be_empty
      end
      it "returns the platforms that are not supported for builds" do
        cookbook.supported_platforms = 'centos', 'ubuntu', 'beos'
        cookbook.non_buildable_platforms(
          ['centos-6.2', 'ubuntu-10.04']).must_equal(['beos'])
      end
    end
    describe "#language" do
      let(:cookbook) { Cookbook.new('example') }
      it "returns the language when asked" do
        cookbook.language.must_equal 'chef'
      end
      it "doesn't allow the language to be overridden" do
        cookbook.language('java')
        cookbook.language.must_equal 'chef'
      end
    end
    describe "#preflight_command" do
      let(:cookbook) { Cookbook.new('example') }
      it "returns nil if linting is disabled" do
        cookbook.lint = false
        refute cookbook.preflight_command
      end
      it "returns two commands if linting is enabled" do
        cookbook.root_path = 'cookbooks/example'
        cookbook.preflight_command.split(" && ").size.must_equal 2
      end
      it "includes the command to check the cookbook is well-formed" do
        cookbook.root_path = 'cookbooks/example'
        cookbook.preflight_command.split(" && ").first.must_equal "knife cookbook test -o cookbooks/example/.. example"
      end
      describe "lint options" do
        let(:lint_cmd) do
          cookbook.root_path = 'cookbooks/example'
          cookbook.preflight_command.split(" && ").last
        end
        it "includes the command to lint the cookbook" do
          lint_cmd.must_match /^foodcritic/
        end
        it "fails for any correctness warning except undeclared metadata dependencies" do
          lint_cmd.must_equal "foodcritic -f ~FC007 -f correctness cookbooks/example"
        end
      end
    end
  end
end
