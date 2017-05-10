---
title: "Running Kitchen Converge"
---

##### Running Kitchen Converge

Now that we have a recipe, let's use `kitchen converge` to see if it works:

~~~
kitchen converge default-ubuntu-1604
-----> Starting Kitchen (v1.16.0)
-----> Creating <default-ubuntu-1604>...
       Bringing machine 'default' up with 'virtualbox' provider...
       ==> default: Importing base box 'bento/ubuntu-16.04'...
==> default: Matching MAC address for NAT networking...
       ==> default: Checking if box 'bento/ubuntu-16.04' is up to date...
       ==> default: Setting the name of the VM: kitchen-git_cookbook-default-ubuntu-1604_default_1494376111924_33738
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
       Finished creating <default-ubuntu-1604> (0m37.00s).
-----> Converging <default-ubuntu-1604>...
       Preparing files for transfer
       Preparing dna.json
       Resolving cookbook dependencies with Berkshelf 5.6.4...
       Removing non-cookbook files before transfer
       Preparing validation.pem
       Preparing client.rb
-----> Installing Chef Omnibus (13)
       Downloading https://omnitruck.chef.io/install.sh to file /tmp/install.sh
       Trying wget...
       Download complete.
       ubuntu 16.04 x86_64
       Getting information for chef stable 13 for ubuntu...
       downloading https://omnitruck.chef.io/stable/chef/metadata?v=13&p=ubuntu&pv=16.04&m=x86_64
         to file /tmp/install.sh.1549/metadata.txt
       trying wget...
       sha1     da845676ff2e17b3049ca6e52541389318183f89
       sha256   650e80ad44584ca48716752d411989ab155845af4af7a50c530155d9718843eb
       url      https://packages.chef.io/files/stable/chef/13.0.118/ubuntu/16.04/chef_13.0.118-1_amd64.deb
       version  13.0.118
       downloaded metadata file looks valid...
       /tmp/omnibus/cache/chef_13.0.118-1_amd64.deb already exists, verifiying checksum...
       Comparing checksum with sha256sum...
       checksum compare succeeded, using existing file!
       Installing chef 13
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
         - yum-epel (2.1.1)
         - packagecloud (0.3.0)
         - runit (3.0.5)
         - compat_resource (12.19.0)
       Installing Cookbook Gems:
       Compiling Cookbooks...
       /tmp/kitchen/cache/cookbooks/packagecloud/resources/repo.rb:10: warning: constant ::Fixnum is deprecated
       Converging 2 resources
       Recipe: git_cookbook::default
         * apt_package[git] action install (up to date)
         * log[Well, that was too easy] action write


       Running handlers:
       Running handlers complete
       Chef Client finished, 1/2 resources updated in 02 seconds
       Finished converging <default-ubuntu-1604> (0m13.91s).
-----> Kitchen is finished. (0m51.99s)
~~~

To quote our Chef run, that **was** too easy. If you are a Chef user then part of the output above should look familiar to you. Here's what happened at a high level:

* Chef was installed on the instance
* The `git_cookbook` files and a minimal Chef configuration were built and uploaded to the instance
* A Chef run was initiated using the run-list and node attributes specified in the `.kitchen.yml` file

Looking closely at the run, there are two important things we want to note: git was already installed as part of the base image so Chef reports `(up to date)` as it didn't have to do anything.

<div class="callout">
<h3 class="callout--title">Pro tip</h3>
This highlights a property of configuration management systems, like Chef, called <b>idempotence</b> - in this context, Chef saw that we requested to install git but as it was already installed there was nothing to do. This concept is very useful when thinking about configuration management generally as unlike a bash script, Chef isn't a series of commands but a set of declarations about the desired state.
</div>

Running converge again, we'd notice:

* Kitchen found that chef-client was installed and skipped a re-installation.
* The same cookbook files and configuration were uploaded to the instance. Test Kitchen is optimizing for **freshness of code and configuration over speed**. Although we all like speed wherever possible.
* A Chef run is initiated and runs very quickly as we are in the desired state.

A lot of time and effort has gone into ensuring that the exit code of Test Kitchen is always appropriate. Here is the Kitchen Command Guarantee:

* I will always exit with code **0** if my operation was successful.
* I will always exit with a non-zero code if **any** part of my operation was not successful.
* Any behavior to the contrary **is a bug**.

This exit code behavior is a fundamental prerequisite for any tool working in a Continuous Integration (CI) environment.

<div class="sidebar--footer">
<a class="button primary-cta" href="manually-verifying">Next - Manually Verifying</a>
<a class="sidebar--footer--back" href="running-converge">Back to previous step</a>
</div>
