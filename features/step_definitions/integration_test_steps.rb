Given /^a Chef cookbook( with syntax errors)?$/ do |syntax_errors|
  chef_cookbook(:malformed => ! syntax_errors.nil?, :type => :real_world)
end

Given 'a Chef cookbook that defines integration tests with no configurations specified' do
  chef_cookbook(:type => :newly_generated, :name => 'example', :path => '.')
  define_integration_tests(:name => 'example', :project_type => 'cookbook', :configurations => [])
end

Given 'a Chef cookbook that defines integration tests for two configurations (client and server)' do
  chef_cookbook(:type => :newly_generated, :name => 'example', :path => '.')
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
  chef_cookbook(:type => :newly_generated, :name => 'example_test', :path => './example/test/kitchen/cookbooks')
  configuration_recipe('example', 'example_test', 'default')
  cd 'example'
end

Given 'a supporting test cookbook that includes client and server recipes' do
  chef_cookbook(:type => :newly_generated, :name => 'example_test', :path => './example/test/kitchen/cookbooks')
  configuration_recipe('example', 'example_test', 'client')
  configuration_recipe('example', 'example_test', 'server')
  cd 'example'
end

Given /^a supporting test cookbook that includes only the server recipe$/ do
  chef_cookbook(:type => :newly_generated, :name => 'example_test', :path => './example/test/kitchen/cookbooks')
  configuration_recipe('example', 'example_test', 'server')
  cd 'example'
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

When 'I view the command line help' do
  run_simple(unescape("bundle exec kitchen --help"), false)
end

When /^I view command line help for the ([a-z]+) sub\-command$/ do |subcommand|
  command_help(subcommand)
end

Then 'an error indicating that the client configuration does not have a matching recipe will be shown' do
  assert missing_config_recipe_error_shown?('client')
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

Then 'the available options will be shown with a brief description of each' do
  assert_command_banner_present(current_subcommand)

  option_flags.must_equal ['configuration', 'platform', 'runner', 'help']

  assert_option_present('--configuration CONFIG',
    'The project configuration to test. Defaults to all configurations.')
  assert_option_present('--platform PLATFORM',
    'The platform to use. If not specified tests will be run against all platforms.')
  assert_option_present('-r, --runner RUNNER',
    'The underlying virtualization platform to test with.')
  assert_option_present('-h, --help', 'Show this message')
end

Then 'the expected platforms will be available' do
  available_platforms.must_equal(["ubuntu-10.04", "ubuntu-11.04", "centos-5.7", "centos-6.2"])
end

Then 'the test cookbook client and server recipes will be converged once for each platform' do
  expected_platforms.each do |platform|
    %w{client server}.each do |recipe|
      assert(converged?(platform, recipe),
        "Expected platform '#{platform}' to have been converged with configuration recipe '#{recipe}'.")
    end
  end
end

Then 'the test cookbook default recipe will be converged once for each platform' do
  expected_platforms.each do |platform|
    assert(converged?(platform, 'default'),
      "Expected platform '#{platform}' to have been converged.")
  end
end

Then 'the test cookbook default recipe will not be converged' do
  expected_platforms.each do |platform|
    refute(converged?(platform, 'default'),
      "Expected default recipe not to have been converged.")
  end
end

Then /^the test cookbook default and server recipes will not be converged$/ do
  expected_platforms.each do |platform|
    %w{default server}.each do |recipe|
      refute(converged?(platform, recipe),
        "Expected #{recipe} recipe not to have been converged.")
    end
  end
end

Then /^the tests will have been run( successfully)?$/ do |successfully|
  assert tests_run? if successfully
  # TODO: Assert that the test output shows tests success too
  last_exit_status.must_equal 0
end

Then 'the tests will not have been run' do
  refute tests_run?
end
