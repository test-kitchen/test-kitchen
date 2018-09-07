---
title: Writing a Test
slug: writing-test
menu:
  docs:
    parent: getting_started
    weight: 90
---

Being able to manually verify the Chef run is great but it would be even better if we had an executable test that would fail if our assumptions were ever proven to be false. Remember how we manually verified that Git was installed in the previous section? Seems like a pretty decent first test to me!

Kitchen presumes you want to test things and supports a variety of different frameworks for doing so. For the purpose of our guide we're going to use a framework called InSpec which kitchen consumes via the `kitchen-inspec` plugin. For more information on available testing frameworks check out [Verifiers](/docs/verifiers)

The cookbook skeleton already has conveniently created a test for you at `test/smoke/default/default_test.rb`. Open this file in your editor and edit to match the following content:

~~~
# # encoding: utf-8

# Inspec test for recipe git_cookbook::default

# The Inspec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/

describe package('git') do
  it { should be_installed }
end
~~~

Why `test/smoke/default/default_test.rb`? Let's take a look again at our `.kitchen.yml`:

~~~
# relevant sections of config
---
verifier:
  name: inspec

suites:
  - name: default
    run_list:
      - recipe[git_cookbook::default]
    verifier:
      inspec_tests:
        - test/smoke/default
    attributes:
~~~

Here we are telling the verifier with the `inspec_tests` key to look in this directory. In our example we are pointing to a local directory but `kitchen-inspec` supports [remote locations](https://github.com/chef/kitchen-inspec#use-remote-inspec-profiles) such as git repositories or even a Chef Automate server.

Can you guess what this does even if you haven't seen an InSpec test before? If not, then take a look at InSpec's [package resource documentation](http://inspec.io/docs/reference/resources/package/). Otherwise your friends in the [Chef Community Slack](http://community-slack.chef.io/) should be able to help.

<div class="sidebar--footer">
<a class="button primary-cta" href="/docs/getting-started/running-verify">Next - kitchen verify</a>
<a class="sidebar--footer--back" href="/docs/getting-started/manually-verifying">Back to previous step</a>
</div>
