Feature: Add Test Kitchen support to an existing project
  In order to add Test Kitchen to a project with minimal effort
  As an operator
  I want to run a command to initialize my project

  Scenario: Displaying help
    When I run `kitchen help init`
    Then the output should contain:
    """
    Usage:
      kitchen init
    """
    And the exit status should be 0

  Scenario: Running init with default values
    When I run `kitchen init`
    Then the exit status should be 0
    And a directory named ".kitchen" should exist
    And a directory named "test/integration/default" should exist
    And the file ".gitignore" should contain ".kitchen/"
    And the file ".gitignore" should contain ".kitchen.local.yml"
    And the file "Gemfile" should contain "https://rubygems.org"
    And the file "Gemfile" should contain "gem 'test-kitchen'"
    And the file "Gemfile" should contain "gem 'kitchen-vagrant'"
    And the file ".kitchen.yml" should contain "driver_plugin: vagrant"
    And a file named "Rakefile" should not exist
    And a file named "Thorfile" should not exist
    And the output should contain "You must run `bundle install'"

  Scenario: Running init with multiple drivers appends to the Gemfile
    When I successfully run `kitchen init --driver=kitchen-bluebox kitchen-wakka`
    Then the file "Gemfile" should contain "gem 'kitchen-bluebox'"
    And the file "Gemfile" should contain "gem 'kitchen-wakka'"
    And the output should contain "You must run `bundle install'"

  Scenario: Running init with multiple driver sets the plugin_driver to the
    first driver given
    When I successfully run `kitchen init --driver=kitchen-bluebox kitchen-wakka`
    Then the file ".kitchen.yml" should contain "driver_plugin: bluebox"

  Scenario: Running init with no drivers sets the plugin_driver to the
    dummy driver
    When I successfully run `kitchen init --no-driver`
    Then the file ".kitchen.yml" should contain "driver_plugin: dummy"

  Scenario: Running with a Rakefile file appends Kitchen tasks
    Given an empty file named "Rakefile"
    When I successfully run `kitchen init`
    Then the file "Rakefile" should contain:
    """
    begin
      require 'kitchen/rake_tasks'
      Kitchen::RakeTasks.new
    rescue LoadError
      puts ">>>>> Kitchen gem not loaded, omitting tasks" unless ENV['CI']
    end
    """

  Scenario: Running with a Thorfile file appends Kitchen tasks
    Given an empty file named "Thorfile"
    When I successfully run `kitchen init`
    Then the file "Thorfile" should contain:
    """
    begin
      require 'kitchen/thor_tasks'
      Kitchen::ThorTasks.new
    rescue LoadError
      puts ">>>>> Kitchen gem not loaded, omitting tasks" unless ENV['CI']
    end
    """

  Scenario: Running init with a the name attribute metadata.rb sets a run list
    Given a file named "metadata.rb" with:
    """
    name              "ntp"
    license           "Apache 2.0"
    description       "Installs and configures ntp as a client or server"
    version           "0.1.0"

    support "ubuntu"
    support "centos"
    """
    When I successfully run `kitchen init`
    Then the file ".kitchen.yml" should contain:
    """
    suites:
    - name: default
      run_list:
      - recipe[ntp]
      attributes: {}
    """
