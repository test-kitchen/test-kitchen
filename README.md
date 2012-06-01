# Test Kitchen

Test Kitchen pulls together some of your favorite tools to make it easy to get
started testing Chef cookbooks.

You define your test config in a `Kitchenfile` within your cookbook.

# Quick start

When you use test-kitchen your test config and the tests themselves live
along-side the cookbook within the cookbook repository. To get started, install
the test-kitchen gem. This makes available the `kitchen` command which is the
main way you will interact with test-kitchen. It is modelled loosely on the
vagrant cli.

    $ gem install test-kitchen

Now you can ask test-kitchen to generate basic scaffolding to get you up and
running:

    $ cd my-existing-cookbook
    $ kitchen init

Run this command to converge your cookbook's default recipe:

    $ kitchen test

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

Each configuration has a matching recipe in the *cookbook*_test subdirectory:

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

    describe 'mysql::server' do
      it 'runs as a daemon' do
        service(node['mysql']['service_name']).must_be_running
      end
    end

Matchers are [available for most resource types](https://github.com/calavera/minitest-chef-handler/blob/master/examples/spec_examples/files/default/tests/minitest/example_test.rb).

# License
The test-kitchen project is licensed under the Apache License, Version 2.0.
Components used by test-kitchen are licensed under their own individual
licenses. See the accompanying
[LICENSE](https://github.com/opscode/test-kitchen/blob/master/LICENSE.md) file for
details.
