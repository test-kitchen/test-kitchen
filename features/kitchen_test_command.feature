Feature: Running a full test instance test
  In order to "fire-and-forget" or run help setup a CI job
  As an operator or CI script
  I want to run a command that will fully test one or more instances

  Background:
    Given a file named ".kitchen.yml" with:
    """
    ---
    driver:
      name: dummy

    provisioner:
      name: dummy

    platforms:
      - name: cool
      - name: beans

    suites:
      - name: client
      - name: server
    """

  @spawn
  Scenario: Running a single instance
    When I run `kitchen test client-beans`
    Then the output should contain "Starting Kitchen"
    Then the output should contain "Cleaning up any prior instances of <client-beans>"
    Then the output should contain "Testing <client-beans>"
    Then the output should contain "Finished testing <client-beans>"
    Then the output should contain "Kitchen is finished."
    And the exit status should be 0

  @spawn
  Scenario: Running a single instance never destroying an instance
    When I successfully run `kitchen test client-beans --destroy=never`
    And I successfully run `kitchen list client-beans`
    Then the output should match /^client-beans\s+.+\s+Verified\s+\<None\>$/

  @spawn
  Scenario: Running a single instance always destroying an instance
    Given a file named ".kitchen.local.yml" with:
    """
    ---
    provisioner:
      fail: true
    """
    When I run `kitchen test client-beans --destroy=always`
    Then the exit status should not be 0
    When I successfully run `kitchen list client-beans`
    Then the output should match /^client-beans\s+.+\s+\<Not Created\>\s+\<None\>$/

  @spawn
  Scenario: Running a single instance not destroying an instance on failure
    Given a file named ".kitchen.local.yml" with:
    """
    ---
    provisioner:
      fail: true
    """
    When I run `kitchen test client-beans --destroy=passing`
    Then the exit status should not be 0
    When I successfully run `kitchen list client-beans`
    Then the output should match /^client-beans\s+.+\s+Created\s+Kitchen::ActionFailed$/

  @spawn
  Scenario: Running a single instance destroying an instance on success
    When I run `kitchen test client-beans --destroy=passing`
    Then the exit status should be 0
    When I successfully run `kitchen list client-beans`
    Then the output should match /^client-beans\s+.+\s+\<Not Created\>\s+\<None\>$/

  @spawn
  Scenario: Running all instances
    When I run `kitchen test`
    Then the output should contain "Starting Kitchen"
    Then the output should contain "Finished testing <client-cool>"
    Then the output should contain "Finished testing <client-beans>"
    Then the output should contain "Finished testing <server-cool>"
    Then the output should contain "Finished testing <server-beans>"
    Then the output should contain "Kitchen is finished."
    And the exit status should be 0
    When I successfully run `kitchen list`
    Then the output should match /^client-cool\s+.+\s+\<Not Created\>\s+\<None\>$/
    Then the output should match /^client-beans\s+.+\s+\<Not Created\>\s+\<None\>$/
    Then the output should match /^server-cool\s+.+\s+\<Not Created\>\s+\<None\>$/
    Then the output should match /^server-beans\s+.+\s+\<Not Created\>\s+\<None\>$/
