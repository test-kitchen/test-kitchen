# Test Kitchen

[![Build Status](https://secure.travis-ci.org/opscode/test-kitchen.png?branch=master)](https://travis-ci.org/opscode/test-kitchen)
[![Code Climate](https://codeclimate.com/github/opscode/test-kitchen.png)](https://codeclimate.com/github/opscode/test-kitchen)

A convergence integration test harness for configuration management systems.

# Getting started

Project Setup
-------------

Install the `test-kitchen` gem. `--pre` is necessary because Test Kitchen 1.0.0 has not been released yet.

```text
$ gem install test-kitchen --pre
```

This will expose the `test-kitchen` CLI. Run `kitchen init` to get started:

```text
$ kitchen init
      create  .kitchen.yml
```

In this guide, we
will be using the [kitchen vagrant driver](https://github.com/opscode/kitchen-vagrant),
so install that:

```text
$ gem install kitchen-vagrant
```

Open up the `.kitchen.yml` file created in the root of your
repository and modify it if you wish.

Now, it is time to get testing. Use the `--parallel` option to run
your tests in parallel. Trust us, it's faster!

    $ kitchen test

### Helpful Switches

 - `--destroy=always|passed|never`
   - `passed` (default): destroy the machine after a successful test
     run (which implies passing tests.)
   - `never`: Never clean up builds, even if they pass or fail.
   - `always`: Regardless of the success or failure of the build,
     destroy the machine.
 - `--log-level=debug|info|warn|error|fatal` - Set the log-level of
     the entire stack, including the chef-solo run. 

## The Kitchen YAML format

Test-Kitchen reads its configuration from the `.kitchen.yml`
configuration file at the root of your cookbook or module. It closely resembles
the format of `.travis.yml` which is intentional.

There are 5 stanzas in `.kitchen.yml`:

* `driver_plugin`
* `provisioner`
* `driver_config`
* `platforms`
* `suites`

The `driver_plugin`, `platforms`, and `suites` stanzas are currently all
required. The `driver_config` stanza can optionally be used to set
values for all platforms defined.

The `driver_plugin` stanza is only one line long and defines which
driver is used by Test-Kitchen.

The `provisioner` stanza is only one line long and defines which
configuration management tool a driver should use. It defines a
configuration value passed to the driver of `provisioner`. When
Test-Kitchen is initialized it detects if it is in a Chef cookbook or a
Puppet module and sets itself accordingly. Otherwise, it defaults to `chef`.

The `platforms` stanza defines individual virtual machines. Additional
`driver_config`, node attributes, and `run_list` can be defined in this stanza

The `suites` stanza defines sets of tests that you intend to be run on
each platform. A `run_list` and node attributes can be defined for each
suite. The `run_list` and node attributes will be merged with that of
each platform. In case of the conflict, the attributes defined on the
suite will triumph.

```yaml

---
driver_plugin: vagrant
provisioner: chef

platforms:
- name: ubuntu-12.04
  driver_config:
    box: opscode-ubuntu-12.04
    box_url: https://opscode-vm.s3.amazonaws.com/vagrant/boxes/opscode-ubuntu-12.04.box

- name: centos-6.3
  driver_config:
    box: opscode-centos-6.3
    box_url: https://opscode-vm.s3.amazonaws.com/vagrant/boxes/opscode-centos-6.3.box
  run_list:
  - recipe[yum::epel]

suites:
- name: stock_system_and_user
  run_list:
  - recipe[user::data_bag]
  - recipe[rvm::system]
  - recipe[rvm::user]
  attributes:
    users:
    - wigglebottom
    rvm:
      user_installs:
      - user: wigglebottom
        default_ruby: 1.8.7
```

## Overriding .kitchen.yaml with .kitchen.&lt;driver&gt;.local.yml

TODO

## A Note

This project is currently in rapid development which means frequent releases,
potential for massive refactorings (that could be API breaking), and minimal
to no documentation. This will change as the project transitions to be used in
production environments.

Despite the warnings above, if you are still interested, please get in touch
via freenode/IRC (#chef-hacking),
Twitter ([@fnichol](https://twitter.com/fnichol)),
or Email ([fnichol@nichol.ca](mailto:fnichol@nichol.ca)).

For everyone else, watch [this space](https://github.com/opscode/test-kitchen).
