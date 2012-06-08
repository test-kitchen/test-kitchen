@announce
Feature: Integration test Chef cookbook

In order to be able to confirm that my cookbook works on the chosen platforms
As a developer
I want to be able to integration test my Chef cookbook

  Scenario: No Kitchenfile
    Given a Chef cookbook with no integration test configuration
     When I run the integration tests with test kitchen
     Then the cookbooks default recipe will have been converged successfully
      And the tests will not have been run

  Scenario: Run cookbook integration tests
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

  Scenario: Cookbook has correctness problems
    Given a Chef cookbook that would fail a lint tool correctness check
      And the integration tests are defined in a Kitchenfile included with the cookbook
     When I run the integration tests with test kitchen
     Then an error indicating that there is a correctness problem with the cookbook will be shown
      And the tests will not have been run

  Scenario: Cookbook has style problems
    Given a Chef cookbook that would be flagged as having only style warnings by the lint tool
      And the integration tests are defined in a Kitchenfile included with the cookbook
     When I run the integration tests with test kitchen
     Then an error indicating that there is a correctness problem with the cookbook will not be shown
      And the tests will have been run
