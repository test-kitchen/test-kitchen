---
title: "kitchen converge"
slug: running-converge
menu:
  docs:
    parent: getting_started
    weight: 70
---

##### kitchen converge

Now that we have a recipe, let's use `kitchen converge` to see if it works:

~~~
$ kitchen converge default-ubuntu-1604
-----> Starting Kitchen (v1.16.0)
-----> Converging <default-ubuntu-1604>...
       Preparing files for transfer
       Preparing dna.json
       Resolving cookbook dependencies with Berkshelf 5.6.4...
       Removing non-cookbook files before transfer
       Preparing validation.pem
       Preparing client.rb
       ubuntu 16.04 x86_64
       Getting information for chef stable 13.0.118 for ubuntu...
       downloading https://omnitruck.chef.io/stable/chef/metadata?v=13.0.118&p=ubuntu&pv=16.04&m=x86_64
         to file /tmp/install.sh.1596/metadata.txt
       trying wget...
       sha1     da845676ff2e17b3049ca6e52541389318183f89
       sha256   650e80ad44584ca48716752d411989ab155845af4af7a50c530155d9718843eb
       url      https://packages.chef.io/files/stable/chef/13.0.118/ubuntu/16.04/chef_13.0.118-1_amd64.deb
       version  13.0.118
       downloaded metadata file looks valid...
       downloading https://packages.chef.io/files/stable/chef/13.0.118/ubuntu/16.04/chef_13.0.118-1_amd64.deb
         to file /tmp/install.sh.1596/chef_13.0.118-1_amd64.deb
       trying wget...
       Comparing checksum with sha256sum...
       Installing chef 13.0.118
       installing with dpkg...
       Selecting previously unselected package chef.
(Reading database ... 37825 files and directories currently installed.)
       Preparing to unpack .../chef_13.0.118-1_amd64.deb ...
       Unpacking chef (13.0.118-1) ...
       Setting up chef (13.0.118-1) ...
       Thank you for installing Chef!
       Transferring files to <default-ubuntu-1604>
       Starting Chef Client, version 13.0.118
       Creating a new client identity for default-ubuntu-1604 using the validator key.
       resolving cookbooks for run list: ["git_cookbook::default"]
       Synchronizing Cookbooks:
         - git_cookbook (0.1.0)
       Installing Cookbook Gems:
       Compiling Cookbooks...
       Converging 1 resources
       Recipe: git_cookbook::default
         * apt_package[git] action install (up to date)

       Running handlers:
       Running handlers complete
       Chef Client finished, 0/1 resources updated in 01 seconds
       Finished converging <default-ubuntu-1604> (0m15.55s).
-----> Kitchen is finished. (0m17.04s)
~~~

If you are a Chef user then part of the output above should look familiar to you. Here's what happened at a high level:

* Chef was installed on the instance
* The `git_cookbook` files and a minimal Chef configuration were built and uploaded to the instance
* A Chef run was initiated using the run-list and node attributes specified in the `.kitchen.yml` file

Looking closely at the run, there are two important things we want to note: git was already installed as part of the base image so Chef reports `(up to date)` as it didn't have to do anything.

<div class="callout">
<h3 class="callout--title">Pro Tip</h3>
This highlights a property of configuration management systems, like Chef, called <b>idempotence</b> - in this context, Chef saw that we requested to install git but as it was already installed there was nothing to do. This concept is very useful when thinking about configuration management generally as unlike a bash script, Chef isn't a series of commands but a set of declarations about the desired state.
</div>

A **converge** will leave the machine running and kitchen automatically uploads changes each converge so that one can iterate rapidly on configuration code. A lot of time and effort has gone into ensuring that the exit code of kitchen is always appropriate. Here is the Kitchen Command Guarantee:

* I will always exit with code **0** if my operation was successful.
* I will always exit with a non-zero code if **any** part of my operation was not successful.
* Any behavior to the contrary **is a bug**.

This exit code behavior is a fundamental prerequisite for any tool working in a Continuous Integration (CI) environment.

<div class="sidebar--footer">
<a class="button primary-cta" href="/docs/getting-started/manually-verifying">Next - Manually Verifying</a>
<a class="sidebar--footer--back" href="/docs/getting-started/writing-recipe">Back to previous step</a>
</div>
