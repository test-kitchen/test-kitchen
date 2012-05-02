@help
Feature: Command line help

In order to be able to determine the options available when performing integration testing
As a developer
I want to be able to view command line help

  Scenario: List commands (no Kitchenfile)
    Given a Ruby project that uses bundler to manage its dependencies
     When I view the command line help
     Then each of the expected kitchen subcommands will be shown

  Scenario: List commands
    Given a Ruby project that uses bundler to manage its dependencies
      And the integration tests are defined in a Kitchenfile included with the project
     When I view the command line help
     Then each of the expected kitchen subcommands will be shown

  Scenario: Test command help
    Given a Ruby project that uses bundler to manage its dependencies
      And the integration tests are defined in a Kitchenfile included with the project
     When I view command line help for the test sub-command
     Then the available options will be shown with a brief description of each
