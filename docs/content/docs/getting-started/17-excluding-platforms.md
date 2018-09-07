---
title: Excluding Platforms
slug: excluding-platforms
menu:
  docs:
    parent: getting_started
    weight: 170
---

##### Excluding Platforms

Perhaps our enterprise has standardized on Ubuntu 16.04 for server tasks so we really only care about testing that our `server` recipe works on that platform. That said we still want to be able to test our default recipe against CentOS.

Let's give `kitchen list` a look:

~~~
$ kitchen list
Instance             Driver   Provisioner  Verifier  Transport  Last Action    Last Error
default-ubuntu-1604  Vagrant  ChefZero     Inspec    Ssh        <Not Created>  <None>
default-centos-7     Vagrant  ChefZero     Inspec    Ssh        <Not Created>  <None>
server-ubuntu-1604   Vagrant  ChefZero     Inspec    Ssh        Verified       <None>
server-centos-7      Vagrant  ChefZero     Inspec    Ssh        <Not Created>  <None>
~~~

> **Add a platform name to an `excludes` array in a suite to remove the platform/suite combination from testing.**

Let's exclude the `centos-7` platform from the `server` suite so that it
doesn't accidentally get run. Update `.kitchen.yml` to look like the following:

~~~
---
driver:
  name: vagrant

provisioner:
  name: chef_zero

verifier:
  name: inspec

platforms:
  - name: ubuntu-16.04
  - name: centos-7

suites:
  - name: default
    run_list:
      - recipe[git_cookbook::default]
    verifier:
      inspec_tests:
        - test/smoke/default
    attributes:
  - name: server
    run_list:
      - recipe[git_cookbook::server]
    verifier:
      inspec_tests:
        - test/smoke/server
    attributes:
    excludes:
      - centos-7
~~~

Now let's run `kitchen list` to ensure the instance is gone:

~~~
$ kitchen list
Instance             Driver   Provisioner  Verifier  Transport  Last Action    Last Error
default-ubuntu-1604  Vagrant  ChefZero     Inspec    Ssh        <Not Created>  <None>
default-centos-7     Vagrant  ChefZero     Inspec    Ssh        <Not Created>  <None>
server-ubuntu-1604   Vagrant  ChefZero     Inspec    Ssh        Verified       <None>
~~~

Finally let's destroy our running instances:

~~~
$ kitchen destroy
-----> Starting Kitchen (v1.16.0)
-----> Destroying <default-ubuntu-1604>...
       Finished destroying <default-ubuntu-1604> (0m0.00s).
-----> Destroying <default-centos-7>...
       Finished destroying <default-centos-7> (0m0.00s).
-----> Destroying <server-ubuntu-1604>...
       ==> default: Forcing shutdown of VM...
       ==> default: Destroying VM and associated drives...
       Vagrant instance <server-ubuntu-1604> destroyed.
       Finished destroying <server-ubuntu-1604> (0m12.55s).
-----> Kitchen is finished. (0m17.39s)
~~~

Now that we've completed our git daemon feature and made sure we're testing it on only the
platform we care about we've come to the end of our guide!

#### Congratulations!

You've just written a valid Chef cookbook, complete with tests, that is ready to
be improved upon further. Before you leave, check out some further resources to
help you along your testing journey.

<div class="sidebar--footer">
<a class="button primary-cta" href="/docs/getting-started/next-steps">Next Steps</a>
<a class="sidebar--footer--back" href="/docs/getting-started/adding-recipe">Back to previous step</a>
</div>
