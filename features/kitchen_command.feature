Feature: A command line interface for Test Kitchen
  In order to provide a quick and response development workflow
  As a Test Kitchen user
  I want a command line interface that has sane defaults and built in help

  @spawn
  Scenario: Displaying help
    When I run `kitchen help`
    Then the exit status should be 0
    And the output should contain "kitchen console"
    And the output should contain "kitchen version"

  Scenario: Displaying the version of Test Kitchen
    When I run `kitchen version`
    Then the exit status should be 0
    And the output should contain "Test Kitchen version"
