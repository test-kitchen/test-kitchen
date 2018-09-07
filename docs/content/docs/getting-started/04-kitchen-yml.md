---
title: ".kitchen.yml"
slug: kitchen-yml
menu:
  docs:
    parent: getting_started
    weight: 40
---

##### .kitchen.yml

Let's turn our attention to the `.kitchen.yml` file for a minute. While ChefDK may have created the initial file automatically, it's expected that you will read and edit this file. After all, you know what you want to test... right?

For the moment let's say we only care about running our Chef cookbook on Ubuntu 16.04 with Chef version 13. In that case, we can edit the `.kitchen.yml` file so that we pin the version of Chef and trim the list of `platforms` to only one entry like so:

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

suites:
  - name: default
    run_list:
      - recipe[git_cookbook::default]
    verifier:
      inspec_tests:
        - test/smoke/default
    attributes:
~~~

Very briefly we can cover the common sections you're likely to find in a `.kitchen.yml` file:

* `driver`: Set and configure the driver. We're explicitly setting it via `name: vagrant` even though this is the default.
* `transport`: Configure settings for the transport layer (SSH/WinRM). No configuration is needed of this for our guide as default values suffice. However, be aware that if  `winrm-elevated 0.4.0` is used, this additional configuration is needed:

~~~
---
transport:
  name: winrm
  elevated: true
~~~

* `provisioner`: This tells Kitchen how to run Chef, to apply the code in our cookbook to the machine under test.  The default and simplest approach is to use `chef_zero`, but other options are available, and ultimately Kitchen doesn't care how the infrastructure is built - it could theoretically be with Puppet, Ansible, or Perl for all it cares.
* `verifier`: This is where we configure the behaviour of the Kitchen Verifier - this component that is responsible for executing tests against the machine after Chef has converged.
* `platforms`: This is a list of operation systems on which we want to run our code. Note that the operating system's version, architecture, cloud environment, etc. might be relevant to what Kitchen considers a **Platform**.
* `suites`: This section defines what we want to test.  It includes the Chef run-list and any node attribute setups that we want run on each **Platform** above. For example, we might want to test the MySQL client cookbook code separately from the server cookbook code for maximum isolation.

To see the results of our work, let's run the `kitchen list` subcommand:

~~~
$ kitchen list
Instance             Driver   Provisioner  Verifier  Transport  Last Action    Last Error
default-ubuntu-1604  Vagrant  ChefZero     Inspec    Ssh        <Not Created>  <None>
~~~

Let's talk about what an **instance** is and how kitchen interacts with these.

<div class="sidebar--footer">
<a class="button primary-cta" href="/docs/getting-started/instances">Next - Instances</a>
<a class="sidebar--footer--back" href="/docs/getting-started/creating-cookbook">Back to previous step</a>
</div>
