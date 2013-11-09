---
title: Installing Test Kitchen
---

Installing Test Kitchen
=======================
Test Kitchen is distributed as a Ruby gem. To get started, install the gem from Rubygems:

```text
$ gem install test-kitchen
```

Or, if you are using Bundler, we recommend adding the `test-kitchen` gem to your cookbook's `Gemfile`:

```ruby
gem 'test-kitchen', '~> 1.0'
```

And then run the `bundle` command to install:

```bash
$ bundle install
```

Test Kitchen includes a command line utility "`kitchen`". Bootstrap your cookbook using the `kitchen init` command from inside your Chef cookbook:

```bash
$ kitchen init
      create  .kitchen.yml
      create  test/integration/default
         run  gem install kitchen-vagrant from "."
```

By default, Test Kitchen will use the Vagrant driver. For more information on Test Kitchen drivers, please see the [Test Kitchen Driver]() documentation.

Examine the `.kitchen.yml` file created in the root of your Chef cookbook. This file defines the driver configuration, platforms, and test suites to execute.

```yaml
driver_plugin: vagrant
driver_config:
  require_chef_omnibus: true

platforms:
  - name: ubuntu-12.04

suites:
  - name: default
    run_list:
      - recipe[bacon::default]
```

See the [Configuration]() section for more information on the `.kitchen.yml` and other configuration options. For now, we can just use the default values
