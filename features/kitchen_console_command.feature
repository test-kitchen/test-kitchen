Feature: Running a console command
  In order to interactively explore Kitchen's internals and wiring
  As an opterator
  I want to run a command to launch an interactive console session

  Background:
    Given a file named ".kitchen.yml" with:
    """
    ---
    driver:
      name: dummy

    provisioner:
      name: dummy

    platforms:
      - name: flebian

    suites:
      - name: default
      - name: full
    """

  @spawn
  Scenario: Launching a session
    When I run `kitchen console` interactively
    And I type "instances.map { |i| i.name }"
    And I type "exit"
    Then the output should contain "kc(Kitchen::Config)> "
    Then the output should contain:
    """
    ["default-flebian", "full-flebian"]
    """
    And the exit status should be 0
