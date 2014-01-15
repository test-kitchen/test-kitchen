Feature: Using Test Kitchen CLI help
  In order to access the self describing documentation
  As a user of Test Kitchen
  I want to run a command help help for kitchen commands

  @spawn
  Scenario: Printing help
    When I run `kitchen help`
    Then the exit status should be 0
    And the output should contain "kitchen help [COMMAND]"

  @spawn
  Scenario: Bad arugments should exit nonzero
    When I run `kitchen help -d always -c`
    Then the exit status should not be 0
    And the output should contain "Usage: "
