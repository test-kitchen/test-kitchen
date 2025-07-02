---
title: Adding a Suite
slug: adding-suite
menu:
  docs:
    parent: getting_started
    weight: 140
---

We're going to call our new suite `server` by editing `kitchen.yml` in your editor of choice so that it looks similar to:

```ruby
---
driver:
  name: vagrant

provisioner:
  name: chef_infra

verifier:
  name: inspec

platforms:
  - name: ubuntu-24.04
  - name: almalinux-10

suites:
  - name: default
    verifier:
      inspec_tests:
        - test/integration/default
  - name: server
    named_run_list: server
    verifier:
      inspec_tests:
        - test/integration/server
```

Now run `kitchen list` to see our new suite in action:

```ruby
$ kitchen list
Instance             Driver   Provisioner  Verifier  Transport  Last Action    Last Error
default-ubuntu-2404  Vagrant  ChefInfra     Inspec    Ssh        <Not Created>  <None>
default-almalinux-10 Vagrant  ChefInfra     Inspec    Ssh        <Not Created>  <None>
server-ubuntu-2404   Vagrant  ChefInfra     Inspec    Ssh        <Not Created>  <None>
server-almalinux-10  Vagrant  ChefInfra     Inspec    Ssh        <Not Created>  <None>
```

Woah, we've doubled our number of instances! Yes, that is going to happen. This explosion of test cases is just one reason why testing is hard.

<div class="sidebar--footer">
<a class="button primary-cta" href="/docs/getting-started/adding-test">Next - Adding a Test</a>
<a class="sidebar--footer--back" href="/docs/getting-started/adding-feature">Back to previous step</a>
</div>
