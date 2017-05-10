---
title: Excluding Platforms
---

##### Excluding Platforms

I'm going to spare us all a great deal of pain and say that getting CentOS working with Git Daemon and runit is, well, kinda nuts. Ultimately not worth it for the sake of this guide. So should we leave a Platform/Suite combination lying around that we know we won't support? Naw!

> **Add a platform name to an `excludes` array in a suite to remove the platform/suite combination from testing.**

Let's exclude the `server-centos-73` instance so that it doesn't accidentally get run. Update `.kitchen.yml` to look like the following:

~~~yaml
---
driver:
  name: vagrant

provisioner:
  name: chef_zero
  require_chef_omnibus: 13

verifier:
  name: inspec

platforms:
  - name: ubuntu-16.04
  - name: centos-7.3

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
      - centos-7.3
~~~

Now let's run `kitchen list` to ensure the instance is gone:

~~~
$ kitchen list
Instance             Driver   Provisioner  Verifier  Transport  Last Action    Last Error
default-ubuntu-1604  Vagrant  ChefZero     Inspec    Ssh        <Not Created>  <None>
default-centos-73    Vagrant  ChefZero     Inspec    Ssh        <Not Created>  <None>
server-ubuntu-1604   Vagrant  ChefZero     Inspec    Ssh        Verified       <None>
~~~

Finally let's destroy our running instances:

~~~
$ kitchen destroy
-----> Starting Kitchen (v1.16.0)
-----> Destroying <default-ubuntu-1604>...
       Finished destroying <default-ubuntu-1604> (0m0.00s).
-----> Destroying <default-centos-73>...
       Finished destroying <default-centos-73> (0m0.00s).
-----> Destroying <server-ubuntu-1604>...
       ==> default: Forcing shutdown of VM...
       ==> default: Destroying VM and associated drives...
       Vagrant instance <server-ubuntu-1604> destroyed.
       Finished destroying <server-ubuntu-1604> (0m12.55s).
-----> Kitchen is finished. (0m17.39s)
~~~

Okay, let's cut it off here, ship it!

<div class="sidebar--footer">
<a class="button primary-cta" href="/docs/getting-started/next-steps">Next Steps</a>
<a class="sidebar--footer--back" href="/docs/getting-started/adding-dependency">Back to previous step</a>
</div>
