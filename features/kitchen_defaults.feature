Feature: Test Kitchen defaults
  In order to have a more pleasant out of the box experience
  As a user of Test Kitchen
  I want to have some common defaults handled for me

  Scenario: Windows platforms get the Winrm Transport by default
    Given a file named ".kitchen.yml" with:
    """
    ---
    driver: dummy
    provisioner: dummy
    verifier: dummy

    platforms:
      - name: win-8.1

    suites:
      - name: default
    """
    When I successfully run `kitchen list`
    Then the output should match /^default-win-81\s+Dummy\s+Dummy\s+Dummy\s+Winrm\s+\<Not Created\>\s+\<None\>$/

  Scenario: Non-Windows platforms get the Ssh Transport by default
    Given a file named ".kitchen.yml" with:
    """
    ---
    driver: dummy
    provisioner: dummy
    verifier: dummy

    platforms:
      - name: ubuntu-14.04

    suites:
      - name: default
    """
    When I successfully run `kitchen list`
    Then the output should match /^default-ubuntu-1404\s+Dummy\s+Dummy\s+Dummy\s+Ssh\s+\<Not Created\>\s+\<None\>$/
