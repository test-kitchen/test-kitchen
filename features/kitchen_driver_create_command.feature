Feature: Create a new Test Kitchen Driver project
  In order to make plugin development a snap
  As a user of Test Kitchen
  I want a command to run that will give me a driver gem project scaffold

  @spawn
  Scenario: Displaying help
    When I run `kitchen help driver create`
    Then the output should contain:
    """
    Usage:
      kitchen driver create [NAME]
    """
    And the exit status should be 0

  Scenario: Running with default values
    When I run `kitchen driver create qemu`
    Then a directory named "kitchen-qemu" should exist
    And the file "kitchen-qemu/CHANGELOG.md" should contain:
    """
    ## 0.1.0 / Unreleased
    """
    And the file "kitchen-qemu/Gemfile" should contain "gemspec"
    And the file "kitchen-qemu/Rakefile" should contain "task :stats"
    And the file "kitchen-qemu/README.md" should contain:
    """
    Kitchen::Qemu
    """
    And the file "kitchen-qemu/kitchen-qemu.gemspec" should contain:
    """
    require 'kitchen/driver/qemu_version'
    """
    And the file "kitchen-qemu/LICENSE" should contain:
    """
    Licensed under the Apache License, Version 2.0
    """
    And the file "kitchen-qemu/.gitignore" should contain:
    """
    Gemfile.lock
    """
    And the file "kitchen-qemu/.tailor" should contain:
    """
    config.file_set 'lib/**/*.rb'
    """
    And the file "kitchen-qemu/.travis.yml" should contain:
    """
    language: ruby
    """
    And a file named "kitchen-qemu/.cane" should exist
    And the file "kitchen-qemu/lib/kitchen/driver/qemu_version.rb" should contain:
    """
    QEMU_VERSION = "0.1.0.dev"
    """
    And the file "kitchen-qemu/lib/kitchen/driver/qemu.rb" should contain:
    """
    class Qemu < Kitchen::Driver::SSHBase
    """

  Scenario: Running with an alternate license
    When I successfully run `kitchen driver create foo --license=reserved`
    Then the file "kitchen-foo/LICENSE" should contain:
    """
    All rights reserved - Do Not Redistribute
    """
