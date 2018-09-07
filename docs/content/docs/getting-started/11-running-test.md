---
title: kitchen test
slug: running-test
menu:
  docs:
    parent: getting_started
    weight: 110
---

##### kitchen test

Now it's time to introduce to the **test** meta-action which helps you automate all the previous actions so far into one command. Recall that we currently have our instance in a "verified" state. With this in mind, let's run `kitchen test`:

~~~
$ kitchen test default-ubuntu-1604
-----> Starting Kitchen (v1.16.0)
-----> Cleaning up any prior instances of <default-ubuntu-1604>
-----> Destroying <default-ubuntu-1604>...
       ==> default: Forcing shutdown of VM...
       ==> default: Destroying VM and associated drives...
       Vagrant instance <default-ubuntu-1604> destroyed.
       Finished destroying <default-ubuntu-1604> (0m5.06s).
-----> Testing <default-ubuntu-1604>
-----> Creating <default-ubuntu-1604>...
       Bringing machine 'default' up with 'virtualbox' provider...
       ==> default: Importing base box 'bento/ubuntu-16.04'...
==> default: Matching MAC address for NAT networking...
       ==> default: Checking if box 'bento/ubuntu-16.04' is up to date...
       ==> default: Setting the name of the VM: kitchen-git_cookbook-default-ubuntu-1604_default_1494862691486_48214
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
       Finished creating <default-ubuntu-1604> (0m34.99s).
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
         to file /tmp/install.sh.1539/metadata.txt
       trying wget...
       sha1     da845676ff2e17b3049ca6e52541389318183f89
       sha256   650e80ad44584ca48716752d411989ab155845af4af7a50c530155d9718843eb
       url      https://packages.chef.io/files/stable/chef/13.0.118/ubuntu/16.04/chef_13.0.118-1_amd64.deb
       version  13.0.118
       downloaded metadata file looks valid...
       downloading https://packages.chef.io/files/stable/chef/13.0.118/ubuntu/16.04/chef_13.0.118-1_amd64.deb
         to file /tmp/install.sh.1539/chef_13.0.118-1_amd64.deb
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
       Finished converging <default-ubuntu-1604> (0m10.41s).
-----> Setting up <default-ubuntu-1604>...
       Finished setting up <default-ubuntu-1604> (0m0.00s).
-----> Verifying <default-ubuntu-1604>...
       Loaded tests from test/smoke/default

Profile: tests from test/smoke/default
Version: (not specified)
Target:  ssh://vagrant@127.0.0.1:2222


  System Package
     ✔  git should be installed

Test Summary: 1 successful, 0 failures, 0 skipped
       Finished verifying <default-ubuntu-1604> (0m0.23s).
-----> Destroying <default-ubuntu-1604>...
       ==> default: Forcing shutdown of VM...
       ==> default: Destroying VM and associated drives...
       Vagrant instance <default-ubuntu-1604> destroyed.
       Finished destroying <default-ubuntu-1604> (0m4.98s).
       Finished testing <default-ubuntu-1604> (0m55.68s).
-----> Kitchen is finished. (0m56.91s)
~~~

There's only one remaining action left that needs a mention: the **Destroy Action** which... destroys the instance. With this in mind, here's what kitchen is doing in the **Test Action**:

1. Destroys the instance if it exists (`Cleaning up any prior instances of <default-ubuntu-1604>`)
2. Creates the instance (`Creating <default-ubuntu-1604>`)
3. Converges the instance (`Converging <default-ubuntu-1604>`)
4. Sets up Busser and runner plugins on the instance (`Setting up <default-ubuntu-1604>`)
5. Verifies the instance by running Busser tests (`Verifying <default-ubuntu-1604>`)
6. Destroys the instance (`Destroying <default-ubuntu-1604>`)

A few details with regards to test:

* Kitchen will abort the run on the instance at the first sign of trouble. This means that if your Chef run fails then Busser won't be installed and the instance won't be destroyed. This gives you a chance to inspect the state of the instance and fix any issues.
* The behavior of the final destroy action can be overridden if desired. Check out the documentation for the `--destroy` flag using `kitchen help test`.
* The primary use case in mind for this meta-action is in a Continuous Integration environment or a command for developers to run before check in or after a fresh clone. If you're using this in your test-code-verify development cycle it's going to quickly become very slow and frustrating. You're better off running the **converge** and **verify** subcommands in development and save the **test** subcommand when you need to verify the end-to-end run of your code.

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
