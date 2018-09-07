---
title: "Instances"
slug: instances
menu:
  docs:
    parent: getting_started
    weight: 50
---

##### Instances

What is this `default-ubuntu-1604` thing and what is an "Instance"?

A Kitchen **Instance** is a combination of a **Suite** and a **Platform** as laid out in your `.kitchen.yml` file. Kitchen has auto-named our only instance by combining the **Suite** name (`"default"`) and the **Platform** name (`"ubuntu-16.04"`) into a form that is safe for DNS and hostname records, namely `"default-ubuntu-1604"`.

Let's spin this **Instance** up to see what happens. We're going to be painfully explicit and ask kitchen to _only_ create the `default-ubuntu-1604` instance:

~~~
$ kitchen create default-ubuntu-1604
-----> Starting Kitchen (v1.16.0)
-----> Creating <default-ubuntu-1604>...
       Bringing machine 'default' up with 'virtualbox' provider...
       ==> default: Box 'bento/ubuntu-16.04' could not be found. Attempting to find and install...
           default: Box Provider: virtualbox
           default: Box Version: >= 0
       ==> default: Loading metadata for box 'bento/ubuntu-16.04'
           default: URL: https://atlas.hashicorp.com/bento/ubuntu-16.04
       ==> default: Adding box 'bento/ubuntu-16.04' (v2.3.5) for provider: virtualbox
           default: Downloading: https://atlas.hashicorp.com/bento/boxes/ubuntu-16.04/versions/2.3.5/providers/virtualbox.box
       ==> default: Successfully added box 'bento/ubuntu-16.04' (v2.3.5) for 'virtualbox'!
       ==> default: Importing base box 'bento/ubuntu-16.04'...
       ==> default: Matching MAC address for NAT networking...
       ==> default: Checking if box 'bento/ubuntu-16.04' is up to date...
       ==> default: Setting the name of the VM: kitchen-git_cookbook-default-ubuntu-1604_default_1494859876671_57654
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
       Finished creating <default-ubuntu-1604> (1m0.49s).
-----> Kitchen is finished. (1m2.08s)
~~~

Kitchen calls this the **Create Action** and several subcommands that we'll learn about later map directly to other **actions**. If you are a Vagrant user then the line containing `vagrant up --no-provision` will look familiar. This may take several minutes depending on
your internet connection as kitchen will automatically fetch the `bento/ubuntu-16.04`
Vagrant box if it does not already exist.

Let's check the status of our instance now:

~~~
$ kitchen list
Instance             Driver   Provisioner  Verifier  Transport  Last Action    Last Error
default-ubuntu-1604  Vagrant  ChefZero     Inspec    Ssh        Created        <None>
~~~

Ok, we have an instance created and ready for some Chef code. Onward!

<div class="sidebar--footer">
<a class="button primary-cta" href="/docs/getting-started/writing-recipe">Next - Writing a Recipe</a>
<a class="sidebar--footer--back" href="/docs/getting-started/kitchen-yml">Back to previous step</a>
</div>
