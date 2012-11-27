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

Given 'a Chef cookbook with no integration test configuration' do
  chef_cookbook(:type => :real_world, :missing_config => true)
end

Given /^a Chef cookbook( with syntax errors)?$/ do |syntax_errors|
  chef_cookbook(:malformed => ! syntax_errors.nil?, :type => :real_world)
end

Given 'a Chef cookbook that does not define a set of supported platforms in its metadata' do
  chef_cookbook(:type => :newly_generated, :name => 'example', :path => '.',
                :setup => false)
  define_integration_tests(:name => 'example', :project_type => 'cookbook')
end

Given 'a Chef cookbook that defines several supported platforms, one of which is not recognised' do
  chef_cookbook(:type => :newly_generated, :name => 'example', :path => '.',
                :setup => false, :supports_type => :includes_unrecognized)
  define_integration_tests(:name => 'example', :project_type => 'cookbook', :configurations => [])
end

Given /^a Chef cookbook that defines a set of supported platforms (literally|as a wordlist) in its metadata$/ do |supports_type|
  chef_cookbook(:type => :newly_generated, :name => 'example', :path => '.',
                :setup => false, :supports_type => supports_type == 'literally' ? :literal : :wordlist)
  define_integration_tests(:name => 'example', :project_type => 'cookbook', :configurations => [])
end

Given 'a Chef cookbook that defines integration tests with no configurations specified' do
  chef_cookbook(:type => :newly_generated, :name => 'example', :path => '.')
  define_integration_tests(:name => 'example', :project_type => 'cookbook', :configurations => [])
end

Given 'a Chef cookbook that defines integration tests for two configurations (client and server)' do
  chef_cookbook(:type => :newly_generated, :name => 'example', :path => '.', :recipes => %w{client server})
  define_integration_tests(:name => 'example', :project_type => 'cookbook', :configurations => %w{client server})
end

Given 'a Chef cookbook that would fail a lint tool correctness check' do
  chef_cookbook(:lint_problem => :correctness, :type => :real_world)
end

Given 'a Chef cookbook that would be flagged as having only style warnings by the lint tool' do
  chef_cookbook(:lint_problem => :style, :type => :real_world)
end

Given 'a Ruby project that uses bundler to manage its dependencies' do
  ruby_project
end

Given 'a supporting test cookbook that includes a default recipe' do
  cd '..'
  chef_cookbook(:type => :newly_generated, :name => 'example_test', :path => './example/test/kitchen/cookbooks')
  configuration_recipe('example', 'example_test', 'default')
  cd 'example'
end

Given 'a supporting test cookbook that includes client and server recipes' do
  cd '..'
  chef_cookbook(:type => :newly_generated, :name => 'example_test', :path => './example/test/kitchen/cookbooks')
  configuration_recipe('example', 'example_test', 'client')
  configuration_recipe('example', 'example_test', 'server')
  cd 'example'
end

Given /^a supporting test cookbook that includes only the server recipe$/ do
  cd '..'
  chef_cookbook(:type => :newly_generated, :name => 'example_test', :path => './example/test/kitchen/cookbooks')
  configuration_recipe('example', 'example_test', 'server')
  cd 'example'
end

Given 'an existing Chef cookbook with no tests defined' do
  chef_cookbook(:type => :real_world_testless)
end

Given 'an existing Chef cookbook named in metadata but not the directory' do
  chef_cookbook(:type => :real_world_testless_dir)
end

Given /^the integration tests are defined in a (malformed )?Kitchenfile included with the (cookbook|project)$/ do |malformed, project_type|
  define_integration_tests(:malformed => malformed, :project_type => project_type)
end

When 'I list the platforms' do
  list_platforms
end

When 'I run the integration tests with test kitchen' do
  run_integration_tests
end

When /^I run the integration tests twice with test kitchen with(out)? teardown$/ do |no_teardown|
  run_integration_tests :times => 2, :teardown => ! no_teardown
end

When /^I scaffold the integration tests$/ do
  scaffold_tests('vim')
end

When /^I scaffold the integration tests in its directory$/ do
  scaffold_tests('cookbook-vim')
end

When 'I run the command line tool from the bundle with no options' do
  run_simple(unescape("bundle exec kitchen"), false)
end

When /^I view command line help for the ([a-z]+) sub\-command$/ do |subcommand|
  command_help(subcommand)
end

Then 'a warning will be displayed for the unrecognized platform' do
  assert unrecognized_platform_warning_shown?('beos')
end

Then /^all (?:recognised )?platforms will be tested against$/ do
  assert_only_platforms_converged(['centos', 'ubuntu'])
end

Then /^an error indicating that there is a problem with the (configuration|cookbook syntax) will be shown$/ do |error|
  assert error == 'configuration' ? kitchenfile_error_shown? : syntax_error_shown?
end

Then /^an error indicating that there is a correctness problem with the cookbook will (not )?be shown$/ do |not_shown|
  if not_shown
    refute lint_correctness_error_shown?
  else
    assert lint_correctness_error_shown?
  end
end

Then 'each of the expected kitchen subcommands will be shown' do
  assert_correct_subcommands_shown
end

Then 'no node will have been torn down between runs' do
  refute any_platform_torn_down?
end

Then /^only the platforms specified in the metadata (wordlist )?will be tested against$/ do |wordlist|
  assert_only_platforms_converged(wordlist ? ['centos', 'ubuntu'] : ['ubuntu'])
end

Then 'the available options will be shown with a brief description of each' do
  assert_command_banner_present(current_subcommand)

  option_flags.must_equal ['configuration', 'platform', 'runner', 'teardown', 'version', 'help']

  assert_option_present('--configuration CONFIG',
    'The project configuration to test. Defaults to all configurations.')
  assert_option_present('--platform PLATFORM',
    'The platform to use. If not specified tests will be run against all platforms.')
  assert_option_present('--teardown',
    'Teardown test nodes between runs.')
  assert_option_present('-r, --runner RUNNER',
    'The underlying virtualization platform to test with.')
  assert_option_present('-h, --help', 'Show this message')
end

Then 'the cookbook client recipe will be converged' do
  expected_platforms.each do |platform|
    assert(converged?(platform, "example::client"),
      "Expected client recipe to have been converged.")
  end
end

Then 'the cookbooks default recipe will have been converged successfully' do
  expected_platforms.each do |platform|
    converged?(platform, 'emacs::default')
  end
  last_exit_status.must_equal(0)
end

Then 'the existing cookbook will have been converged' do
  all_output.must_match /Chef Run complete in/
end

Then 'The generated Kitchenfile will contain the name from the metadata' do
  assert cookbook_project_name_metadata?
end

Then 'the expected platforms will be available' do
  available_platforms.must_equal(["centos-5.8", "centos-6.3", "ubuntu-10.04", "ubuntu-12.04"])
end

Then 'the node will have been torn down between runs' do
  assert any_platform_torn_down?
end

Then 'the test cookbook client and server recipes will be converged once for each platform' do
  expected_platforms.each do |platform|
    %w{client server}.each do |recipe|
      assert(converged?(platform, "example_test::#{recipe}"),
        "Expected platform '#{platform}' to have been converged with configuration recipe '#{recipe}'.")
    end
  end
end

Then 'the test cookbook default recipe will be converged once for each platform' do
  expected_platforms.each do |platform|
    assert(converged?(platform, 'example_test::default'),
      "Expected platform '#{platform}' to have been converged.")
  end
end

Then 'the test cookbook default recipe will not be converged' do
  expected_platforms.each do |platform|
    refute(converged?(platform, 'example_test::default'),
      "Expected default recipe not to have been converged.")
  end
end

Then 'the test cookbook server recipe will be converged' do
  expected_platforms.each do |platform|
    assert(converged?(platform, 'example_test::server'),
      "Expected server test recipe to have been converged.")
  end
end

Then /^the tests will have been run( successfully)?$/ do |successfully|
  assert tests_run?
  last_exit_status.must_equal(0) if successfully
end

Then 'the tests will not have been run' do
  refute tests_run?
end
