---
title: "kitchen converge"
slug: running-converge
menu:
  docs:
    parent: getting_started
    weight: 70
---

Now that we have a recipe, let's use `kitchen converge` to see if it works:

~~~
-----> Starting Kitchen (v1.23.2)
-----> Creating <default-ubuntu-1604>...
       Bringing machine 'default' up with 'virtualbox' provider...
       ==> default: Importing base box 'bento/ubuntu-16.04'...
       ==> default: Matching MAC address for NAT networking...
       ==> default: Checking if box 'bento/ubuntu-16.04' is up to date...
       ==> default: Setting the name of the VM: default-ubuntu-1604_default_1537636613635_14010
       ==> default: Clearing any previously set network interfaces...
       ==> default: Preparing network interfaces based on configuration...
           default: Adapter 1: nat
       ==> default: Forwarding ports...
           default: 22 (guest) => 2222 (host) (adapter 1)
       ==> default: Booting VM...
       ==> default: Waiting for machine to boot. This may take a few minutes...
           default: SSH address: 127.0.0.1:2222
           default: SSH username: vagrant
           default: SSH auth method: private key
           default:
           default: Vagrant insecure key detected. Vagrant will automatically replace
           default: this with a newly generated keypair for better security.
           default:
           default: Inserting generated public key within guest...
           default: Removing insecure key from the guest if it's present...
           default: Key inserted! Disconnecting and reconnecting using new SSH key...
       ==> default: Machine booted and ready!
       ==> default: Checking for guest additions in VM...
       ==> default: Setting hostname...
       ==> default: Mounting shared folders...
           default: /tmp/omnibus/cache => /Users/cheeseplus/.kitchen/cache
       ==> default: Machine not provisioned because `--no-provision` is specified.
       [SSH] Established
       Vagrant instance <default-ubuntu-1604> created.
       Finished creating <default-ubuntu-1604> (0m37.44s).
-----> Converging <default-ubuntu-1604>...
       Preparing files for transfer
       Preparing dna.json
       Resolving cookbook dependencies with Berkshelf 7.0.6...
       Removing non-cookbook files before transfer
       Preparing validation.pem
       Preparing client.rb
-----> Installing Chef (install only if missing)
       Downloading https://omnitruck.chef.io/install.sh to file /tmp/install.sh
       Trying wget...
       Download complete.
       ubuntu 16.04 x86_64
       Getting information for chef stable  for ubuntu...
       downloading https://omnitruck.chef.io/stable/chef/metadata?v=&p=ubuntu&pv=16.04&m=x86_64
         to file /tmp/install.sh.1548/metadata.txt
       trying wget...
       sha1     174eb82ebe2eddc9c370487de6c124907f6d2f3a
       sha256   70ce695d2bf9fb01279a726148c0600544f1cd431642fa98d6696ef4c1dfc3c9
       url      https://packages.chef.io/files/stable/chef/14.5.27/ubuntu/16.04/chef_14.5.27-1_amd64.deb
       version  14.5.27
       downloaded metadata file looks valid...
       downloading https://packages.chef.io/files/stable/chef/14.5.27/ubuntu/16.04/chef_14.5.27-1_amd64.deb
         to file /tmp/omnibus/cache/chef_14.5.27-1_amd64.deb
       trying wget...
       Comparing checksum with sha256sum...

       WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING

       You are installing an omnibus package without a version pin.  If you are installing
       on production servers via an automated process this is DANGEROUS and you will
       be upgraded without warning on new releases, even to new major releases.
       Letting the version float is only appropriate in desktop, test, development or
       CI/CD environments.

       WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING

       Installing chef
       installing with dpkg...
       Selecting previously unselected package chef.
(Reading database ... 38378 files and directories currently installed.)
       Preparing to unpack .../cache/chef_14.5.27-1_amd64.deb ...
       Unpacking chef (14.5.27-1) ...
       Setting up chef (14.5.27-1) ...
       Thank you for installing Chef!
       Transferring files to <default-ubuntu-1604>
       Starting Chef Client, version 14.5.27
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
       Downloading files from <default-ubuntu-1604>
       Finished converging <default-ubuntu-1604> (0m22.49s).
-----> Kitchen is finished. (1m2.47s)
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
