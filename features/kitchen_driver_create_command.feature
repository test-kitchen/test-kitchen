Feature: Create a new Test Kitchen Driver project
  In order to make plugin development a snap
  As a user of Test Kitchen
  I want a command to run that will give me a driver gem project scaffold

  Scenario: Displaying help
    When I run `kitchen help driver create`
    Then the output should contain:
    """
    Usage:
      kitchen driver create [NAME]
    """
    And the exit status should be 0
