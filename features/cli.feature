Feature: Ensure that the Command Line Interface works as designed
  In order to test code via CLI
  As an Operator
  I want to run the CLI with different arguments

Scenario: Running the help command exits cleanly
  When I successfully run `kitchen help`
  Then the exit status should be 0
  And the output should contain "kitchen console"
  And a file named ".kitchen/logs/kitchen.log" should exist

Scenario: Show the version number
  When I successfully run `kitchen version`
  Then the exit status should be 0
