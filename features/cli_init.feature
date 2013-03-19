Feature: Ensure that the Command Line Interface init creates the correct files
  In order to initialize an un-Kitchenified cookbook
  As an Operator
  I want to initialize a cookbook

@ok
Scenario: Basic init with no extras succeeds
  When I run `kitchen init` interactively
  And I type "n"
  Then the exit status should be 0
  And a directory named ".kitchen" should exist
  And a directory named "test/integration/default" should exist
  And the file ".gitignore" should contain:
  """
  .kitchen/
  .kitchen.local.yml
  """
  And the file ".kitchen.yml" should contain:
  """
  ---
  driver_plugin: vagrant
  platforms:
  - name: ubuntu-12.04
    driver_config:
      box: opscode-ubuntu-12.04
      box_url: https://opscode-vm.s3.amazonaws.com/vagrant/boxes/opscode-ubuntu-12.04.box
    run_list:
    - recipe[apt]
  - name: ubuntu-10.04
    driver_config:
      box: opscode-ubuntu-10.04
      box_url: https://opscode-vm.s3.amazonaws.com/vagrant/boxes/opscode-ubuntu-10.04.box
    run_list:
    - recipe[apt]
  - name: centos-6.3
    driver_config:
      box: opscode-centos-6.3
      box_url: https://opscode-vm.s3.amazonaws.com/vagrant/boxes/opscode-centos-6.3.box
    run_list:
    - recipe[yum::epel]
  - name: centos-5.8
    driver_config:
      box: opscode-centos-5.8
      box_url: https://opscode-vm.s3.amazonaws.com/vagrant/boxes/opscode-centos-5.8.box
    run_list:
    - recipe[yum::epel]
  suites:
  - name: default
    run_list: []
    attributes: {}
  """
  And a file named "Gemfile" should not exist
  And a file named "Rakefile" should not exist
  And a file named "Thorfile" should not exist



@ok
Scenario: Running with a Rakefile file appends Kitchen tasks
  Given an empty file named "Rakefile"
  When I run `kitchen init` interactively
  And I type "n"
  Then the exit status should be 0
  And the file "Rakefile" should contain exactly:
  """

  begin
    require 'kitchen/rake_tasks'
    Kitchen::RakeTasks.new
  rescue LoadError
    puts ">>>>> Kitchen gem not loaded, omitting tasks" unless ENV['CI']
  end

  """

@ok
Scenario: Running with a Thorfile file appends Kitchen tasks
  Given an empty file named "Thorfile"
  When I run `kitchen init` interactively
  And I type "n"
  Then the exit status should be 0
  And the file "Thorfile" should contain exactly:
  """

  begin
    require 'kitchen/thor_tasks'
    Kitchen::ThorTasks.new
  rescue LoadError
    puts ">>>>> Kitchen gem not loaded, omitting tasks" unless ENV['CI']
  end

  """

@ok
Scenario: Listing the drivers provides correct output, does not write Gemfile
  When I run `kitchen init` interactively
  And I type "y"
  And I type "list"
  And I type "skip"
  Then the exit status should be 0
  And a file named ".kitchen.yml" should exist
  And a directory named ".kitchen" should exist
  And a file named "Gemfile" should not exist

@ok
Scenario: Running the init command without a Gemfile provides warning and fails
  When I run `kitchen init` interactively
  And I type "y"
  And I type "kitchen-vagrant"
  And the output should contain "You do not have an existing Gemfile"
  Then the exit status should be 1

@ok
Scenario: Running the init command succeeds
  Given an empty file named "Gemfile"
  When I run `kitchen init` interactively
  And I type "y"
  And I type "kitchen-vagrant"
  Then the exit status should be 0
  And the output should contain "You must run `bundle install' to fetch any new gems."
  And a file named ".kitchen.yml" should exist
  And a file named ".gitignore" should exist
  And the file "Gemfile" should contain "gem 'kitchen-vagrant', :group => :integration"

@ok
Scenario: Running init with a correct metadata.rb works
  Given a file named "metadata.rb" with:
  """
  name              "ntp"
  license           "Apache 2.0"
  description       "Installs and configures ntp as a client or server"
  version           "0.1.0"
  recipe "ntp", "Installs and configures ntp either as a server or client"

  %w{ ubuntu debian redhat centos fedora scientific amazon oracle freebsd }.each do |os|
    supports os
  end
  """
  When I run `kitchen init` interactively
  And I type "n"
  Then the exit status should be 0
  And the file ".kitchen.yml" should contain:
  """
  suites:
  - name: default
    run_list:
    - recipe[ntp]
    attributes: {}
  """
