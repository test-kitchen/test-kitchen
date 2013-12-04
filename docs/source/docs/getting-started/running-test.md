---
title: Running Kitchen Test
prev:
  text: "Running Kitchen Verify"
  url: "running-verify"
next:
  text: "Adding a Platform"
  url: "adding-platform"
---

Now it's time to introduce to the **test** meta-action which helps you automate all the previous actions so far into one command. Recall that we currently have our instance in a "verified" state. With this in mind, let's run `kitchen test`:

~~~
$ kitchen test default-ubuntu-1204
-----> Starting Kitchen (v1.0.0)
-----> Cleaning up any prior instances of <default-ubuntu-1204>
-----> Destroying <default-ubuntu-1204>...
       [default] Forcing shutdown of VM...
       [default] Destroying VM and associated drives...
       Vagrant instance <default-ubuntu-1204> destroyed.
       Finished destroying <default-ubuntu-1204> (0m3.06s).
-----> Testing <default-ubuntu-1204>
-----> Creating <default-ubuntu-1204>...
       Bringing machine 'default' up with 'virtualbox' provider...
       [default] Importing base box 'opscode-ubuntu-12.04'...
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
[default] Machine booted and ready!       [default] Setting hostname...
       [default] Mounting shared folders...
       Vagrant instance <default-ubuntu-1204> created.
       Finished creating <default-ubuntu-1204> (0m46.22s).
-----> Converging <default-ubuntu-1204>...
       Preparing files for transfer
       Preparing current project directory as a cookbook
       Removing non-cookbook files before transfer
-----> Installing Chef Omnibus (true)
       downloading https://www.opscode.com/chef/install.sh
         to file /tmp/install.sh
       trying wget...
Downloading Chef  for ubuntu...
Installing Chef
Selecting previously unselected package chef.
(Reading database ... 53291 files and directories currently installed.)
Unpacking chef (from .../tmp.CLdJIw55/chef__amd64.deb) ...
Setting up chef (11.8.0-1.ubuntu.12.04) ...
Thank you for installing Chef!
       Transfering files to <default-ubuntu-1204>
[2013-11-30T22:10:59+00:00] INFO: Forking chef instance to converge...
Starting Chef Client, version 11.8.0
[2013-11-30T22:10:59+00:00] INFO: *** Chef 11.8.0 ***
[2013-11-30T22:10:59+00:00] INFO: Chef-client pid: 1192
[2013-11-30T22:10:59+00:00] INFO: Setting the run_list to ["recipe[git::default]"] from JSON
[2013-11-30T22:10:59+00:00] INFO: Run List is [recipe[git::default]]
[2013-11-30T22:10:59+00:00] INFO: Run List expands to [git::default]
[2013-11-30T22:10:59+00:00] INFO: Starting Chef Run for default-ubuntu-1204
[2013-11-30T22:10:59+00:00] INFO: Running start handlers
[2013-11-30T22:10:59+00:00] INFO: Start handlers complete.
Compiling Cookbooks...
Converging 2 resources
Recipe: git::default
  * package[git] action install[2013-11-30T22:10:59+00:00] INFO: Processing package[git] action install (git::default line 1)

    - install version 1:1.7.9.5-1 of package git

  * log[Well, that was too easy] action write[2013-11-30T22:11:24+00:00] INFO: Processing log[Well, that was too easy] action write (git::default line 3)
[2013-11-30T22:11:24+00:00] INFO: Well, that was too easy


[2013-11-30T22:11:24+00:00] INFO: Chef Run complete in 24.365178204 seconds
[2013-11-30T22:11:24+00:00] INFO: Running report handlers
[2013-11-30T22:11:24+00:00] INFO: Report handlers complete
Chef Client finished, 2 resources updated
       Finished converging <default-ubuntu-1204> (0m45.17s).
-----> Setting up <default-ubuntu-1204>...
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
      create  /tmp/bats20131130-4164-uxjzr4/bats
      create  /tmp/bats20131130-4164-uxjzr4/bats.tar.gz
Installed Bats to /tmp/busser/vendor/bats/bin/bats
      remove  /tmp/bats20131130-4164-uxjzr4
       Finished setting up <default-ubuntu-1204> (0m4.89s).
-----> Verifying <default-ubuntu-1204>...
       Suite path directory /tmp/busser/suites does not exist, skipping.
Uploading /tmp/busser/suites/bats/git_installed.bats (mode=0644)
-----> Running bats test suite
 ✓ git binary is found in PATH

       1 test, 0 failures

       Finished verifying <default-ubuntu-1204> (0m0.98s).
-----> Destroying <default-ubuntu-1204>...
       [default] Forcing shutdown of VM...
       [default] Destroying VM and associated drives...
       Vagrant instance <default-ubuntu-1204> destroyed.
       Finished destroying <default-ubuntu-1204> (0m3.48s).
       Finished testing <default-ubuntu-1204> (1m43.82s).
-----> Kitchen is finished. (1m44.11s)
~~~

There's only one remaining action left that needs a mention: the **Destroy Action** which... destroys the instance. With this in mind, here's what Test Kitchen is doing in the **Test Action**:

1. Destroys the instance if it exists (`Cleaning up any prior instances of <default-ubuntu-1204>`)
2. Creates the instance (`Creating <default-ubuntu-1204>`)
3. Converges the instance (`Converging <default-ubuntu-1204>`)
4. Sets up Busser and runner plugins on the instance (`Setting up <default-ubuntu-1204>`)
5. Verifies the instance by running Busser tests (`Verifying <default-ubuntu-1204>`)
6. Destroys the instance (`Destroying <default-ubuntu-1204>`)

A few details with regards to test:

* Test Kitchen will abort the run on the instance at the first sign of trouble. This means that if your Chef run fails then Busser won't be installed and the instance won't be destroyed. This gives you a chance to inspect the state of the instance and fix any issues.
* The behavior of the final destroy action can be overridden if desired. Check out the documentation for the `--destroy` flag using `kitchen help test`.
* The primary use case in mind for this meta-action is in a Continuous Integration environment or a command for developers to run before check in or after a fresh clone. If you're using this in your test-code-verify development cycle it's going to quickly become very slow and frustrating. You're better off running the **converge** and **verify** subcommands in development and save the **test** subcommand when you need to verify the end-to-end run of your code.

Finally, let's check the status of the instance:

~~~
$ kitchen list
Instance             Driver   Provisioner  Last Action
default-ubuntu-1204  Vagrant  ChefSolo     <Not Created>
~~~

Back to square one.
