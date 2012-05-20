@announce
Feature: Configurations

In order to be able to test the full range of deployment options
As a developer
I want test my cookbook against multiple possible configurations that I define

  Scenario: No configurations
    Given a Chef cookbook that defines integration tests with no configurations specified
      And a supporting test cookbook that includes a default recipe
     When I run the integration tests with test kitchen
     Then the test cookbook default recipe will be converged once for each platform

  Scenario: Client and server configurations
    Given a Chef cookbook that defines integration tests for two configurations (client and server)
      And a supporting test cookbook that includes client and server recipes
     When I run the integration tests with test kitchen
     Then the test cookbook default recipe will not be converged
      And the test cookbook client and server recipes will be converged once for each platform

  Scenario: Missing test cookbook recipe
    Given a Chef cookbook that defines integration tests for two configurations (client and server)
      And a supporting test cookbook that includes only the server recipe
     When I run the integration tests with test kitchen
     Then the test cookbook default and server recipes will not be converged
      And an error indicating that the client configuration does not have a matching recipe will be shown
