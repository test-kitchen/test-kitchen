---
title: Adding a Platform
prev:
  text: "Running Kitchen Test"
  url: "running-test"
next:
  text: "Fixing Converge"
  url: "fixing-converge"
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
default-ubuntu-1204  Vagrant  Chef Solo    <Not Created>
default-centos-64    Vagrant  Chef Solo    <Not Created>
~~~

We're going to use two shortcuts here in the next command:

* Each Test Kitchen instance has a simple state machine that tracks where it is in its lifecyle. Given its current state and the desired state, the instance is smart enough to run all actions in between current and desired. In our next example we will take an instance from not created to verified in one command.
* Any `kitchen` subcommand that takes an instance name as an argument can take a Ruby regular expression that will be used to glob a list of instances together. This means that `kitchen test ubuntu` would run the **test** action only the ubuntu instance. Note that the **list** subcommand also takes the regex-globbing argument so feel free to experiment there. In our next example we'll select the `default-centos-64` instance with simply `64`.

Let's see how CentOS runs our cookbook:

~~~
$ kitchen verify 64
-----> Starting Kitchen (v1.0.0.beta.3)
-----> Creating <default-centos-64>
       [kitchen::driver::vagrant command] BEGIN (vagrant up --no-provision)
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
       [kitchen::driver::vagrant command] END (0m51.59s)
       [kitchen::driver::vagrant command] BEGIN (vagrant ssh-config)
       [kitchen::driver::vagrant command] END (0m0.87s)
       Vagrant instance <default-centos-64> created.
       Finished creating <default-centos-64> (0m57.25s).
-----> Converging <default-centos-64>
-----> Installing Chef Omnibus (true)
       --2013-10-17 06:52:15--  https://www.opscode.com/chef/install.sh
Resolving www.opscode.com...        184.106.28.82
       Connecting to www.opscode.com|184.106.28.82|:443...
       connected.
HTTP request sent, awaiting response...        200 OK
       Length: 6790 (6.6K) [application/x-sh]
       Saving to: `STDOUT'

 0% [                                       ] 0           --.-K/s
100%[======================================>] 6,790       --.-K/s   in 0s

       2013-10-17 06:52:20 (336 MB/s) - written to stdout [6790/6790]

       Downloading Chef  for el...
       Installing Chef
       warning: /tmp/tmp.VHOrEPIv/chef-.x86_64.rpm: Header V4 DSA/SHA1 Signature, key ID 83ef826a: NOKEY
Preparing...                #####  ########################################### [100%]
   1:chef                          ########################################### [100%]
       Thank you for installing Chef!
       Preparing current project directory as a cookbook
       Removing non-cookbook files in sandbox
       Uploaded /var/folders/ld/ykg04kvx5y53v7qkhpp254y40000gn/T/default-centos-64-sandbox-20131017-65316-1copg0l/cookbooks/git/metadata.rb (27 bytes)
       Uploaded /var/folders/ld/ykg04kvx5y53v7qkhpp254y40000gn/T/default-centos-64-sandbox-20131017-65316-1copg0l/cookbooks/git/recipes/default.rb (45 bytes)
       Uploaded /var/folders/ld/ykg04kvx5y53v7qkhpp254y40000gn/T/default-centos-64-sandbox-20131017-65316-1copg0l/dna.json (28 bytes)
       Uploaded /var/folders/ld/ykg04kvx5y53v7qkhpp254y40000gn/T/default-centos-64-sandbox-20131017-65316-1copg0l/solo.rb (166 bytes)
       [2013-10-17T06:53:02+00:00] INFO: Forking chef instance to converge...
       Starting Chef Client, version 11.6.2
       [2013-10-17T06:53:02+00:00] INFO: *** Chef 11.6.2 ***
       [2013-10-17T06:53:02+00:00] INFO: Setting the run_list to ["recipe[git]"] from JSON
       [2013-10-17T06:53:02+00:00] INFO: Run List is [recipe[git]]
       [2013-10-17T06:53:02+00:00] INFO: Run List expands to [git]
       [2013-10-17T06:53:02+00:00] INFO: Starting Chef Run for default-centos-64
       [2013-10-17T06:53:02+00:00] INFO: Running start handlers
       [2013-10-17T06:53:02+00:00] INFO: Start handlers complete.
       Compiling Cookbooks...
       Converging 2 resources
       Recipe: git::default
         * package[git] action install

       [2013-10-17T06:53:02+00:00] INFO: Processing package[git] action install (git::default line 1)
        (up to date)
         * log[Well, that was too easy] action write
       [2013-10-17T06:54:05+00:00] INFO: Processing log[Well, that was too easy] action write (git::default line 3)
       [2013-10-17T06:54:05+00:00] INFO: Well, that was too easy


       [2013-10-17T06:54:05+00:00] INFO: Chef Run complete in 62.525344754 seconds
       [2013-10-17T06:54:05+00:00] INFO: Running report handlers
       [2013-10-17T06:54:05+00:00] INFO: Report handlers complete
       Chef Client finished, 1 resources updated
       Finished converging <default-centos-64> (1m50.16s).
-----> Setting up <default-centos-64>
Fetching: thor-0.18.1.gem (100%)
Fetching: busser-0.4.1.gem (100%)
       Successfully installed thor-0.18.1
       Successfully installed busser-0.4.1
       2 gems installed
-----> Setting up Busser
       Creating BUSSER_ROOT in /opt/busser
       Creating busser binstub
       Plugin bats installed (version 0.1.0)
-----> Running postinstall for bats plugin
             create  /tmp/bats20131017-2604-10io6m5/bats
             create  /tmp/bats20131017-2604-10io6m5/bats.tar.gz
       Installed Bats to /opt/busser/vendor/bats/bin/bats
             remove  /tmp/bats20131017-2604-10io6m5
       Finished setting up <default-centos-64> (0m54.66s).
-----> Verifying <default-centos-64>
       Suite path directory /opt/busser/suites does not exist, skipping.
       Uploading /opt/busser/suites/bats/git_installed.bats (mode=0644)
-----> Running bats test suite
       1..1
       ok 1 git binary is found in PATH
       Finished verifying <default-centos-64> (0m1.11s).
-----> Kitchen is finished. (3m43.47s)
~~~

Nice! We've verified that our cookbook works on Ubuntu 12.04 and CentOS 6.4. Since the CentOS instance will hang out for no good reason, let's kill it for now:

~~~
$ kitchen destroy
-----> Starting Kitchen (v1.0.0.beta.3)
-----> Destroying <default-ubuntu-1204>
       Finished destroying <default-ubuntu-1204> (0m0.00s).
-----> Destroying <default-centos-64>
       [kitchen::driver::vagrant command] BEGIN (vagrant destroy -f)
       [default] Forcing shutdown of VM...
       [default] Destroying VM and associated drives...
       [kitchen::driver::vagrant command] END (0m2.79s)
       Vagrant instance <default-centos-64> destroyed.
       Finished destroying <default-centos-64> (0m3.09s).
-----> Kitchen is finished. (0m3.39s)
~~~

Interesting. Test Kitchen tried to destroy both instances, one that was created and the other that was not. Which brings us to another tip with the `kitchen` command:

> **Any `kitchen` subcommand without an instance argument will apply to all instances.**

Let's make sure everything has been destroyed:

~~~
$ kitchen list
Instance             Driver   Provisioner  Last Action
default-ubuntu-1204  Vagrant  Chef Solo    <Not Created>
default-centos-64    Vagrant  Chef Solo    <Not Created>
~~~

There's no production code change so far but we did modify the `.kitchen.yml` file, so let's commit that:

~~~
$ git add .kitchen.yml
> git commit -m "Add support for CentOS 6.4."
[master 528ac72] Add support for CentOS 6.4.
 1 file changed, 1 insertion(+)
~~~
