Feature: Logging into a Kitchen instance
  In order to iterate, explore, and debug
  As a crafty developer
  I want to run a command that will give me a terminal session

  Background:
    Given a file named ".kitchen.yml" with:
    """
    ---
    driver:
      name: dummy

    transport:
      name: dummy

    provisioner:
      name: dummy

    platforms:
      - name: flebian

    suites:
      - name: default
      - name: full
    """
    And I successfully run `kitchen create default-flebian`

  @spawn
  Scenario: Logging in to an instance
    When I run `kitchen login default-flebian`
    Then the output should contain:
    """
    Remote login not supported in Kitchen::Transport::Dummy::Connection.
    """
    And the exit status should not be 0

  @spawn
  Scenario: Attempting to log into a non-created instance
    When I run `kitchen login full-flebian`
    Then the output should contain:
    """
    Instance <full-flebian> has not yet been created
    """
    And the exit status should not be 0

  @spawn
  Scenario: Attempting to log into a non-existent instance
    When I run `kitchen login nope`
    Then the output should contain "No instances for regex `nope'"
    And the exit status should not be 0

  @spawn
  Scenario: Attempting to log into an instance with an overly fuzzy match
    When I run `kitchen login flebian`
    Then the output should contain:
    """
    Argument `flebian' returned multiple results:
      * default-flebian
      * full-flebian
    """
    And the exit status should not be 0

