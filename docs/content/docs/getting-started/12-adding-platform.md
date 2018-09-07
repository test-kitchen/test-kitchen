---
title: Adding a Platform
slug: adding-platform
menu:
  docs:
    parent: getting_started
    weight: 120
---

Now that we have Ubuntu working, let's add support for CentOS to our cookbook. This shouldn't be too bad. Open `.kitchen.yml` in your editor and the `centos-7` line to your platforms list so that it resembles:

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
~~~

Now let's check the status of our instances:

~~~
$ kitchen list
Instance             Driver   Provisioner  Verifier  Transport  Last Action    Last Error
default-ubuntu-1604  Vagrant  ChefZero     Inspec    Ssh        <Not Created>  <None>
default-centos-7     Vagrant  ChefZero     Inspec    Ssh        <Not Created>  <None>
~~~

We're going to use two shortcuts in the next command:

* Each instance has a simple state machine that tracks where it is in its lifecycle. Given its current state and the desired state, the instance is smart enough to run all actions in between current and desired.
* Any `kitchen` subcommand that takes an instance name as an argument can take a Ruby regular expression that will be used to glob a list of instances together. This means that `kitchen test ubuntu` would run the **test** action on all instances that had `ubuntu` in their name. Note that the **list** subcommand also takes the regex-globbing argument so feel free to experiment there.

In our next example we'll select the `default-centos-7` instance with simply `7` and will take it from uncreated to verified in one command.

Let's see how CentOS runs our cookbook:

~~~
kitchen verify 7
-----> Starting Kitchen (v1.16.0)
-----> Creating <default-centos-7>...
       Bringing machine 'default' up with 'virtualbox' provider...
       ==> default: Importing base box 'bento/centos-7'...
==> default: Matching MAC address for NAT networking...
       ==> default: Checking if box 'bento/centos-7' is up to date...
       ==> default: Setting the name of the VM: kitchen-git_cookbook-default-centos-7_default_1494253442790_20368
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
           default: Warning: Connection reset. Retrying...
           default: Warning: Remote connection disconnect. Retrying...
           default: Warning: Connection reset. Retrying...
           default: Warning: Remote connection disconnect. Retrying...
           default: Warning: Connection reset. Retrying...
           default: Warning: Remote connection disconnect. Retrying...
           default: Warning: Connection reset. Retrying...
           default: Warning: Remote connection disconnect. Retrying...
           default: Warning: Connection reset. Retrying...
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
       Vagrant instance <default-centos-7> created.
       Finished creating <default-centos-7> (0m42.13s).
-----> Converging <default-centos-7>...
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
       el 7 x86_64
       Getting information for chef stable 13 for el...
       downloading https://omnitruck.chef.io/stable/chef/metadata?v=13&p=el&pv=7&m=x86_64
         to file /tmp/install.sh.3984/metadata.txt
       trying wget...
       sha1     f0eac57e53833d710334839fbe4e9b940d1c43c6
       sha256   a3cb30fe2eb6e3ce5ea8914635d01562660f4978568fa3303b14336eefdb09ee
       url      https://packages.chef.io/files/stable/chef/13.0.118/el/7/chef-13.0.118-1.el7.x86_64.rpm
       version  13.0.118
       downloaded metadata file looks valid...
       /tmp/omnibus/cache/chef-13.0.118-1.el7.x86_64.rpm already exists, verifiying checksum...
       Comparing checksum with sha256sum...
       checksum compare succeeded, using existing file!
       Installing chef 13
       installing with rpm...
       warning: /tmp/omnibus/cache/chef-13.0.118-1.el7.x86_64.rpm: Header V4 DSA/SHA1 Signature, key ID 83ef826a: NOKEY
       Preparing...                          ################################# [100%]
       Updating / installing...
          1:chef-13.0.118-1.el7              ################################# [100%]
       Thank you for installing Chef!
       Transferring files to <default-centos-7>
       Starting Chef Client, version 13.0.118
       Creating a new client identity for default-centos-7 using the validator key.
       resolving cookbooks for run list: ["git_cookbook::default"]
       Synchronizing Cookbooks:
         - git_cookbook (0.1.0)
       Installing Cookbook Gems:
       Compiling Cookbooks...
       Converging 2 resources
       Recipe: git_cookbook::default
         * yum_package[git] action install
           - install version 1.8.3.1-6.el7_2.1 of package git
         * log[Well, that was too easy] action write


       Running handlers:
       Running handlers complete
       Chef Client finished, 2/2 resources updated in 12 seconds
       Finished converging <default-centos-7> (0m27.28s).
-----> Setting up <default-centos-7>...
       Finished setting up <default-centos-7> (0m0.00s).
-----> Verifying <default-centos-7>...
       Loaded tests from test/smoke/default

Profile: tests from test/smoke/default
Version: (not specified)
Target:  ssh://vagrant@127.0.0.1:2222


  System Package
     ✔  git should be installed

Test Summary: 1 successful, 0 failures, 0 skipped
       Finished verifying <default-centos-7> (0m1.52s).
-----> Kitchen is finished. (1m11.96s)
~~~

Nice! We've verified that our cookbook works on Ubuntu 16.04 and CentOS 7.3. Since the CentOS instance will hang out for no good reason, let's kill it for now:

~~~
kitchen destroy
-----> Starting Kitchen (v1.16.0)
-----> Destroying <default-ubuntu-1604>...
       Finished destroying <default-ubuntu-1604> (0m0.00s).
-----> Destroying <default-centos-7>...
       ==> default: Forcing shutdown of VM...
       ==> default: Destroying VM and associated drives...
       Vagrant instance <default-centos-7> destroyed.
       Finished destroying <default-centos-7> (0m4.96s).
-----> Kitchen is finished. (0m6.04s)
~~~

Interesting. Kitchen tried to destroy both instances, one that was created and the other that was not. Which brings us to another tip with the `kitchen` command:

> **Any `kitchen` subcommand without an instance argument will apply to all instances.**

Let's make sure everything has been destroyed:

~~~
$ kitchen list
Instance             Driver   Provisioner  Verifier  Transport  Last Action    Last Error
default-ubuntu-1604  Vagrant  ChefZero     Inspec    Ssh        <Not Created>  <None>
default-centos-7     Vagrant  ChefZero     Inspec    Ssh        <Not Created>  <None>
~~~

<div class="sidebar--footer">
<a class="button primary-cta" href="/docs/getting-started/adding-feature">Next - Adding a Feature</a>
<a class="sidebar--footer--back" href="/docs/getting-started/running-test">Back to previous step</a>
</div>
