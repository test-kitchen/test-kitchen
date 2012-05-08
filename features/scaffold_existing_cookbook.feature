Feature: Scaffold existing cookbook

In order to be able to confirm that my existing cookbook works on the chosen platforms
As a developer
I want to be able to quickly setup my existing cookbook for integration testing

  Scenario: Existing cookbook
    Given an existing Chef cookbook with no tests defined
     When I scaffold the integration tests
      And I run the integration tests with test kitchen
     Then the existing cookbook will have been converged
