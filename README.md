# Test Kitchen

[![Gem Version](https://badge.fury.io/rb/test-kitchen.svg)](http://badge.fury.io/rb/test-kitchen)
[![Build Status](https://dev.azure.com/test-kitchen/test-kitchen/_apis/build/status/test-kitchen.test-kitchen?branchName=main)](https://dev.azure.com/test-kitchen/test-kitchen/_build/latest?definitionId=6&branchName=main)

|             |                                                                                 |
| ----------- | --------------------------------------------------------------------------------|
| Website     | [https://kitchen.ci/][website]                                                  |
| Source Code | [https://kitchen.ci/docs/getting-started/introduction/][guide]                  |
| Slack       | [#test-kitchen][slack] channel on Chef Community Slack                          |

**Test Kitchen is an integration tool for developing and testing infrastructure code and software on isolated target platforms.**

## Getting Started Guide

To learn how to install and setup Test Kitchen for developing infrastructure
code, check out the [Getting Started Guide][guide].

If you want to get going super fast, then try the Quick Start next...

## Quick Start

Test Kitchen is a RubyGem and can be installed with:

```shell
gem install test-kitchen
```

If you use Bundler, you can add `gem "test-kitchen"` to your Gemfile and make
sure to run `bundle install`.

Next add support to your library, Chef cookbook, or empty project with `kitchen
init`:

```shell
kitchen init
```

A `kitchen.yml` file will be created in your project base directory. This file
describes your testing configuration; what you want to test and on which target
platforms. Each of these suite and platform combinations are called instances.
By default your instances will be converged with Chef Solo and run in Vagrant
virtual machines.

Get a listing of your instances with:

```shell
kitchen list
```

Run Chef Infra Client on an instance, in this case `default-ubuntu-2004`, with:

```shell
kitchen converge default-ubuntu-2004
```

Destroy all instances with:

```shell
kitchen destroy
```

You can clone a Chef Infra cookbook project that contains Test Kitchen support and
run through all the instances in serial by running:

```shell
kitchen test
```

## Usage

There is help included with the `kitchen help` subcommand which will list all
subcommands and their usage:

```shell
kitchen help test
```

More verbose logging for test-kitchen can be specified when running test-kitchen from the command line using:

```shell
kitchen test -l debug
```

For the provisioner (e.g. chef-solo or chef-infra) add a `log_level` item to the provisioner section of the `.kitchen.yml`
For more information on setting `log_level` see the [configuration documentation](https://kitchen.ci/docs/reference/configuration/).

## Documentation

Documentation is being added on the Test Kitchen [website][website]. Please
read and contribute to improve them!

## Versioning

Test Kitchen aims to adhere to [Semantic Versioning 2.0.0][semver].

## Community and Ecosystem

If you would like to see a few of the plugins or ecosystem helpers, please look at [ECOSYSTEM.md][ecosystem].

## Development

* Source hosted at [GitHub][repo]
* Report issues/questions/feature requests on [GitHub Issues][issues]

Pull requests are very welcome! Make sure your patches are well tested.
Ideally create a topic branch for every separate change you make. For
example:

1. Fork the repo
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Authors

Created by [Fletcher Nichol][fnichol] (<fnichol@nichol.ca>).

Maintained by Chef Software and a growing community of [contributors][contributors].

## License

Apache License, Version 2.0 (see [LICENSE][license])

[contributors]: https://github.com/test-kitchen/test-kitchen/graphs/contributors
[ecosystem]: https://github.com/test-kitchen/test-kitchen/blob/main/ECOSYSTEM.md
[fnichol]: https://github.com/fnichol
[guide]: https://kitchen.ci/docs/getting-started/introduction/
[issues]: https://github.com/test-kitchen/test-kitchen/issues
[license]: https://github.com/test-kitchen/test-kitchen/blob/main/LICENSE
[repo]: https://github.com/test-kitchen/test-kitchen
[semver]: https://semver.org/
[slack]: https://chefcommunity.slack.com/messages/testkitchen/details/
[website]: https://kitchen.ci/
