Feature: Running a diagnosis command
  In order to understand how Kitchen is wired together
  As an operator and configuration sleuth
  I want to run a command to get configuration information

  Background:
    Given a file named ".kitchen.yml" with:
    """
    ---
    driver:
      name: dummy

    provisioner:
      name: dummy

    transport:
      name: dummy

    verifier:
      name: dummy

    platforms:
      - name: cool
      - name: beans

    suites:
      - name: client
      - name: server
    """

  @spawn
  Scenario: Displaying help
    When I run `kitchen help diagnose`
    Then the output should contain:
    """
    Usage:
      kitchen diagnose
    """
    And the exit status should be 0

  @spawn
  Scenario: Showing all instances
    When I run `kitchen diagnose`
    Then the output should contain "timestamp: "
    Then the output should contain "kitchen_version: "
    Then the output should contain "  client-cool:"
    Then the output should contain "  client-beans:"
    Then the output should contain "  server-cool:"
    Then the output should contain "  server-beans:"
    And the exit status should be 0

  @spawn
  Scenario: Showing all instances with loader configuration
    When I run `kitchen diagnose --loader`
    Then the output should contain:
    """
    loader:
      process_erb: true
      process_local: true
      process_global: true
    """
    And the exit status should be 0

  @spawn
  Scenario: Showing all instances with plugin configuration
    When I run `kitchen diagnose --plugins`
    Then the output should contain "plugins:"
    Then the output should contain "    class: Kitchen::Driver::Dummy"
    Then the output should contain "    class: Kitchen::Provisioner::Dummy"
    Then the output should contain "    class: Kitchen::Transport::Dummy"
    Then the output should contain "    class: Kitchen::Verifier::Dummy"
    And the exit status should be 0

  @spawn
  Scenario: Coping with loading failure
    Given a file named ".kitchen.local.yml" with:
    """
    I'm a little teapot
    """
    When I run `kitchen diagnose --all`
    Then the output should contain:
    """
        raw_data:
          error:
    """
    And the output should contain:
    """
    instances:
      error:
    """
    And the output should contain:
    """
    plugins:
      error:
    """
    And the exit status should be 0
