Test Kitchen is a framework for running project integration tests in
an isolated environment using Vagrant and/or OpenStack and Chef. You describe the
configuration for testing your project using a lightweight Ruby DSL.

We use Vagrant baseboxes built with [Bento](https://github.com/opscode/bento),
OpenStack users may choose by their OpenStack 'image_id'.

# Quick Start

When you use test-kitchen your test config and the tests themselves live
along-side the cookbook within the cookbook repository. To get started, install
the test-kitchen gem. This makes available the `kitchen` command which is the
main way you will interact with test-kitchen. It is modeled loosely on the
vagrant cli.

    $ gem install test-kitchen

Now you can ask test-kitchen to generate basic scaffolding to get you up and
running:

    $ cd my-existing-cookbook
    $ kitchen init

Run this command to converge your cookbook's default recipe:

    $ kitchen test

# What does it do?

Test kitchen runs through several different kinds of tests, depending on the
configuration.

First, it does a syntax check using `knife cookbook test`. This does require a
valid knife.rb with the cache path for the checksums stored by the syntax checker.

Second, it performs a lint check using [foodcritic](http://acrmp.github.com/foodcritic),
and will fail and exit if any correctness checks fail.

For cookbook projects, it provisions a VM and runs the default recipe or recipes
set as "configurations" (see below) in the Kitchenfile to ensure it can be
converged. If a cookbook has minitest-chef tests, it will run those as well. If
the cookbook has declared dependencies in the metadata, test-kitchen uses
[Librarian](https://github.com/applicationsonline/librarian) to resolve those
dependencies. Support for [Berkshelf](http://berkshelf.com) is
[pending](http://tickets.opscode.com/browse/KITCHEN-9)

For integration_test projects, it provisions a VM and runs the integration tests
for the project, by default "rspec spec".

In either cookbook or integration_test projects, if a "features" directory exists,
test-kitchen will attempt to run those tests using cucumber.

All this is configurable, see the DSL section below.

# Platforms

Even if you haven't yet got around to writing any tests, test-kitchen is still
useful in providing an easy way to test that your cookbook converges
successfully on a variety of platforms.

Test-kitchen looks at your cookbook's `metadata.rb` file to see which platforms
you have indicated that it should support.

For example your cookbook metadata might contain the following lines:

```ruby
supports 'centos'
supports 'ubuntu'
```

This says to Chef that you expect your cookbook to work on both CentOS and
Ubuntu. When you run `kitchen test`, test-kitchen consults this metadata and
will test your cookbook against these platforms only.

If your cookbook doesn't specify the platforms that it supports then it will be
tested against all platforms supported by test-kitchen. Alternatively if you
have specified a platform that test-kitchen doesn't yet support a warning
message will be displayed.

# Configurations

Very often you will want to test different independent usages or
*configurations* of your cookbook. An example would be a cookbook like the
`mysql` cookbook which has `client` and `server` recipes. These need to be
converged separately to prove that they will work independently. If you only
converged them both on the same node you might find that the `client` recipe
unexpectedly relied on a resource declared by the `server` recipe.

You need to tell test-kitchen what the different configurations are that you
want your cookbook tested with. To do this we edit the generated
`test/kitchen/Kitchenfile` and define our configurations:

```ruby
cookbook "mysql" do
  configuration "client"
  configuration "server"
end
```

Each configuration optionally has a matching recipe in the *cookbook*_test
subdirectory:

    mysql/test/kitchen/cookbooks/mysql_test/recipes/client.rb
    mysql/test/kitchen/cookbooks/mysql_test/recipes/server.rb

This recipe is responsible for doing the setup for the configuration tests.
For example in the case of mysql the server recipe will include the standard
`mysql::server` recipe but then also setup a dummy test database. The tests
that then exercise the service will be able to verify that mysql is working
correctly by running queries against the test database.

## Testing a single configuration only

To run the tests for a single configuration only specify the configuration
on the command line:

    $ kitchen test --configuration my_configuration

## Excluding platforms and configurations

If you know that a certain configuration is not expected to work on a platform
you can choose to `exclude` it from the build:

```ruby
cookbook "mysql" do
  configuration "client"
  configuration "server"

  # we only want to test amazon against the client configuration
  exclude :platform => 'amazon', :configuration => 'server'

  # we don't want to test freebsd at all even though it's in the metadata
  exclude :platform => 'freebsd'
end
```

# Adding Tests

As we saw above, there is a lot of value in just converging your cookbooks
against the platforms that they should support. However to really get the
benefits of test-kitchen you should write tests that make assertions about the
converged node. Test-kitchen will by default look for these tests and run them
if they are present.

You can add these tests at two levels:

* You can test the converged node as a 'black box' - that is you can test that
the node provides a service that you expect to be available, without looking at
how that service was implemented. This is necessarily service-specific - for
our MySQL example this would mean connecting to the running database and
executing database queries. If you add a `features` directory with Cucumber
features underneath the kitchen directory then test-kitchen will run these
after converge to verify the service behaviour.

* You can also ignore the service functionality and make assertions about the
state of the server (packages installed on the server and the file paths
created). These tests are normally less useful than the black box tests, but are
probably easier to get started with if you haven't written tests before. If you
use minitest-chef-handler then your `MiniTest::Spec` examples will be run
following the converge in the report handler phase of the Chef run.

## Cucumber Examples

Here's an example feature for our MySQL cookbook:

    @server
    Feature: Query database

    In order to persist and retrieve my application data
    As a developer
    I want to be able to query the database

      Scenario: Query database
        Given a new database server with some example data
         When I query the database
         Then the expected data should be returned

The `@server` tag at the top of the feature specifies that this feature is
associated with the `server` configuration. Test Kitchen will run any features
in the `test/features` subdirectory tagged with the configuration name
in order to check that the service is working as expected.

In this case, after converging MySQL, we are going to check that we can query
the database and get back the data that we expect. For a webserver we would
check that the default webserver page was available.

Writing our examples in plain english means that Chef users who know
_just-enough-ruby_ are able to quickly see what functionality our cookbook
should support, without having to wade through the actual test code.

## Test Setup

Frequently you will want to do some additional setup in order to be able to
adequately test your cookbook. For example the scenario above assumes that
the test database and example data have been created.

To do this you can create a test cookbook at
`mysql/test/kitchen/cookbooks/mysql_test/`. Each configuration has a matching
test recipe of the same name where you can perform any necessary setup.

## MiniTest

Any minitest-chef-handler tests placed in `files/default/tests/minitest` within
your cookbook will be run as the final part of the converge in the exception
and reporting handler phase. You can use these to check that the expected
resources were actually created.

For our MySQL example this looks like:

```ruby
describe 'mysql::server' do
  it 'runs as a daemon' do
    service(node['mysql']['service_name']).must_be_running
  end
end
```

Matchers are [available for most resource types](https://github.com/calavera/minitest-chef-handler/blob/master/examples/spec_examples/files/default/tests/minitest/example_test.rb).

# Kitchenfile DSL

The Kitchenfile has a relatively lightweight Ruby domain-specific
language that allows you to describe various aspects of how your
project should be tested.

## platform

Use a platform block to describe the versions of a particular platform
that should be tested.

`platform` - This is the name of the platform, with a block containing
its versions. Each platform named must match a platform in Chef
(e.g. centos, ubuntu, debian, etc) and can be specified as a string or
a symbol.

`version` - Specify one or more versions for the platform, with a
block containing the name of the box and the URL where the box can be
downloaded.

`chef_attributes` - Pass a JSON string containing attributes to be used
for the platform and version. If you pass
```
chef_attributes '{"apt": { "cacher_ipaddress": "10.0.111.3" }}'
```
this will be utilized by the `apt::cacher-client` recipe included in the
`test-kitchen` recipe.

`box` - This is the name of the Vagrant box that should should be used
for the platform and version.

`box_url` - This is the URL to the base box file to use for the box
for this platform and version.

`image_id` - The OpenStack image id to use for this platform and
version. (OpenStack runner only, required)

`flavor_id` - The instance flavor to start for this platform and
version. (OpenStack runner only, required)

`keyname` - The OpenStack keyname that should be placed on the
VM. (OpenStack runner only)

`instance_name` - Custom instance name for the this OpenStack
instance. (OpenStack runner only)

`install_chef` - Boolean that controls whether Chef should be
installed on the VM before convergence. Defaults to false. (OpenStack runner
only)

`install_chef_cmd` - Command to install Chef with if `install_chef` is
true. Defaults to an omnibus installation using curl. (OpenStack runner only)

`ssh_user` - User to authenticate with during remote commands. Defaults to
'root' (OpenStack runner only)

`ssh_key` - Path to the ssh private key to authenticate with during
remote commands.  If unset, the ssh-agent will be used if available. (OpenStack
runner only)

### Platform Example

```ruby
platform :centos do
  version "5.8" do
    box "opscode-centos-5.8"
    box_url "https://opscode-vm.s3.amazonaws.com/vagrant/boxes/opscode-centos-5.8.box"
  end
end
```

## cookbook

Describe the configurations that test-kitchen should run for a
cookbook project in a `cookbook` block.

`cookbook` - The name of the cookbook to test, with a block containing
additional project configuration.

`configuration` - Specify one or more configurations as a string. See
the [configurations section](#configurations)

`lint` - Specify whether to perform lint checking with foodcritic with
a boolean. Can also specify a list of tags to ignore, see example.

`exclude` - Exclude a configuration from a particular platform passing
it a hash with the platforms and configuration to exclude. See example
below.

`memory` - Specify an amount of memory in megabytes as an integer. The default
is 256.

`run_list_extras` - Additional recipes that are required in order to
run the tests. Create these cookbooks in `test/kitchen/cookbooks`.

`preflight_command` - The command to run before provisioning the
tests, by default this is `knife cookbook test` and `foodcritic` for
the cookbook being tested.

`script` - A script to use for running spec tests. Defaults to `rspec spec`.

`runtimes` - An array of Ruby runtime versions to run tests (features,
specs) under. This uses RVM, and that must be installed and available.
At this time, that is assumed to be in the base box. The default for
cookbook projects is `[]`, which effectively disables spec/feature
tests. Set to the Ruby versions installed in your custom base box
under RVM.

`data_bags_path` - Specify the directory containing data bags to make available
to the `:chef_solo` Vagrant provisioner. Defaults to `test/kitchen/data_bags`.
See: [Using Data Bags with Chef Solo](http://wiki.opscode.com/display/chef/Data+Bags#DataBags-UsingDataBagswithChefSolo)
for more information.

### Cookbook Examples

Excerpt from Opscode's apache2 cookbook Kitchenfile:

```ruby
cookbook "apache2" do
  configuration "default"
  configuration "basic_web_app"
  configuration "mod_authnz_ldap"
  configuration "mod_ssl"
  exclude :platform => 'centos', :configuration => 'mod_authnz_ldap'
  run_list_extras ['apache2_test::setup']
end
```

Disable lint checking for the zsh cookbook:

```ruby
cookbook "zsh" do
  lint false
end
```

Ignore certain foodcritic rules in the lint check, which must pass in
an array. For example to ignore the ["prefer strings over symbols"](http://acrmp.github.com/foodcritic/#FC001)
and ["check for solo"](http://acrmp.github.com/foodcritic/#FC003) rules:

```ruby
cookbook "mycookbook" do
  lint(:ignore => ["FC001", "FC003"])
end
```

To ignore just the "prefer strings over symbols rule", it still needs
to be an array at this time.

```ruby
cookbook "mycookbook" do
  lint(:ignore => ["FC001"])
end
```

## integration\_test

Describe how to perform integration tests for an arbitrary software
project with an `integration_test` block.

`integration_test` - The name of the project to test with a block of
additional configuration for how to run the test(s).

`language` - The language of the project.

`install` - The command to install the requirements to run the test.

`specs` - Specify whether to run specs with `true` or `false`, default `true`.

`features` - Specify whether to run features with `true` or `false`, default `true`.

`script` - A shell script used to run the tests.

`runtimes` - An array of Ruby runtime versions to run tests (features,
specs) under. This uses RVM, and that must be installed and available.
At this time, that is assumed to be in the base box.

### Integration Test Example

```ruby
integration_test "mixlib-shellout" do
  language "ruby"
  install "bundle install"
  specs true
  features false
end
```

## openstack

Describes global configuration settings for the OpenStack runner:

`username` - The OpenStack username with which to authenticate.

`password` - The OpenStack password for the given username.

`tenant` - The OpenStack tenant to authenticate against.

`auth_url` - The URL of your OpenStack installations keystone server.

`floating_ip` - Whether or not to request a floating IP, default is 'false'.

### OpenStack example

```ruby
openstack do
  auth_url "http://172.0.0.100:5000/v2.0/tokens"
  username "bobby"
  password "p4ssw0rd"
  tenant "openstack"
end
```

## default_runner

The default_runner option allows you to specify the runner to use in
the absence of the `--runner` flag.  The available runners are currently
'vagrant' and 'openstack'.  The default is 'vagrant'

```ruby
default_runner 'openstack'
```

# Bugs and Issues

Use the
[issue tracker](http://tickets.opscode.com/browse/KITCHEN) to
report bugs, features or other issues.

# Contributing

[How to contribute to Opscode open source software projects](http://wiki.opscode.com/display/chef/How+to+Contribute)

# License and Author

Author:: Andrew Crump (<andrew@kotirisoftware.com>)
Author:: Seth Chisamore (<schisamo@opscode.com>)

Copyright:: 2012, Opscode, Inc. (<legal@opscode.com>)

License:: Apache License, Version 2.0

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

[http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0)

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

Components used by test-kitchen are licensed under their own individual
licenses. See the accompanying
[LICENSE](https://github.com/opscode/test-kitchen/blob/master/LICENSE.md) file for
details.
