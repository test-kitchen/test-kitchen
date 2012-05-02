Given 'a Chef cookbook' do
  chef_cookbook
end

Given 'a Ruby project that uses bundler to manage its dependencies' do
  ruby_project
end

Given /^the integration tests are defined in a (malformed )?Kitchenfile included with the (cookbook|project)$/ do |malformed, project_type|
  define_integration_tests(:malformed => malformed, :project_type => project_type)
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

Then 'an error indicating that there is a problem with the configuration will be shown' do
  assert kitchenfile_error_shown?
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

Then 'the tests will have been run successfully' do
  assert tests_run?
  # TODO: Assert that the test output shows tests success too
  last_exit_status.must_equal 0
end

Then 'the tests will not have been run' do
  refute tests_run?
end
