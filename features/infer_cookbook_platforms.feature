Feature: Infer cookbook platforms

In order to remove the need to re-state the platforms that a cookbook supports
As a developer
I want to infer the platforms a cookbook should be tested against from the cookbook metadata

Note that currently this does not implement platform versions.

  Scenario: Supported platforms specified in metadata
    Given a Chef cookbook that defines a set of supported platforms literally in its metadata
     When I run the integration tests with test kitchen
     Then only the platforms specified in the metadata will be tested against
