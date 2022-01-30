---
title: "Instances"
slug: instances
menu:
  docs:
    parent: getting_started
    weight: 50
---

What is this `default-ubuntu-2004` thing and what is an **Instance**?

A Test Kitchen **Instance** is a combination of a **Suite** and a **Platform** as laid out in your `kitchen.yml` file. Test Kitchen has auto-named our only instance by combining the **Suite** name (`"default"`) and the **Platform** name (`"ubuntu-20.04"`) into a form that is safe for DNS and hostname records, namely `"default-ubuntu-2004"`.

Let's spin this **Instance** up to see what happens. We're going to be painfully explicit and ask kitchen to _only_ create the `default-ubuntu-2004` instance:

```ruby
$ kitchen create default-ubuntu-2004
-----> Starting Test Kitchen (v3.1.0)
-----> Creating <default-ubuntu-2004>...
       Bringing machine 'default' up with 'virtualbox' provider...
       ==> default: Importing base box 'bento/ubuntu-20.04'...
       ==> default: Matching MAC address for NAT networking...
       ==> default: Checking if box 'bento/ubuntu-20.04' version '202005.21.0' is up to date...
       ==> default: Setting the name of the VM: kitchen-git_cookbook-default-ubuntu-2004-38ec631e-b76e-4ac0-9029-fa885e4ada7f
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
       Vagrant instance <default-ubuntu-2004> created.
       Finished creating <default-ubuntu-2004> (0m39.37s).
-----> Test Kitchen is finished. (0m40.73s)
```

Test Kitchen calls this the **Create Action** and several subcommands that we'll learn about later map directly to other **actions**. If you are a Vagrant user then the line containing `vagrant up --no-provision` will look familiar. This may take several minutes depending on your internet connection as kitchen will automatically fetch the `bento/ubuntu-20.04`
Vagrant box if it does not already exist.

Let's check the status of our instance now:

```bash
$ kitchen list
Instance             Driver   Provisioner  Verifier  Transport  Last Action    Last Error
default-ubuntu-2004  Vagrant  ChefZero     Inspec    Ssh        Created        <None>
```

Ok, we have an instance created and ready for some Chef Infra code. Onward!

<div class="sidebar--footer">
<a class="button primary-cta" href="/docs/getting-started/writing-recipe">Next - Writing a Recipe</a>
<a class="sidebar--footer--back" href="/docs/getting-started/kitchen-yml">Back to previous step</a>
</div>
