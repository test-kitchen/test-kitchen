Feature: The `kitchen sink` command
  In order to have fun and provide an Easter Egg for users
  As a Test Kitchen user
  I want a `sink` command that displays ASCII art

  Scenario: Displaying help
    When I run `kitchen help`
    Then the exit status should be 0
    And the output should not contain "kitchen sink"

  Scenario: Displaying the sink
    When I run `kitchen sink`
    Then the exit status should be 0
    And the output should contain:
      """
                          ___
                         ' _ '.
                       / /` `\ \
                       | |   [__]
                       | |    {{
                       | |    }}
                    _  | |  _ {{
        ___________<_>_| |_<_>}}________
            .=======^=(___)=^={{====.
           / .----------------}}---. \
          / /                 {{    \ \
         / /                  }}     \ \
        (  '========================='  )
         '-----------------------------'
      """
