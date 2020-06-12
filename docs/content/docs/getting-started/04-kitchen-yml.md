---
title: "kitchen.yml"
slug: kitchen-yml
menu:
  docs:
    parent: getting_started
    weight: 40
---

<div class="callout">
<h3 class="callout--title">Note</h3>
As of test-kitchen 1.21.0, we now prefer <code>kitchen.yml</code> over <code>.kitchen.yml</code>. This preference applies to <code>kitchen.local.yml</code> as well. This is backward compatible so the dot versions continue to work.
</div>

Let's turn our attention to the `kitchen.yml` file for a minute. While Chef Workstaton may have created the initial file automatically, it's expected that you will read and edit this file. After all, you know what you want to test... right?

For the moment let's say we only care about running our Chef cookbook on Ubuntu 20.04 with the latest Chef Infra Client release. In that case, we can edit the `kitchen.yml` file so that we pin the version of Chef and trim the list of `platforms` to only one entry like so:

~~~
---
driver:
  name: vagrant

provisioner:
  name: chef_zero

verifier:
  name: inspec

platforms:
  - name: ubuntu-20.04

suites:
  - name: default
    verifier:
      inspec_tests:
        - test/integration/default
    attributes:
~~~

To see the results of our work, let's run the `kitchen list` subcommand:

~~~
$ kitchen list
Instance             Driver   Provisioner  Verifier  Transport  Last Action    Last Error
default-ubuntu-2004  Vagrant  ChefZero     Inspec    Ssh        <Not Created>  <None>
~~~

Let's talk about what an **instance** is and how kitchen interacts with these.

<div class="sidebar--footer">
<a class="button primary-cta" href="/docs/getting-started/instances">Next - Instances</a>
<a class="sidebar--footer--back" href="/docs/getting-started/creating-cookbook">Back to previous step</a>
</div>
