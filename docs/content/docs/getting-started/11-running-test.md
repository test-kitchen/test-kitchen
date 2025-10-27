---
title: kitchen test
slug: running-test
menu:
  docs:
    parent: getting_started
    weight: 110
---

Now it's time to introduce to the **test** meta-action which helps you automate all the previous actions so far into one command. Checking `kitchen list`, the "Last Action" of our instance should be "Verified". With this in mind, let's run `kitchen test`:

```ruby
$ kitchen test
-----> Starting Test Kitchen (v3.7.1)
-----> Cleaning up any prior instances of <default-ubuntu-2404>
-----> Destroying <default-ubuntu-2404>...
       ==> default: Forcing shutdown of VM...
       ==> default: Destroying VM and associated drives...
       Vagrant instance <default-ubuntu-2404> destroyed.
       Finished destroying <default-ubuntu-2404> (0m8.27s).
-----> Testing <default-ubuntu-2404>
-----> Creating <default-ubuntu-2404>...
       Bringing machine 'default' up with 'virtualbox' provider...
       ==> default: Importing base box 'bento/ubuntu-24.04'...
       ==> default: Matching MAC address for NAT networking...
       ==> default: Checking if box 'bento/ubuntu-24.04' version '202112.19.0' is up to date...
       ==> default: Setting the name of the VM: kitchen-git_cookbook-default-ubuntu-2404-c269d77f-86f8-4bf9-aafe-884177e193fe
       ==> default: Clearing any previously set network interfaces...
       ==> default: Preparing network interfaces based on configuration...
           default: Adapter 1: nat
       ==> default: Forwarding ports...
           default: 22 (guest) => 2222 (host) (adapter 1)
       ==> default: Running 'pre-boot' VM customizations...
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
           default: /tmp/omnibus/cache => /Users/tsmith/.kitchen/cache
       ==> default: Machine not provisioned because `--no-provision` is specified.
       [SSH] Established
       Vagrant instance <default-ubuntu-2404> created.
       Finished creating <default-ubuntu-2404> (0m35.86s).
-----> Converging <default-ubuntu-2404>...
       Preparing files for transfer
       Installing cookbooks for Policyfile /Users/tsmith/git_cookbook/Policyfile.rb using `chef install`
       Installing cookbooks from lock
       Installing git_cookbook 0.1.0
       Preparing dna.json
       Exporting cookbook dependencies from Policyfile /var/folders/99/1b6ms59j59sbl9t85sm75y8h0000gp/T/default-ubuntu-2404-sandbox-20200610-80493-1jydajx...
       Exported policy 'git_cookbook' to /var/folders/99/1b6ms59j59sbl9t85sm75y8h0000gp/T/default-ubuntu-2404-sandbox-20200610-80493-1jydajx

       To converge this system with the exported policy, run:
         cd /var/folders/99/1b6ms59j59sbl9t85sm75y8h0000gp/T/default-ubuntu-2404-sandbox-20200610-80493-1jydajx
         chef-client -z
       Removing non-cookbook files before transfer
       Preparing validation.pem
       Preparing client.rb
-----> Installing Chef install only if missing package
       Downloading https://omnitruck.chef.io/install.sh to file /tmp/install.sh
       Trying wget...
       Download complete.
       ubuntu 24.04 x86_64
       Getting information for chef stable  for ubuntu...
       downloading https://omnitruck.chef.io/stable/chef/metadata?v=&p=ubuntu&pv=24.04&m=x86_64
         to file /tmp/install.sh.1399/metadata.txt
       trying wget...
       sha1 1466b9dbfcce80987e145d58e12c076216f9a5b5
       sha256 f1f1cc5787bb56d5d3cb37339bb458f8d715e0be9a58abaad7e52ade90a2bfec
       url https://packages.chef.io/files/stable/chef/17.9.42/ubuntu/24.04/chef_17.9.42-1_amd64.deb
       version 17.9.42
       downloaded metadata file looks valid...
       /tmp/omnibus/cache/chef_17.9.42-1_amd64.deb exists
       Comparing checksum with sha256sum...

       WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING

       You are installing a package without a version pin.  If you are installing
       on production servers via an automated process this is DANGEROUS and you will
       be upgraded without warning on new releases, even to new major releases.
       Letting the version float is only appropriate in desktop, test, development or
       CI/CD environments.

       WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING

       Installing chef
       installing with dpkg...
       Selecting previously unselected package chef.
(Reading database ... 44414 files and directories currently installed.)
       Preparing to unpack .../cache/chef_17.9.42-1_amd64.deb ...
       Unpacking chef (17.9.42-1) ...
       Setting up chef (17.9.42-1) ...
       Thank you for installing Chef Infra Client! For help getting started visit https://learn.chef.io
       Transferring files to <default-ubuntu-2404>
       +---------------------------------------------+
       ✔ 2 product licenses accepted.
       +---------------------------------------------+
       Starting Chef Infra Client, version 17.9.42
       Creating a new client identity for default-ubuntu-2404 using the validator key.
       Using policy 'git_cookbook' at revision 'f9aaaeaa7a929e3370d5224a3c7f07c605721933b9a893d383d0dc478aa48ce8'
       resolving cookbooks for run list: ["git_cookbook::default@0.1.0 (4def6b4)"]
       Synchronizing Cookbooks:
         - git_cookbook (0.1.0)
       Installing Cookbook Gems:
       Compiling Cookbooks...
       Converging 1 resources
       Recipe: git_cookbook::default
         * apt_package[git] action install (up to date)

       Running handlers:
       Running handlers complete
       Chef Infra Client finished, 0/1 resources updated in 01 seconds
       Downloading files from <default-ubuntu-2404>
       Finished converging <default-ubuntu-2404> (0m10.98s).
-----> Setting up <default-ubuntu-2404>...
       Finished setting up <default-ubuntu-2404> (0m0.00s).
-----> Verifying <default-ubuntu-2404>...
       Loaded tests from {:path=>".Users.tsmith.git_cookbook.test.integration.default"}

Profile: tests from {:path=>"/Users/tsmith/git_cookbook/test/integration/default"} (tests from {:path=>".Users.tsmith.git_cookbook.test.integration.default"})
Version: (not specified)
Target:  ssh://vagrant@127.0.0.1:2222

  System Package git
     ✔  is expected to be installed

Test Summary: 1 successful, 0 failures, 0 skipped
       Finished verifying <default-ubuntu-2404> (0m0.65s).
-----> Destroying <default-ubuntu-2404>...
       ==> default: Forcing shutdown of VM...
       ==> default: Destroying VM and associated drives...
       Vagrant instance <default-ubuntu-2404> destroyed.
       Finished destroying <default-ubuntu-2404> (0m7.03s).
       Finished testing <default-ubuntu-2404> (1m2.79s).
-----> Test Kitchen is finished. (1m4.19s)
```

There's only one remaining action left that needs a mention: the **Destroy Action** which as one might expect, destroys the instance. With this in mind, here's what Test Kitchen is doing in the **Test Action**:

1. Destroys the instance if it exists
2. Creates the instance
3. Converges the instance
4. Verifies the instance with InSpec
5. Destroys the instance

A few details with regards to test:

* Test Kitchen will abort the run on the instance at the first sign of trouble. This means that if your Chef Infra Client run fails then Chef InSpec won't be run and the instance won't be destroyed. This gives you a chance to inspect the state of the instance and fix any issues.
* The behavior of the final destroy action can be overridden if desired. Check out the CLI help for the `--destroy` flag using `kitchen help test`.
* The primary use case in mind for this meta-action is in a Continuous Integration environment or a command for developers to run before check in or after a fresh clone. If you're using this in your test-code-verify development cycle it's going to quickly become very slow and frustrating. You're better off running the **converge** and **verify** sub-commands in development and save the **test** sub-command when you need to verify the end-to-end run of your code.

Finally, let's check the status of the instance:

```ruby
$ kitchen list
Instance             Driver   Provisioner  Verifier  Transport  Last Action    Last Error
default-ubuntu-2404  Vagrant  ChefInfra     Inspec    Ssh        <Not Created>  <None>
```

Back to square one.

<div class="sidebar--footer">
<a class="button primary-cta" href="12-adding-platform.md">Next - Adding a Platform</a>
<a class="sidebar--footer--back" href="10-running-verify.md">Back to previous step</a>
</div>
