# Test Kitchen

[![Gem Version](https://badge.fury.io/rb/test-kitchen.svg)](http://badge.fury.io/rb/test-kitchen)
[![Build Status](https://secure.travis-ci.org/test-kitchen/test-kitchen.svg?branch=master)](https://travis-ci.org/test-kitchen/test-kitchen)
[![Code Climate](https://codeclimate.com/github/test-kitchen/test-kitchen.svg)](https://codeclimate.com/github/test-kitchen/test-kitchen)
[![Test Coverage](https://codeclimate.com/github/test-kitchen/test-kitchen/coverage.svg)](https://codeclimate.com/github/test-kitchen/test-kitchen)
[![Dependency Status](https://gemnasium.com/test-kitchen/test-kitchen.svg)](https://gemnasium.com/test-kitchen/test-kitchen)
[![Inline docs](http://inch-ci.org/github/test-kitchen/test-kitchen.svg?branch=master)](http://inch-ci.org/github/test-kitchen/test-kitchen)

|             |                                               |
|-------------|-----------------------------------------------|
| Website     | http://kitchen.ci                             |
| Source Code | http://kitchen.ci/docs/getting-started/       |
| IRC         | [#kitchenci][irc] channel on Freenode, [transcript][irc_log] thanks to [BotBot.me][botbotme] |
| Twitter     | [@kitchenci][twitter]                         |

> **Test Kitchen is an integration tool for developing and testing
> infrastructure code and software on isolated target platforms.**

## Getting Started Guide

To learn how to install and setup Test Kitchen for developing infrastructure
code, check out the [Getting Started Guide][guide].

If you want to get going super fast, then try the Quick Start next...

## Quick Start

Test Kitchen is a RubyGem and can be installed with:

```
$ gem install test-kitchen
```

If you use Bundler, you can add `gem "test-kitchen"` to your Gemfile and make
sure to run `bundle install`.

Next add support to your library, Chef cookbook, or empty project with `kitchen
init`:

```
$ kitchen init
```

A `.kitchen.yml` will be created in your project base directory. This file
describes your testing configuration; what you want to test and on which target
platforms. Each of these suite and platform combinations are called instances.
By default your instances will be converged with Chef Solo and run in Vagrant
virtual machines.

Get a listing of your instances with:

```
$ kitchen list
```

Run Chef on an instance, in this case `default-ubuntu-1204`, with:

```
$ kitchen converge default-ubuntu-1204
```

Destroy all instances with:

```
$ kitchen destroy
```

You can clone a Chef cookbook project that contains Test Kitchen support and
run through all the instances in serial by running:

```
$ kitchen test
```

## Usage

There is help included with the `kitchen help` subcommand which will list all
subcommands and their usage:

```
$ kitchen help test
```

More verbose logging for test-kitchen can be specified when running test-kitchen from the command line using:

```
$ kitchen test -l debug
```

For the provisioner (e.g. chef-solo or chef-zero) add a `log_level` item to the provisioner section of the `.kitchen.yml`
For more information see the Documentation.  This is a change since version 1.7.0

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
5. Create new Pull Request

## Authors

Created and maintained by [Fletcher Nichol][fnichol] (<fnichol@nichol.ca>) and
a growing community of [contributors][contributors].

## License

Apache License, Version 2.0 (see [LICENSE][license])

[botbotme]: https://botbot.me/
[contributors]: https://github.com/test-kitchen/test-kitchen/graphs/contributors
[fnichol]: https://github.com/fnichol
[guide]: http://kitchen.ci/docs/getting-started/
[irc]: http://webchat.freenode.net/?channels=kitchenci
[irc_log]: https://botbot.me/freenode/kitchenci/
[issues]: https://github.com/test-kitchen/test-kitchen/issues
[license]: https://github.com/test-kitchen/test-kitchen/blob/master/LICENSE
[repo]: https://github.com/test-kitchen/test-kitchen
[semver]: http://semver.org/
[twitter]: https://twitter.com/kitchenci
[website]: http://kitchen.ci
[ecosystem]: https://github.com/test-kitchen/test-kitchen/blob/master/ECOSYSTEM.md
