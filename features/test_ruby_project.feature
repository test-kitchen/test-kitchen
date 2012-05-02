Feature: Integration test Ruby project

In order to be able to reproduceably test my software in various configurations
As a developer
I want to be able to integration test generic Ruby projects

  Scenario: Basic Ruby project
    Given a Ruby project that uses bundler to manage its dependencies
      And the integration tests are defined in a Kitchenfile included with the project
     When I run the integration tests with test kitchen
     Then the tests will have been run successfully

  Scenario: Malformed Kitchenfile
    Given a Ruby project that uses bundler to manage its dependencies
      And the integration tests are defined in a malformed Kitchenfile included with the project
     When I run the integration tests with test kitchen
     Then an error indicating that there is a problem with the configuration will be shown
      And the tests will not have been run
