Feature: Listing Test Kitchen instances
  In order to understand how the .kitchen.yml is consumed
  As a user of Test Kitchen
  I want to run a command to see the state of my instances

  Background:
    Given a file named ".kitchen.yml" with:
    """
    ---
    driver: dummy
    provisioner: chef_solo

    platforms:
      - name: ubuntu-13.04
      - name: centos-6.4

    suites:
      - name: foobar
    """

  Scenario: Listing instances
    When I run `kitchen list`
    Then the exit status should be 0
    And the output should contain "foobar-ubuntu-1304"
    And the output should contain "foobar-centos-64"

  Scenario: Listing instances with the --bare option
    When I run `kitchen list --bare`
    Then the exit status should be 0
    And the output should contain exactly:
    """
    foobar-ubuntu-1304
    foobar-centos-64

    """

  Scenario: Listing instances with a simple regular expression glob
    When I successfully run `kitchen list ubun --bare`
    Then the output should contain exactly:
    """
    foobar-ubuntu-1304

    """

  Scenario: Listing instances with a Ruby regular expression glob, requiring
    signle quoting on the command line
    When I successfully run `kitchen list '^foo.*\-(10|13)04$' --bare`
    Then the output should contain exactly:
    """
    foobar-ubuntu-1304

    """

  @spawn
  Scenario: Listing instances with a regular expression yielding no results
    When I run `kitchen list freebsd --bare`
    Then the exit status should not be 0
    And the output should contain "No instances for regex `freebsd', try running `kitchen list'"

  @spawn
  Scenario: Listing instances with a bad regular expression
    When I run `kitchen list *centos* --bare`
    Then the exit status should not be 0
    And the output should contain "Invalid Ruby regular expression"
