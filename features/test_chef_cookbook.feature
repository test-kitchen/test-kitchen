Feature: Integration test Chef cookbook

In order to be able to reproduceably test my cookbook
As a developer
I want to be able to integration test my Chef cookbook

  Scenario: Run coobook integration tests
    Given a Chef cookbook
      And the integration tests are defined in a Kitchenfile included with the cookbook
     When I run the integration tests with test kitchen
     Then the tests will have been run successfully

  Scenario: Malformed Kitchenfile
    Given a Chef cookbook
      And the integration tests are defined in a malformed Kitchenfile included with the project
     When I run the integration tests with test kitchen
     Then an error indicating that there is a problem with the configuration will be shown
      And the tests will not have been run

  Scenario: Cookbook has syntax errors
    Given a Chef cookbook with syntax errors
      And the integration tests are defined in a Kitchenfile included with the cookbook
     When I run the integration tests with test kitchen
     Then an error indicating that there is a problem with the cookbook syntax will be shown
      And the tests will not have been run
