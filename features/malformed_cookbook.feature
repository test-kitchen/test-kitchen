@announce
Feature: Don't integration test a malformed cookbook

In order to be able to confirm that my cookbook works on the chosen platforms
As a developer
I want to fail quickly if the cookbook is malformed

  Scenario: Cookbook has syntax errors
    Given a Chef cookbook with syntax errors
      And the integration tests are defined in a Kitchenfile included with the cookbook
     When I run the integration tests with test kitchen
     Then an error indicating that there is a problem with the cookbook syntax will be shown
      And the tests will not have been run
