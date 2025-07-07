---
title: Adding a Platform
slug: adding-platform
menu:
  docs:
    parent: getting_started
    weight: 120
---

Now that we have Ubuntu working, let's add support for AlmaLinux to our cookbook. This shouldn't be too bad. Open `kitchen.yml` in your editor and the `almalinux-10` line to your platforms list so that it resembles:

```yaml
---
driver:
  name: vagrant

provisioner:
  name: chef_infra

verifier:
  name: inspec

platforms:
  - name: ubuntu-24.04
  - name: almalinux-10

suites:
  - name: default
    verifier:
      inspec_tests:
        - test/integration/default
    attributes:
```

Now let's check the status of our instances:

```ruby
$ kitchen list
Instance             Driver   Provisioner  Verifier  Transport  Last Action    Last Error
default-ubuntu-2404  Vagrant  ChefInfra     Inspec    Ssh        <Not Created>  <None>
default-almalinux-10 Vagrant  ChefInfra     Inspec    Ssh        <Not Created>  <None>
```

We're going to use two shortcuts in the next command:

* Each instance has a simple state machine that tracks where it is in its lifecycle. Given its current state and the desired state, the instance is smart enough to run all actions in between current and desired.
* Any `kitchen` subcommand that takes an instance name as an argument can take a Ruby regular expression that will be used to glob a list of instances together. This means that `kitchen test ubuntu` would run the **test** action on all instances that had `ubuntu` in their name. Note that the **list** subcommand also takes the regex-globbing argument so feel free to experiment there.

In our next example we'll select the `default-almalinux-10` instance with simply `10` and will take it from uncreated to verified in one command.

Let's see how AlmaLinux runs our cookbook:

```ruby
$ kitchen verify 10
-----> Starting Test Kitchen (v3.7.1)
-----> Creating <default-almalinux-10>...
       Bringing machine 'default' up with 'virtualbox' provider...
       ==> default: Importing base box 'bento/almalinux-10'...
==> default: Matching MAC address for NAT networking...
       ==> default: Checking if box 'bento/almalinux-10' version '202112.19.0' is up to date...
       ==> default: Setting the name of the VM: kitchen-git_cookbook-default-almalinux-10-6e8b4f65-b069-4529-9b0a-ad936dc45032
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
       Vagrant instance <default-almalinux-10> created.
       Finished creating <default-almalinux-10> (0m58.00s).
-----> Converging <default-almalinux-10>...
       Preparing files for transfer
       Installing cookbooks for Policyfile /Users/tsmith/git_cookbook/Policyfile.rb using `chef install`
       Installing cookbooks from lock
       Installing git_cookbook 0.1.0
       Preparing dna.json
       Exporting cookbook dependencies from Policyfile /var/folders/99/1b6ms59j59sbl9t85sm75y8h0000gp/T/default-almalinux-10-sandbox-20200610-87075-1nvx3ww...
       Exported policy 'git_cookbook' to /var/folders/99/1b6ms59j59sbl9t85sm75y8h0000gp/T/default-almalinux-10-sandbox-20200610-87075-1nvx3ww

       To converge this system with the exported policy, run:
         cd /var/folders/99/1b6ms59j59sbl9t85sm75y8h0000gp/T/default-almalinux-10-sandbox-20200610-87075-1nvx3ww
         chef-client -z
       Removing non-cookbook files before transfer
       Preparing validation.pem
       Preparing client.rb
-----> Installing Chef install only if missing package
       Downloading https://omnitruck.chef.io/install.sh to file /tmp/install.sh
       Trying wget...
       Download complete.
       el 8 x86_64
       Getting information for chef stable  for el...
       downloading https://omnitruck.chef.io/stable/chef/metadata?v=&p=el&pv=8&m=x86_64
         to file /tmp/install.sh.3312/metadata.txt
       trying wget...
       sha1 599b3294c243e362ca77fb89a723c42fc29dae68
       sha256 ccf3b233b2e971a9fde360b6c9a3536ad31369c6c0c256b1f7619650c03695ab
       url https://packages.chef.io/files/stable/chef/17.9.42/el/8/chef-17.9.42-1.el7.x86_64.rpm
       version 17.9.42
       downloaded metadata file looks valid...
       downloading https://packages.chef.io/files/stable/chef/17.9.42/el/8/chef-17.9.42-1.el7.x86_64.rpm
         to file /tmp/omnibus/cache/chef-17.9.42-1.el7.x86_64.rpm
       trying wget...
       Comparing checksum with sha256sum...

       WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING

       You are installing a package without a version pin.  If you are installing
       on production servers via an automated process this is DANGEROUS and you will
       be upgraded without warning on new releases, even to new major releases.
       Letting the version float is only appropriate in desktop, test, development or
       CI/CD environments.

       WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING

       Installing chef
       installing with rpm...
       warning: /tmp/omnibus/cache/chef-17.9.42-1.el7.x86_64.rpm: Header V4 DSA/SHA1 Signature, key ID 83ef826a: NOKEY
       Verifying...                          ################################# [100%]
       Preparing...                          ################################# [100%]
       Updating / installing...
          1:chef-17.9.42-1.el7               ################################# [100%]
       Thank you for installing Chef Infra Client! For help getting started visit https://learn.chef.io
       Transferring files to <default-almalinux-10>
       +---------------------------------------------+
       ✔ 2 product licenses accepted.
       +---------------------------------------------+
       Starting Chef Infra Client, version 17.9.42
       Creating a new client identity for default-almalinux-10 using the validator key.
       Using policy 'git_cookbook' at revision 'f9aaaeaa7a929e3370d5224a3c7f07c605721933b9a893d383d0dc478aa48ce8'
       resolving cookbooks for run list: ["git_cookbook::default@0.1.0 (4def6b4)"]
       Synchronizing Cookbooks:
         - git_cookbook (0.1.0)
       Installing Cookbook Gems:
       Compiling Cookbooks...
       Converging 1 resources
       Recipe: git_cookbook::default
         * dnf_package[git] action install
           - install version 0:2.47.1-2.el10_0.x86_64 of package git

       Running handlers:
       Running handlers complete
       Chef Infra Client finished, 1/1 resources updated in 35 seconds
       Downloading files from <default-almalinux-10>
       Finished converging <default-almalinux-10> (0m53.28s).
-----> Setting up <default-almalinux-10>...
       Finished setting up <default-almalinux-10> (0m0.00s).
-----> Verifying <default-almalinux-10>...
       Loaded tests from {:path=>".Users.tsmith.git_cookbook.test.integration.default"}

Profile: tests from {:path=>"/Users/tsmith/git_cookbook/test/integration/default"} (tests from {:path=>".Users.tsmith.git_cookbook.test.integration.default"})
Version: (not specified)
Target:  ssh://vagrant@127.0.0.1:2222

  System Package git
     ✔  is expected to be installed

Test Summary: 1 successful, 0 failures, 0 skipped
       Finished verifying <default-almalinux-10> (0m0.80s).
-----> Test Kitchen is finished. (1m54.59s)
```

Nice! We've verified that our cookbook works on Ubuntu 24.04 and CentOS 8. Since the CentOS instance is no longer needed, let's destroy it for now:

```ruby
$ kitchen destroy
-----> Starting Test Kitchen (v3.7.1)
-----> Destroying <default-ubuntu-2404>...
       Finished destroying <default-ubuntu-2404> (0m0.00s).
-----> Destroying <default-almalinux-10>...
       ==> default: Forcing shutdown of VM...
       ==> default: Destroying VM and associated drives...
       Vagrant instance <default-almalinux-10> destroyed.
       Finished destroying <default-almalinux-10> (0m7.11s).
-----> Test Kitchen is finished. (0m8.76s)
```

Interesting. Test Kitchen tried to destroy both instances, one that was created and the other that was not. Which brings us to another tip with the `kitchen` command:

**Any `kitchen` subcommand without an instance argument will apply to all instances.**

Let's make sure everything has been destroyed:

```ruby
$ kitchen list
Instance             Driver   Provisioner  Verifier  Transport  Last Action    Last Error
default-ubuntu-2404  Vagrant  ChefInfra     Inspec    Ssh        <Not Created>  <None>
default-almalinux-10     Vagrant  ChefInfra     Inspec    Ssh        <Not Created>  <None>
```

<div class="sidebar--footer">
<a class="button primary-cta" href="/docs/getting-started/adding-feature">Next - Adding a Feature</a>
<a class="sidebar--footer--back" href="/docs/getting-started/running-test">Back to previous step</a>
</div>
