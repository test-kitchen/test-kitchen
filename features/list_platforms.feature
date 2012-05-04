Feature: List platforms

In order to be able to define the platforms to test against
As a developer
I want to be able to list the platforms available for testing

  Scenario: List platforms
    Given a Chef cookbook
      And the integration tests are defined in a Kitchenfile included with the cookbook
     When I list the platforms
     Then the expected platforms will be available
