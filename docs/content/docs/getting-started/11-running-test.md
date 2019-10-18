---
title: kitchen test
slug: running-test
menu:
  docs:
    parent: getting_started
    weight: 110
---

Now it's time to introduce to the **test** meta-action which helps you automate all the previous actions so far into one command. Checking `kitchen list`, the "Last Action" of our instance should be "Verified". With this in mind, let's run `kitchen test`:

~~~
-----> Starting Test Kitchen (v1.23.2)
-----> Cleaning up any prior instances of <default-ubuntu-1604>
-----> Destroying <default-ubuntu-1604>...
       ==> default: Forcing shutdown of VM...
       ==> default: Destroying VM and associated drives...
       Vagrant instance <default-ubuntu-1604> destroyed.
       Finished destroying <default-ubuntu-1604> (0m5.56s).
-----> Testing <default-ubuntu-1604>
-----> Creating <default-ubuntu-1604>...
       Bringing machine 'default' up with 'virtualbox' provider...
       ==> default: Importing base box 'bento/ubuntu-16.04'...
       ==> default: Matching MAC address for NAT networking...
       ==> default: Checking if box 'bento/ubuntu-16.04' is up to date...
       ==> default: Setting the name of the VM: default-ubuntu-1604_default_1537638619562_49760
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
       Finished creating <default-ubuntu-1604> (0m36.40s).
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
         to file /tmp/install.sh.1561/metadata.txt
       Trying wget...
       Download complete.
       ubuntu 16.04 x86_64
       Getting information for chef stable  for ubuntu...
       downloading https://omnitruck.chef.io/stable/chef/metadata?v=&p=ubuntu&pv=16.04&m=x86_64
         to file /tmp/install.sh.1561/metadata.txt
       trying wget...
       sha1     174eb82ebe2eddc9c370487de6c124907f6d2f3a
       sha256   70ce695d2bf9fb01279a726148c0600544f1cd431642fa98d6696ef4c1dfc3c9
       url      https://packages.chef.io/files/stable/chef/14.5.27/ubuntu/16.04/chef_14.5.27-1_amd64.deb
       version  14.5.27
       downloaded metadata file looks valid...
       /tmp/omnibus/cache/chef_14.5.27-1_amd64.deb exists
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
       Finished converging <default-ubuntu-1604> (0m22.87s).
-----> Setting up <default-ubuntu-1604>...
       Finished setting up <default-ubuntu-1604> (0m0.00s).
-----> Verifying <default-ubuntu-1604>...
       Loaded tests from {:path=>".Users.cheeseplus.focus.git_cookbook.test.integration.default"}

Profile: tests from {:path=>"/Users/cheeseplus/focus/git_cookbook/test/integration/default"} (tests from {:path=>".Users.cheeseplus.focus.git_cookbook.test.integration.default"})
Version: (not specified)
Target:  ssh://vagrant@127.0.0.1:2222

  System Package git
     ✔  should be installed

Test Summary: 1 successful, 0 failures, 0 skipped
       Finished verifying <default-ubuntu-1604> (0m0.29s).
-----> Destroying <default-ubuntu-1604>...
       ==> default: Forcing shutdown of VM...
       ==> default: Destroying VM and associated drives...
       Vagrant instance <default-ubuntu-1604> destroyed.
       Finished destroying <default-ubuntu-1604> (0m5.61s).
       Finished testing <default-ubuntu-1604> (1m10.75s).
-----> Test Kitchen is finished. (1m13.21s)
~~~

There's only one remaining action left that needs a mention: the **Destroy Action** which as one might expect, destroys the instance. With this in mind, here's what kitchen is doing in the **Test Action**:

1. Destroys the instance if it exists
2. Creates the instance
3. Converges the instance
4. Verifies the instance with InSpec
5. Destroys the instance

A few details with regards to test:

* Kitchen will abort the run on the instance at the first sign of trouble. This means that if your Chef run fails then InSpec won't be run and the instance won't be destroyed. This gives you a chance to inspect the state of the instance and fix any issues.
* The behavior of the final destroy action can be overridden if desired. Check out the CLI help for the `--destroy` flag using `kitchen help test`.
* The primary use case in mind for this meta-action is in a Continuous Integration environment or a command for developers to run before check in or after a fresh clone. If you're using this in your test-code-verify development cycle it's going to quickly become very slow and frustrating. You're better off running the **converge** and **verify** sub-commands in development and save the **test** sub-command when you need to verify the end-to-end run of your code.

Finally, let's check the status of the instance:

~~~
$ kitchen list
Instance             Driver   Provisioner  Verifier  Transport  Last Action    Last Error
default-ubuntu-1604  Vagrant  ChefZero     Inspec    Ssh        <Not Created>  <None>
~~~

Back to square one.

<div class="sidebar--footer">
<a class="button primary-cta" href="/docs/getting-started/adding-platform">Next - Adding a Platform</a>
<a class="sidebar--footer--back" href="/docs/getting-started/running-verify">Back to previous step</a>
</div>
