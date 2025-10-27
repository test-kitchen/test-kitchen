---
title: "Instances"
slug: instances
menu:
  docs:
    parent: getting_started
    weight: 50
---

What is this `default-ubuntu-2404` thing and what is an **Instance**?

A Test Kitchen **Instance** represents a unique combination of a **Suite** and a **Platform** as defined in your `kitchen.yml` file. In this example, Test Kitchen automatically generates the instance name by joining the **Suite** name (`default`) and the **Platform** name (`ubuntu-24.04`), resulting in `default-ubuntu-2404`. This naming convention ensures the instance name is safe for use in DNS and hostnames.

Let's create this **Instance** to see how it works. We'll explicitly instruct Test Kitchen to create only the `default-ubuntu-2404` instance:

```ruby
$ kitchen create default-ubuntu-2404
-----> Starting Test Kitchen (v3.7.1)
-----> Creating <default-ubuntu-2404>...
       Bringing machine 'default' up with 'virtualbox' provider...
       ==> default: Importing base box 'bento/ubuntu-24.04'...
       ==> default: Matching MAC address for NAT networking...
       ==> default: Checking if box 'bento/ubuntu-24.04' version '202112.19.0' is up to date...
       ==> default: Setting the name of the VM: kitchen-git_cookbook-default-ubuntu-2404-38ec631e-b76e-4ac0-9029-fa885e4ada7f
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
       Finished creating <default-ubuntu-2404> (0m39.37s).
-----> Test Kitchen is finished. (0m40.73s)
```

Test Kitchen calls this the **Create Action** and several subcommands that we'll learn about later map directly to other **actions**. If you are a Vagrant user then the line containing `vagrant up --no-provision` will look familiar. This may take several minutes depending on your internet connection as kitchen will automatically fetch the `bento/ubuntu-24.04`
Vagrant box if it does not already exist.

Let's check the status of our instance now:

```bash
$ kitchen list
Instance             Driver   Provisioner  Verifier  Transport  Last Action    Last Error
default-ubuntu-2404  Vagrant  ChefInfra     Inspec    Ssh        Created        <None>
```

Ok, we have an instance created and ready for some Chef Infra code. Onward!

<div class="sidebar--footer">
<a class="button primary-cta" href="06-writing-recipe.md">Next - Writing a Recipe</a>
<a class="sidebar--footer--back" href="04-kitchen-yml.md">Back to previous step</a>
</div>
