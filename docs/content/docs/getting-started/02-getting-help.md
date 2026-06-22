---
title: "Getting Help"
slug: getting-help
menu:
  docs:
    parent: getting_started
    weight: 20
---

Use the `kitchen help` for a quick reminder of what the `kitchen` command provides:

```ruby
$ kitchen help
Commands:
  kitchen console                                 # Test Kitchen Console!
  kitchen converge [INSTANCE|REGEXP|all]          # Change instance state to converge. Use a provisioner to configure one or more instances
  kitchen create [INSTANCE|REGEXP|all]            # Change instance state to create. Start one or more instances
  kitchen destroy [INSTANCE|REGEXP|all]           # Change instance state to destroy. Delete all information for one or more instances
  kitchen diagnose [INSTANCE|REGEXP|all]          # Show computed diagnostic configuration
  kitchen doctor INSTANCE|REGEXP                  # Check for common system problems
  kitchen exec INSTANCE|REGEXP -c REMOTE_COMMAND  # Execute command on one or more instance
  kitchen help [COMMAND]                          # Describe available commands or one specific command
  kitchen init                                    # Adds some configuration to your cookbook so Kitchen can rock
  kitchen list [INSTANCE|REGEXP|all]              # Lists one or more instances
  kitchen login INSTANCE|REGEXP                   # Log in to one instance
  kitchen package INSTANCE|REGEXP                 # package an instance
  kitchen setup [INSTANCE|REGEXP|all]             # Change instance state to setup. Prepare to run automated tests. Install busser and related gems on one or more instances
  kitchen test [INSTANCE|REGEXP|all]              # Test (destroy, create, converge, setup, verify and destroy) one or more instances
  kitchen verify [INSTANCE|REGEXP|all]            # Change instance state to verify. Run automated tests on one or more instances
  kitchen version                                 # Print Test Kitchen's version information
```

For more detailed information about a specific subcommand, append its name to the `help` command. For example, the `kitchen diagnose` subcommand is especially useful for visualizing Test Kitchen's configuration layers and troubleshooting issues.

```ruby
$ kitchen help diagnose
Usage:
  kitchen diagnose [INSTANCE|REGEXP|all]

Options:
      [--loader], [--no-loader]                # Include data loader diagnostics
      [--plugins], [--no-plugins]              # Include plugin diagnostics
      [--instances], [--no-instances]          # Include instances diagnostics
                                               # Default: true
      [--all], [--no-all]                      # Include all diagnostics
  -l, [--log-level=LOG_LEVEL]                  # Set the log level (debug, info, warn, error, fatal)
      [--log-overwrite], [--no-log-overwrite]  # Set to false to prevent log overwriting each time Test Kitchen runs
      [--color], [--no-color]                  # Toggle color output for STDOUT logger
  -t, [--test-base-path=TEST_BASE_PATH]        # Set the base path of the tests

Show computed diagnostic configuration
```

Remember, you can also ask for assistance in the [Chef Community Slack](https://community.chef.io/slack) `#test-kitchen` channel where community members can help answer questions.

<div class="sidebar--footer">
<a class="button primary-cta" href="/docs/getting-started/creating-cookbook">Next - Creating a Cookbook</a>
<a class="sidebar--footer--back" href="/docs/getting-started/installing">Back to previous step</a>
</div>
