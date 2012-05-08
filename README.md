# Test Kitchen

Test Kitchen pulls together some of your favorite tools (Chef, Vagrant, Toft) to
make it easy to get started testing Chef cookbooks.

You define your test config in a `Kitchenfile` within your cookbook.

# Quick start

When you use test-kitchen your test config and the tests themselves live
along-side the cookbook within the cookbook repository. To get started, install
the test-kitchen gem. This makes available the `kitchen` command which is the
main way you will interact with test-kitchen. It is modelled closely on the
vagrant cli.

    $ gem install test-kitchen

Now you can ask test-kitchen to generate basic scaffolding to get you up and
running:

    $ cd my-existing-cookbook
    $ kitchen init

Even if you haven't yet got around to writing any tests, test-kitchen is still
useful in providing an easy way to test that your cookbook converges
successfully.

Run this command to converge your cookbook's default recipe:

    $ kitchen test

# Platforms

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

If you are using Vagrant/VirtualBox (the default) you'll notice that
test-kitchen doesn't tear down the VirtualBox VM between different platforms.
This is because a single VM is provisioned which then uses Linux Containers (via
Toft) to give you faster feedback.

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

Each configuration has a matching recipe in the *cookbook*_test subdirectory.
This recipe is responsible for doing the setup for the configuration tests.
For example in the case of mysql the server recipe will include the standard
`mysql::server` recipe but then also setup a dummy test database. The tests
that then exercise the service will be able to verify that mysql is working
correctly by running queries against the test database.

    mysql/
    +-- attributes
    +-- libraries
    +-- metadata.rb
    +-- recipes
    |   +-- client.rb
    |   +-- default.rb
    |   +-- server.rb
    +-- test
        +-- Gemfile
        +-- kitchen
            +-- Kitchenfile
            +-- cookbooks
                +-- mysql_test
                    +-- recipes
                        +-- client.rb
                        +-- server.rb

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
executing database queries. You might use Cucumber to implement these tests.
* You can also ignore the service functionality and make assertions about the
packages installed on the server and the file paths created. These tests are
normally less useful than the black box tests, but are easier to write. You
would probably use `MiniTest::Spec` to implement these tests.

* *<<< Add Cucumber feature example here >>>*
* *<<< Add MiniTest::Spec example here >>>*

# License
The test-kitchen project is licensed under the Apache License, Version 2.0.
Components used by test-kitchen are licensed under their own individual
licenses. See the accompanying
[LICENSE](https://github.com/opscode/test-kitchen/blob/master/LICENSE.md) file for
details.
