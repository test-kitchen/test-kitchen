Feature: Add Test Kitchen support to an existing project
  In order to add Test Kitchen to a project with minimal effort
  As an operator
  I want to run a command to initialize my project

  Background:
    Given a sandboxed GEM_HOME directory named "kitchen-init"

  @spawn
  Scenario: Displaying help
    When I run `kitchen help init`
    Then the output should contain:
    """
    Usage:
      kitchen init
    """
    And the exit status should be 0

  @spawn
  Scenario: Running init with default values
    Given I have a git repository
    When I run `kitchen init`
    Then the exit status should be 0
    And a directory named "test/integration/default" should exist
    And the file ".gitignore" should contain ".kitchen/"
    And the file ".gitignore" should contain "kitchen.local.yml"
    And the file ".gitignore" should contain ".kitchen.local.yml"
    And the file "kitchen.yml" should exist:
    And the file "kitchen.yml" should contain:
    """
    driver:
      name: vagrant
    """
    And a file named "Gemfile" should not exist
    And a file named "Rakefile" should not exist
    And a file named "Thorfile" should not exist
    And a gem named "kitchen-vagrant" is installed
    And a file named "chefignore" should exist
    And the file "chefignore" should contain ".kitchen"

  Scenario: Running init that creates a Gemfile
    When I successfully run `kitchen init --create-gemfile`
    Then the file "Gemfile" should contain "https://rubygems.org"
    And the file "Gemfile" should contain:
    """
    gem "test-kitchen"
    """
    And the file "Gemfile" should contain:
    """
    gem "kitchen-vagrant"
    """
    And the output should contain "You must run `bundle install'"

  Scenario: Running init with an existing Gemfile appends to the Gemfile
    Given a file named "Gemfile" with:
    """
    source "https://rubygems.org"


    """
    When I successfully run `kitchen init`
    Then the file "Gemfile" should contain exactly:
    """
    source "https://rubygems.org"

    gem "test-kitchen"
    gem "kitchen-vagrant"

    """
    And the output should contain "You must run `bundle install'"

  Scenario: Running init with a Gemfile containing test-kitchen does not
    re-append
    Given a file named "Gemfile" with:
    """
    source "https://rubygems.org"

    gem 'test-kitchen'

    """
    When I successfully run `kitchen init`
    Then the file "Gemfile" should contain exactly:
    """
    source "https://rubygems.org"

    gem 'test-kitchen'
    gem "kitchen-vagrant"

    """
    And the output should contain "You must run `bundle install'"

  Scenario: Running init with a Gemfile containing the driver gem does not
    re-append
    Given a file named "Gemfile" with:
    """
    source "https://rubygems.org"

    gem 'test-kitchen'
    gem 'kitchen-ec2'

    """
    When I successfully run `kitchen init --driver=kitchen-ec2`
    Then the file "Gemfile" should contain exactly:
    """
    source "https://rubygems.org"

    gem 'test-kitchen'
    gem 'kitchen-ec2'

    """
    And the output should not contain "You must run `bundle install'"

  Scenario: Running init with multiple drivers appends to the Gemfile
    Given an empty file named "Gemfile"
    When I successfully run `kitchen init --driver=kitchen-bluebox kitchen-wakka`
    Then the file "Gemfile" should contain:
    """
    gem "kitchen-bluebox"
    """
    And the file "Gemfile" should contain:
    """
    gem "kitchen-wakka"
    """
    And the output should contain "You must run `bundle install'"

  Scenario: Running init with multiple driver sets the plugin_driver to the
    first driver given
    Given an empty file named "Gemfile"
    When I successfully run `kitchen init --driver=kitchen-bluebox kitchen-wakka`
    Then the file "kitchen.yml" should exist
    Then the file "kitchen.yml" should contain:
    """
    driver:
      name: bluebox
    """

  Scenario: Running init with no drivers sets the plugin_driver to the
    dummy driver
    Given an empty file named "Gemfile"
    When I successfully run `kitchen init --no-driver`
    Then the file "kitchen.yml" should contain:
    """
    driver:
      name: dummy
    """

  Scenario: Running init without a provisioner sets the default provisioner
    to chef_solo in kitchen.yml
    Given an empty file named "Gemfile"
    When I successfully run `kitchen init --no-driver`
    Then the file "kitchen.yml" should contain:
    """
    provisioner:
      name: chef_solo
    """

  Scenario: Running init with a provisioner sets the provisioner in kitchen.yml
    Given an empty file named "Gemfile"
    When I successfully run `kitchen init --no-driver --provisioner=chef_zero`
    Then the file "kitchen.yml" should contain:
    """
    provisioner:
      name: chef_zero
    """

  Scenario: Running with a Rakefile file appends Kitchen tasks
    Given an empty file named "Gemfile"
    And an empty file named "Rakefile"
    When I successfully run `kitchen init`
    Then the file "Rakefile" should contain:
    """
    begin
      require 'kitchen/rake_tasks'
      Kitchen::RakeTasks.new
    rescue LoadError
      puts '>>>>> Kitchen gem not loaded, omitting tasks' unless ENV['CI']
    end
    """

  Scenario: Running without git doesn't make a .gitignore
    When I successfully run `kitchen init --no-driver`
    Then the exit status should be 0
    And a file named ".gitignore" should not exist

  Scenario: Running with a Thorfile file appends Kitchen tasks
    Given an empty file named "Gemfile"
    Given an empty file named "Thorfile"
    When I successfully run `kitchen init`
    Then the file "Thorfile" should contain:
    """
    begin
      require 'kitchen/thor_tasks'
      Kitchen::ThorTasks.new
    rescue LoadError
      puts '>>>>> Kitchen gem not loaded, omitting tasks' unless ENV['CI']
    end
    """

  Scenario: Running init with a name in metadata.rb sets a run list
    Given an empty file named "Gemfile"
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
    Then the file "kitchen.yml" should contain exactly:
    """
    ---
    driver:
      name: vagrant

    provisioner:
      name: chef_solo

    platforms:
      - name: ubuntu-16.04
      - name: centos-7

    suites:
      - name: default
        run_list:
          - recipe[ntp::default]
        attributes:

    """

  Scenario: Running init with an empty file metadata.rb sets an empty run list
    Given an empty file named "metadata.rb"
    When I successfully run `kitchen init`
    Then the file "kitchen.yml" should contain exactly:
    """
    ---
    driver:
      name: vagrant

    provisioner:
      name: chef_solo

    platforms:
      - name: ubuntu-16.04
      - name: centos-7

    suites:
      - name: default
        run_list:
        attributes:

    """

  Scenario: Running init with no metadata.rb file sets an empty run list
    Given a file named "metadata.rb" does not exist
    When I successfully run `kitchen init`
    Then the file "kitchen.yml" should contain exactly:
    """
    ---
    driver:
      name: vagrant

    provisioner:
      name: chef_solo

    platforms:
      - name: ubuntu-16.04
      - name: centos-7

    suites:
      - name: default
        run_list:
        attributes:

    """
