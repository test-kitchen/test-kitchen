---
title: Writing a Test
slug: writing-test
menu:
  docs:
    parent: getting_started
    weight: 90
---

Being able to manually verify that the Chef Infra Client run worked is helpful, but having an automated test that fails when our assumptions are wrong is even better. Remember how we manually checked that Git was installed in the last section? That’s a great candidate for our first automated test.

Test Kitchen is built with testing in mind and supports several testing frameworks. In this guide, we’ll use Chef InSpec, which integrates with Test Kitchen via the `kitchen-inspec` plugin. If you’re curious about other supported frameworks, check out the [Verifiers](/docs/verifiers) section.

The cookbook skeleton already has conveniently created a test for you at `test/integration/default/default_test.rb`. Open this file in your editor and edit to match the following content:

```ruby
describe package('git') do
  it { should be_installed }
end
```

Why `test/integration/default/default_test.rb`? Let's take a look again at our `kitchen.yml`:

```yaml
# relevant sections of config
---
verifier:
  name: inspec

suites:
  - name: default
    verifier:
      inspec_tests:
        - test/integration/default
    attributes:
```

Here we are telling the verifier with the `inspec_tests` key to look in this directory. In our example we are pointing to a local directory but `kitchen-inspec` supports [remote locations](https://github.com/inspec/kitchen-inspec#use-remote-inspec-profiles) such as git repositories or even a Chef Automate server.

Can you guess what this does even if you haven't seen a Chef InSpec test before? If not, then take a look at Chef InSpec's [package resource documentation](https://docs.chef.io/inspec/resources/package/). Otherwise your friends in the [Chef Community Slack](https://community.chef.io/slack) should be able to help.

<div class="sidebar--footer">
<a class="button primary-cta" href="/docs/getting-started/running-verify">Next - kitchen verify</a>
<a class="sidebar--footer--back" href="/docs/getting-started/manually-verifying">Back to previous step</a>
</div>
