Feature: Running instance actions
  In order to trigger discrete instance lifecyle actions
  As an operator
  I want to run a action commands

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
  Scenario: Creating a single instance
    When I successfully run `kitchen list client-beans`
    Then the stdout should match /^client-beans\s+.+\s+\<Not Created\>\Z/
    When I run `kitchen create client-beans`
    Then the output should contain "Finished creating <client-beans>"
    And the exit status should be 0
    When I successfully run `kitchen list client-beans`
    Then the stdout should match /^client-beans\s+.+\s+Created\Z/

  @spawn
  Scenario: Creating a single instance that fails
    Given a file named ".kitchen.local.yml" with:
    """
    ---
    driver:
      fail_create: true
    """
    When I successfully run `kitchen list client-beans`
    Then the stdout should match /^client-beans\s+.+\s+\<Not Created\>\Z/
    When I run `kitchen create client-beans`
    Then the output should contain "Create failed on instance <client-beans>"
    And the exit status should not be 0
    When I successfully run `kitchen list client-beans`
    Then the stdout should match /^client-beans\s+.+\s+\<Not Created\>\Z/

  @spawn
  Scenario: Converging a single instance
    When I successfully run `kitchen create client-beans`
    And I successfully run `kitchen list client-beans`
    Then the stdout should match /^client-beans\s+.+\s+Created\Z/
    When I run `kitchen converge client-beans`
    Then the output should contain "Finished converging <client-beans>"
    And the exit status should be 0
    When I successfully run `kitchen list client-beans`
    Then the stdout should match /^client-beans\s+.+\s+Converged\Z/

  @spawn
  Scenario: Converging a single instance that fails
    Given a file named ".kitchen.local.yml" with:
    """
    ---
    driver:
      fail_converge: true
    """
    When I successfully run `kitchen create client-beans`
    And I successfully run `kitchen list client-beans`
    Then the stdout should match /^client-beans\s+.+\s+Created\Z/
    When I run `kitchen converge client-beans`
    Then the output should contain "Converge failed on instance <client-beans>"
    And the exit status should not be 0
    When I successfully run `kitchen list client-beans`
    Then the stdout should match /^client-beans\s+.+\s+Created\Z/

  @spawn
  Scenario: Setting up a single instance
    When I successfully run `kitchen converge client-beans`
    And I successfully run `kitchen list client-beans`
    Then the stdout should match /^client-beans\s+.+\s+Converged\Z/
    When I run `kitchen setup client-beans`
    Then the output should contain "Finished setting up <client-beans>"
    And the exit status should be 0
    When I successfully run `kitchen list client-beans`
    Then the stdout should match /^client-beans\s+.+\s+Set Up\Z/

  @spawn
  Scenario: Setting up a single instance that fails
    Given a file named ".kitchen.local.yml" with:
    """
    ---
    driver:
      fail_setup: true
    """
    When I successfully run `kitchen converge client-beans`
    And I successfully run `kitchen list client-beans`
    Then the stdout should match /^client-beans\s+.+\s+Converged\Z/
    When I run `kitchen setup client-beans`
    Then the output should contain "Setup failed on instance <client-beans>"
    And the exit status should not be 0
    When I successfully run `kitchen list client-beans`
    Then the stdout should match /^client-beans\s+.+\s+Converged\Z/

  @spawn
  Scenario: Verifying a single instance
    When I successfully run `kitchen setup client-beans`
    And I successfully run `kitchen list client-beans`
    Then the stdout should match /^client-beans\s+.+\s+Set Up\Z/
    When I run `kitchen verify client-beans`
    Then the output should contain "Finished verifying <client-beans>"
    And the exit status should be 0
    When I successfully run `kitchen list client-beans`
    Then the stdout should match /^client-beans\s+.+\s+Verified\Z/

  @spawn
  Scenario: Verifying a single instance that fails
    Given a file named ".kitchen.local.yml" with:
    """
    ---
    driver:
      fail_verify: true
    """
    When I successfully run `kitchen setup client-beans`
    And I successfully run `kitchen list client-beans`
    Then the stdout should match /^client-beans\s+.+\s+Set Up\Z/
    When I run `kitchen verify client-beans`
    Then the output should contain "Verify failed on instance <client-beans>"
    And the exit status should not be 0
    When I successfully run `kitchen list client-beans`
    Then the stdout should match /^client-beans\s+.+\s+Set Up\Z/

  @spawn
  Scenario: Destroying a single instance
    When I successfully run `kitchen create client-beans`
    And I successfully run `kitchen list client-beans`
    Then the stdout should match /^client-beans\s+.+\s+Created\Z/
    When I run `kitchen destroy client-beans`
    Then the output should contain "Finished destroying <client-beans>"
    And the exit status should be 0
    When I successfully run `kitchen list client-beans`
    Then the stdout should match /^client-beans\s+.+\s+\<Not Created\>\Z/

  @spawn
  Scenario: Destroying a single instance that fails
    Given a file named ".kitchen.local.yml" with:
    """
    ---
    driver:
      fail_destroy: true
    """
    When I successfully run `kitchen create client-beans`
    And I successfully run `kitchen list client-beans`
    Then the stdout should match /^client-beans\s+.+\s+Created\Z/
    When I run `kitchen destroy client-beans`
    Then the output should contain "Destroy failed on instance <client-beans>"
    And the exit status should not be 0
    When I successfully run `kitchen list client-beans`
    Then the stdout should match /^client-beans\s+.+\s+Created\Z/
