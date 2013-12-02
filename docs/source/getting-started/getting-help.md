---
title: "Getting Help"
next:
  text: "Creating a Cookbook"
  url: "creating-cookbook"
---

If you need a quick reminder of what the `kitchen` command gives you, then use the **help** subcommand:

~~~
$ kitchen help
Commands:
  kitchen console                          # Kitchen Console!
  kitchen converge [(all|<REGEX>)] [opts]  # Converge one or more instances
  kitchen create [(all|<REGEX>)] [opts]    # Create one or more instances
  kitchen destroy [(all|<REGEX>)] [opts]   # Destroy one or more instances
  kitchen diganose [(all|<REGEX>)]         # Show computed diagnostic configuration
  kitchen driver                           # Driver subcommands
  kitchen driver create [NAME]             # Create a new Kitchen Driver gem project
  kitchen driver discover                  # Discover Test Kitchen drivers published on RubyGems
  kitchen driver help [COMMAND]            # Describe subcommands or one specific subcommand
  kitchen help [COMMAND]                   # Describe available commands or one specific command
  kitchen init                             # Adds some configuration to your cookbook so Kitchen can rock
  kitchen list [(all|<REGEX>)]             # List all instances
  kitchen login (['REGEX']|[INSTANCE])     # Log in to one instance
  kitchen setup [(all|<REGEX>)] [opts]     # Setup one or more instances
  kitchen test [all|<REGEX>)] [opts]       # Test one or more instances
  kitchen verify [(all|<REGEX>)] [opts]    # Verify one or more instances
  kitchen version                          # Print Kitchen's version information
~~~

For more detailed help on a given subcommand, add it to end of the **help** subcommand. For example, in the next section we will be using the **init** subcommand. To get a sneak peek of what this subcommand does, try:

~~~
$ kitchen help init
Usage:
  kitchen init

Options:
  -D, [--driver=one two three]     # One or more Kitchen Driver gems to be installed or added to a Gemfile
                                   # Default: kitchen-vagrant
  -P, [--provisioner=PROVISIONER]  # The default Kitchen Provisioner to use
                                   # Default: chef_solo
      [--create-gemfile]           # Whether or not to create a Gemfile if one does not exist. Default: false

Description:
  Init will add Test Kitchen support to an existing project for convergence integration testing. A default .kitchen.yml file (which is intended to be customized) is created in the
  project's root directory and one or more gems will be added to the project's Gemfile.
~~~
