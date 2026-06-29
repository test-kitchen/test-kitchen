Feature: Showing Test Kitchen logs
  In order to inspect live and historical instance output
  As a Test Kitchen user
  I want structured logs to be available in text and NDJSON formats

  Background:
    Given a file named ".kitchen.yml" with:
    """
    ---
    driver:
      name: dummy

    provisioner:
      name: dummy

    verifier:
      name: dummy

    platforms:
      - name: ubuntu-24.04

    suites:
      - name: default
    """
    And a file named ".kitchen/logs/default-ubuntu-2404.ndjson" with:
    """
    {"level":"debug","message":"debug detail","instance_session_id":"session-current"}
    {"level":"info","message":"booting","instance_session_id":"session-current"}
    {"level":"warn","message":"package cache stale","instance_session_id":"session-current"}
    {"level":"error","message":"converge failed","instance_session_id":"session-current"}
    """

  Scenario: Showing all session logs as text by default
    When I run `kitchen logs --all-sessions --level warn`
    Then the exit status should be 0
    And the output should contain exactly:
    """
    package cache stale
    converge failed

    """

  Scenario: Showing all session logs as NDJSON when requested
    When I run `kitchen logs --all-sessions --format ndjson --level warn`
    Then the exit status should be 0
    And the output should contain exactly:
    """
    {"level":"warn","message":"package cache stale","instance_session_id":"session-current"}
    {"level":"error","message":"converge failed","instance_session_id":"session-current"}

    """
