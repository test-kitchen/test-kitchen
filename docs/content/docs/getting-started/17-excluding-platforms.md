---
title: Excluding Platforms
slug: excluding-platforms
menu:
  docs:
    parent: getting_started
    weight: 170
---

Perhaps our enterprise has standardized on Ubuntu 24.04 for server tasks so we really only care about testing that our `server` recipe works on that platform. That said we still want to be able to test our default recipe against AlmaLinux.

Let's give `kitchen list` a look:

```ruby
$ kitchen list
Instance             Driver   Provisioner  Verifier  Transport  Last Action    Last Error
default-ubuntu-2404  Vagrant  ChefInfra     Inspec    Ssh        <Not Created>  <None>
default-almalinux-10 Vagrant  ChefInfra     Inspec    Ssh        <Not Created>  <None>
server-ubuntu-2404   Vagrant  ChefInfra     Inspec    Ssh        Verified       <None>
server-almalinux-10  Vagrant  ChefInfra     Inspec    Ssh        <Not Created>  <None>
```

> **Add a platform name to an `excludes` array in a suite to remove the platform/suite combination from testing.**

Let's exclude the `almalinux-10` platform from the `server` suite so that it
doesn't accidentally get run. Update `kitchen.yml` to look like the following:

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
    excludes:
      - almalinux-10
```

**Note:** in above example the `almalinux-10` platform is explicitly excluded. You could have use a regexp syntax `/<pattern>/` to exclude any platform matching the given pattern.

Now let's run `kitchen list` to ensure the instance is gone:

```ruby
$ kitchen list
Instance             Driver   Provisioner  Verifier  Transport  Last Action    Last Error
default-ubuntu-2404  Vagrant  ChefInfra     Inspec    Ssh        <Not Created>  <None>
default-almalinux-10 Vagrant  ChefInfra     Inspec    Ssh        <Not Created>  <None>
server-ubuntu-2404   Vagrant  ChefInfra     Inspec    Ssh        Verified       <None>
```

Finally let's destroy our running instances:

```ruby
$ kitchen destroy
-----> Starting Test Kitchen (v3.7.1)
-----> Destroying <default-ubuntu-2404>...
       Finished destroying <default-ubuntu-2404> (0m0.00s).
-----> Destroying <default-almalinux-10>...
       Finished destroying <default-almalinux-10> (0m0.00s).
-----> Destroying <server-ubuntu-2404>...
       ==> default: Forcing shutdown of VM...
       ==> default: Destroying VM and associated drives...
       Vagrant instance <server-ubuntu-2404> destroyed.
       Finished destroying <server-ubuntu-2404> (0m12.55s).
-----> Test Kitchen is finished. (0m17.39s)
```

Now that we've completed our git daemon feature and made sure we're testing it on only the
platform we care about we've come to the end of our guide!

#### Congratulations

You've just written a valid Chef Infra cookbook, complete with tests, that is ready to
be improved upon further. Before you leave, check out some further resources to
help you along your testing journey.

<div class="sidebar--footer">
<a class="button primary-cta" href="/docs/getting-started/next-steps">Next Steps</a>
<a class="sidebar--footer--back" href="/docs/getting-started/adding-recipe">Back to previous step</a>
</div>
