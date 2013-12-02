---
title: Running Kitchen Test
next:
  text: "Adding a Platform"
  url: "adding-platform"
---

Now that we are masters of the Ubuntu platform, let's add support for CentOS to our cookbook. This shouldn't be too bad. Open `.kitchen.yml` in your editor and the `centos-6.4` line to your platforms list so that it resembles:

~~~yaml
---
driver_plugin: vagrant
driver_config:
  require_chef_omnibus: true

platforms:
- name: ubuntu-12.04
- name: centos-6.4

suites:
- name: default
  run_list: ["recipe[git]"]
  attributes: {}
~~~

Now let's check the status of our instances:

~~~
$ kitchen list
Instance             Driver   Provisioner  Last Action
default-ubuntu-1204  Vagrant  ChefSolo     <Not Created>
default-centos-64    Vagrant  ChefSolo     <Not Created>
~~~

We're going to use two shortcuts here in the next command:

* Each Test Kitchen instance has a simple state machine that tracks where it is in its lifecyle. Given its current state and the desired state, the instance is smart enough to run all actions in between current and desired. In our next example we will take an instance from not created to verified in one command.
* Any `kitchen` subcommand that takes an instance name as an argument can take a Ruby regular expression that will be used to glob a list of instances together. This means that `kitchen test ubuntu` would run the **test** action only the ubuntu instance. Note that the **list** subcommand also takes the regex-globbing argument so feel free to experiment there. In our next example we'll select the `default-centos-64` instance with simply `64`.

Let's see how CentOS runs our cookbook:

~~~
$ kitchen verify 64
-----> Starting Kitchen (v1.0.0)
-----> Creating <default-centos-64>...
       Bringing machine 'default' up with 'virtualbox' provider...
       [default] Importing base box 'opscode-centos-6.4'...
       [default] Matching MAC address for NAT networking...
       [default] Setting the name of the VM...
       [default] Clearing any previously set forwarded ports...
       [default] Creating shared folders metadata...
       [default] Clearing any previously set network interfaces...
       [default] Preparing network interfaces based on configuration...
       [default] Forwarding ports...
       [default] -- 22 => 2222 (adapter 1)
       [default] Running 'pre-boot' VM customizations...
       [default] Booting VM...
       [default] Waiting for machine to boot. This may take a few minutes...
       [default] Machine booted and ready!
       [default] Setting hostname...
       [default] Mounting shared folders...
       Vagrant instance <default-centos-64> created.
       Finished creating <default-centos-64> (0m54.63s).
-----> Converging <default-centos-64>...
       Preparing files for transfer
       Preparing current project directory as a cookbook
       Removing non-cookbook files before transfer
-----> Installing Chef Omnibus (true)
       downloading https://www.opscode.com/chef/install.sh
         to file /tmp/install.sh
       trying wget...
       Downloading Chef  for el...
       Installing Chef
       warning: /tmp/tmp.4O86geCV/chef-.x86_64.rpm: Header V4 DSA/SHA1 Signature, key ID 83ef826a: NOKEY
Preparing...                #####  ########################################### [100%]
   1:chef                          ########################################### [100%]
       Thank you for installing Chef!
       Transfering files to <default-centos-64>
       [2013-11-30T22:16:45+00:00] INFO: Forking chef instance to converge...
       Starting Chef Client, version 11.8.0
       [2013-11-30T22:16:45+00:00] INFO: *** Chef 11.8.0 ***
       [2013-11-30T22:16:45+00:00] INFO: Chef-client pid: 2452
       [2013-11-30T22:16:45+00:00] INFO: Setting the run_list to ["recipe[git::default]"] from JSON
       [2013-11-30T22:16:45+00:00] INFO: Run List is [recipe[git::default]]
       [2013-11-30T22:16:45+00:00] INFO: Run List expands to [git::default]
       [2013-11-30T22:16:45+00:00] INFO: Starting Chef Run for default-centos-64
       [2013-11-30T22:16:45+00:00] INFO: Running start handlers
       [2013-11-30T22:16:45+00:00] INFO: Start handlers complete.
       Compiling Cookbooks...
       Converging 2 resources
       Recipe: git::default
         * package[git] action install[2013-11-30T22:16:45+00:00] INFO: Processing package[git] action install (git::default line 1)
        (up to date)
         * log[Well, that was too easy] action write[2013-11-30T22:17:17+00:00] INFO: Processing log[Well, that was too easy] action write (git::default line 3)
       [2013-11-30T22:17:17+00:00] INFO: Well, that was too easy


       [2013-11-30T22:17:17+00:00] INFO: Chef Run complete in 31.73868597 seconds
       [2013-11-30T22:17:17+00:00] INFO: Running report handlers
       [2013-11-30T22:17:17+00:00] INFO: Report handlers complete
       Chef Client finished, 1 resources updated
       Finished converging <default-centos-64> (1m16.32s).
-----> Setting up <default-centos-64>...
Fetching: thor-0.18.1.gem (100%)
Fetching: busser-0.6.0.gem (100%)
       Successfully installed thor-0.18.1
       Successfully installed busser-0.6.0
       2 gems installed
-----> Setting up Busser
       Creating BUSSER_ROOT in /tmp/busser
       Creating busser binstub
       Plugin bats installed (version 0.1.0)
-----> Running postinstall for bats plugin
             create  /tmp/bats20131130-2614-1jxkqra/bats
             create  /tmp/bats20131130-2614-1jxkqra/bats.tar.gz
       Installed Bats to /tmp/busser/vendor/bats/bin/bats
             remove  /tmp/bats20131130-2614-1jxkqra
       Finished setting up <default-centos-64> (0m44.50s).
-----> Verifying <default-centos-64>...
       Suite path directory /tmp/busser/suites does not exist, skipping.
       Uploading /tmp/busser/suites/bats/git_installed.bats (mode=0644)
-----> Running bats test suite
 ✓ git binary is found in PATH

       1 test, 0 failures
       Finished verifying <default-centos-64> (0m0.94s).
-----> Kitchen is finished. (2m56.69s)
~~~

Nice! We've verified that our cookbook works on Ubuntu 12.04 and CentOS 6.4. Since the CentOS instance will hang out for no good reason, let's kill it for now:

~~~
$ kitchen destroy
-----> Starting Kitchen (v1.0.0)
-----> Destroying <default-ubuntu-1204>...
       Finished destroying <default-ubuntu-1204> (0m0.00s).
-----> Destroying <default-centos-64>...
       [default] Forcing shutdown of VM...
       [default] Destroying VM and associated drives...
       Vagrant instance <default-centos-64> destroyed.
       Finished destroying <default-centos-64> (0m3.06s).
-----> Kitchen is finished. (0m3.36s)
~~~

Interesting. Test Kitchen tried to destroy both instances, one that was created and the other that was not. Which brings us to another tip with the `kitchen` command:

> **Any `kitchen` subcommand without an instance argument will apply to all instances.**

Let's make sure everything has been destroyed:

~~~
$ kitchen list
Instance             Driver   Provisioner  Last Action
default-ubuntu-1204  Vagrant  ChefSolo     <Not Created>
default-centos-64    Vagrant  ChefSolo     <Not Created>
~~~

There's no production code change so far but we did modify the `.kitchen.yml` file, so let's commit that:

~~~
$ git add .kitchen.yml
$ git commit -m "Add support for CentOS 6.4."
[master 386a373] Add support for CentOS 6.4.
 1 file changed, 1 insertion(+)
~~~
