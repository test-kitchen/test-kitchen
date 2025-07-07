---
title: "kitchen.yml"
slug: kitchen-yml
menu:
  docs:
    parent: getting_started
    weight: 40
---

Let's take a closer look at the `kitchen.yml` file. Although Chef Workstation generates an initial version for you, it's important to review and customize this file to suit your testing needs.

Suppose you want to test your Chef cookbook exclusively on Ubuntu 24.04 using the latest Chef Infra Client. In this scenario, you can update the `kitchen.yml` file to specify the desired Chef version and limit the `platforms` section to just one entry, as shown below:

```yaml
---
driver:
  name: vagrant

provisioner:
  name: chef_infra

verifier:
  name: inspec

platforms:
  - name: ubuntu-24.04

suites:
  - name: default
    verifier:
      inspec_tests:
        - test/integration/default
    attributes:
```

To see the results of our work, let's run the `kitchen list` subcommand:

```ruby
$ kitchen list
Instance             Driver   Provisioner  Verifier  Transport  Last Action    Last Error
default-ubuntu-2404  Vagrant  ChefInfra     Inspec    Ssh        <Not Created>  <None>
```

Let's talk about what an **instance** is and how kitchen interacts with these.

<div class="sidebar--footer">
<a class="button primary-cta" href="/docs/getting-started/instances">Next - Instances</a>
<a class="sidebar--footer--back" href="/docs/getting-started/creating-cookbook">Back to previous step</a>
</div>
