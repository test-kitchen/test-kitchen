---
title: ".kitchen.yml"
---

##### .kitchen.yml

Let's turn our attention to the `.kitchen.yml` file for a minute. While ChefDK may have created the initial file automatically, it's expected that you will read and edit this file. After all, you know what you want to test... right? Opening this file in your editor of choice we see something like the following:

~~~yaml
---
driver:
  name: vagrant

provisioner:
  name: chef_zero
  # You may wish to disable always updating cookbooks in CI or other testing environments.
  # For example:
  #   always_update_cookbooks: <%= !ENV['CI'] %>
  always_update_cookbooks: true

verifier:
  name: inspec

platforms:
  - name: ubuntu-16.04
  - name: centos-7.3

suites:
  - name: default
    run_list:
      - recipe[git_cookbook::default]
    verifier:
      inspec_tests:
        - test/smoke/default
    attributes:
~~~

Very briefly we can cover the common sections you're likely to find in a `.kitchen.yml` file:

* `driver`: Set and configure the driver. We're explicitly setting it via `name: vagrant` even though this is the default.
* `transport`: Configure settings for the transport layer (SSH/WinRM). No configuration is needed of this for our guide as default values suffice.
* `provisioner`: This tells Kitchen how to run Chef, to apply the code in our cookbook to the machine under test.  The default and simplest approach is to use `chef-solo`, but other options are available, and ultimately Test Kitchen doesn't care how the infrastructure is built - it could theoretically be with Puppet, Ansible, or Perl for all it cares.
* `verifier`: This is where we configure the behaviour of the Kitchen Verifier - this component that is responsible for executing tests against the machine after Chef has converged.
* `platforms`: This is a list of operation systems on which we want to run our code. Note that the operating system's version, architecture, cloud environment, etc. might be relevant to what Test Kitchen considers a **Platform**.
* `suites`: This section defines what we want to test.  It includes the Chef run-list and any node attribute setups that we want run on each **Platform** above. For example, we might want to test the MySQL client cookbook code separately from the server cookbook code for maximum isolation.

Let's say for argument's sake that we only care about running our Chef cookbook on Ubuntu 16.04 with Chef version 13. In that case, we can edit the `.kitchen.yml` file so that we add `require_chef_omnibus: 13` under the provisioner and trim the list of `platforms` to only one entry like so:

~~~yaml
---
driver:
  name: vagrant

provisioner:
  name: chef_zero
  require_chef_omnibus: 13

verifier:
  name: inspec

platforms:
  - name: ubuntu-16.04

suites:
  - name: default
    run_list:
      - recipe[git_cookbook::default]
    verifier:
      inspec_tests:
        - test/smoke/default
    attributes:
~~~

To see the results of our work, let's run the `kitchen list` subcommand:

~~~
$ kitchen list
Instance             Driver   Provisioner  Verifier  Transport  Last Action    Last Error
default-ubuntu-1604  Vagrant  ChefZero     Inspec    Ssh        <Not Created>  <None>
~~~

So what's this `default-ubuntu-1604` thing and what's an "Instance"? A Kitchen **Instance** is a pairwise combination of a **Suite** and a **Platform** as laid out in your `.kitchen.yml` file. Test Kitchen has auto-named your only instance by combining the **Suite** name (`"default"`) and the **Platform** name (`"ubuntu-16.04"`) into a form that is safe for DNS and hostname records, namely `"default-ubuntu-1604"`.



Before we're ready to create this instance, please make sure Okay, let's spin this **Instance** up to see what happens. Test Kitchen calls this the **Create Action**. We're going to be painfully explicit and ask Test Kitchen to only create the `default-ubuntu-1604` instance:

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
       ==> default: Setting the name of the VM: kitchen-git_cookbook-default-ubuntu-1604_default_1491849642627_99448
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
       Finished creating <default-ubuntu-1604> (1m0.15s).
-----> Kitchen is finished. (1m1.76s)
~~~

If you are a Vagrant user then the line containing `vagrant up --no-provision` will look familiar. Let's check the status of our instance now:

~~~
$ kitchen list
Instance             Driver   Provisioner  Verifier  Transport  Last Action    Last Error
default-ubuntu-1604  Vagrant  ChefZero     Inspec    Ssh        Created        <None>
~~~

Ok, we have an instance created and ready for some Chef code. Onward!

<div class="sidebar--footer">
<a class="button primary-cta" href="/docs/getting-started/writing-recipe">Next - Writing a Recipe</a>
<a class="sidebar--footer--back" href="/docs/getting-started/creating-cookbook">Back to previous step</a>
</div>
