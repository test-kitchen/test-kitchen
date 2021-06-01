---
title: Excluding Platforms
slug: excluding-platforms
menu:
  docs:
    parent: getting_started
    weight: 170
---

Perhaps our enterprise has standardized on Ubuntu 20.04 for server tasks so we really only care about testing that our `server` recipe works on that platform. That said we still want to be able to test our default recipe against CentOS.

Let's give `kitchen list` a look:

~~~
$ kitchen list
Instance             Driver   Provisioner  Verifier  Transport  Last Action    Last Error
default-ubuntu-2004  Vagrant  ChefZero     Inspec    Ssh        <Not Created>  <None>
default-centos-8     Vagrant  ChefZero     Inspec    Ssh        <Not Created>  <None>
server-ubuntu-2004   Vagrant  ChefZero     Inspec    Ssh        Verified       <None>
server-centos-8      Vagrant  ChefZero     Inspec    Ssh        <Not Created>  <None>
~~~

> **Add a platform name to an `excludes` array in a suite to remove the platform/suite combination from testing.**

Let's exclude the `centos-8` platform from the `server` suite so that it
doesn't accidentally get run. Update `kitchen.yml` to look like the following:

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
  - name: centos-8

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
      - centos-8
~~~

Now let's run `kitchen list` to ensure the instance is gone:

~~~
$ kitchen list
Instance             Driver   Provisioner  Verifier  Transport  Last Action    Last Error
default-ubuntu-2004  Vagrant  ChefZero     Inspec    Ssh        <Not Created>  <None>
default-centos-8     Vagrant  ChefZero     Inspec    Ssh        <Not Created>  <None>
server-ubuntu-2004   Vagrant  ChefZero     Inspec    Ssh        Verified       <None>
~~~

Finally let's destroy our running instances:

~~~
$ kitchen destroy
-----> Starting Test Kitchen (v2.5.2)
-----> Destroying <default-ubuntu-2004>...
       Finished destroying <default-ubuntu-2004> (0m0.00s).
-----> Destroying <default-centos-8>...
       Finished destroying <default-centos-8> (0m0.00s).
-----> Destroying <server-ubuntu-2004>...
       ==> default: Forcing shutdown of VM...
       ==> default: Destroying VM and associated drives...
       Vagrant instance <server-ubuntu-2004> destroyed.
       Finished destroying <server-ubuntu-2004> (0m12.55s).
-----> Test Kitchen is finished. (0m17.39s)
~~~

Now that we've completed our git daemon feature and made sure we're testing it on only the
platform we care about we've come to the end of our guide!

#### Congratulations!

You've just written a valid Chef Infra cookbook, complete with tests, that is ready to
be improved upon further. Before you leave, check out some further resources to
help you along your testing journey.

<div class="sidebar--footer">
<a class="button primary-cta" href="/docs/getting-started/next-steps">Next Steps</a>
<a class="sidebar--footer--back" href="/docs/getting-started/adding-recipe">Back to previous step</a>
</div>
