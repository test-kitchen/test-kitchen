Feature: Integration test Chef cookbook

In order to be able to reproduceably test my cookbook
As a developer
I want to be able to integration test my Chef cookbook

  Scenario: Cookbook
    Given a Chef cookbook
      And the integration tests are defined in a Kitchenfile included with the cookbook
     When I run the integration tests with test kitchen
     Then the tests will have been run successfully
