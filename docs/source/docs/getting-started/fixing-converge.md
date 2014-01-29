---
title: Fixing Converge
prev:
  text: "Dynamic Configuration"
  url: "dynamic-configuration"
next:
  text: "Add a New Feature"
  url: "adding-feature"
---

News of the amazing Git cookbook starts to spread to all corners of your workplace. Now a colleague has expressed interest in running the cookbook on a fleet of older Ubuntu 10.04 systems.  You mention that 2009 called, and it wants its iPhone 3 and Three Wolf Moon t-shirt back, but they just look at you blankly.  You muse over whether your not inconsiderable talents are wasted in this job, and then press on.  No problem, they should be good to go, right? Just to be sure let's add explicit testing for this platform.

Open `.kitchen.yml` in your editor and add a `ubuntu-10.04` entry to the platforms list:

~~~yaml
---
driver:
  name: vagrant

provisioner:
  name: chef_solo

platforms:
  - name: ubuntu-12.04
  - name: ubuntu-10.04
  - name: centos-6.4

suites:
  - name: default
    run_list:
      - recipe[git::default]
    attributes:
~~~

And run `kitchen list` to confirm the introduction of our latest instance:

~~~
$ kitchen list
Instance             Driver   Provisioner  Last Action
default-ubuntu-1204  Vagrant  ChefSolo     <Not Created>
default-ubuntu-1004  Vagrant  ChefSolo     <Not Created>
default-centos-64    Vagrant  ChefSolo     <Not Created>
~~~

Now we'll run the **test** subcommand and go grab a coffee:

~~~
$ kitchen test 10
-----> Starting Kitchen (v1.0.0)
-----> Cleaning up any prior instances of <default-ubuntu-1004>
-----> Destroying <default-ubuntu-1004>...
       Finished destroying <default-ubuntu-1004> (0m0.00s).
-----> Testing <default-ubuntu-1004>
-----> Creating <default-ubuntu-1004>...
       Bringing machine 'default' up with 'virtualbox' provider...
       [default] Importing base box 'opscode-ubuntu-10.04'...
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
[default] Waiting for machine to boot. This may take a few minutes...       [default] Machine booted and ready!
       [default] Setting hostname...
       [default] Mounting shared folders...
       Vagrant instance <default-ubuntu-1004> created.
       Finished creating <default-ubuntu-1004> (0m39.75s).
-----> Converging <default-ubuntu-1004>...
       Preparing files for transfer
       Preparing current project directory as a cookbook
       Removing non-cookbook files before transfer
-----> Installing Chef Omnibus (true)
       downloading https://www.opscode.com/chef/install.sh
         to file /tmp/install.sh
       trying wget...
       Downloading Chef  for ubuntu...
       Installing Chef
       Selecting previously deselected package chef.
(Reading database ... 60%...
(Reading database ... 44103 files and directories currently installed.)
       Unpacking chef (from .../tmp.ruCJgCrm/chef__amd64.deb) ...
       Setting up chef (11.8.0-1.ubuntu.10.04) ...
       Thank you for installing Chef!

       Transfering files to <default-ubuntu-1004>
       [2013-11-30T22:22:25+00:00] INFO: Forking chef instance to converge...
       Starting Chef Client, version 11.8.0
       [2013-11-30T22:22:25+00:00] INFO: *** Chef 11.8.0 ***
       [2013-11-30T22:22:25+00:00] INFO: Chef-client pid: 976
       [2013-11-30T22:22:25+00:00] INFO: Setting the run_list to ["recipe[git::default]"] from JSON
       [2013-11-30T22:22:25+00:00] INFO: Run List is [recipe[git::default]]
       [2013-11-30T22:22:25+00:00] INFO: Run List expands to [git::default]
       [2013-11-30T22:22:25+00:00] INFO: Starting Chef Run for default-ubuntu-1004
       [2013-11-30T22:22:25+00:00] INFO: Running start handlers
       [2013-11-30T22:22:25+00:00] INFO: Start handlers complete.
       Compiling Cookbooks...
       Converging 2 resources
       Recipe: git::default
         * package[git] action install[2013-11-30T22:22:25+00:00] INFO: Processing package[git] action install (git::default line 1)

       ================================================================================
       Error executing action `install` on resource 'package[git]'
       ================================================================================


       Chef::Exceptions::Package
       -------------------------
       git has no candidate in the apt-cache


       Resource Declaration:
       ---------------------
       # In /tmp/kitchen/cookbooks/git/recipes/default.rb

         1: package "git"
         2:



       Compiled Resource:
       ------------------
       # Declared in /tmp/kitchen/cookbooks/git/recipes/default.rb:1:in `from_file'

       package("git") do
         action :install
         retries 0
         retry_delay 2
         package_name "git"
         cookbook_name :git
         recipe_name "default"
       end



       [2013-11-30T22:22:26+00:00] INFO: Running queued delayed notifications before re-raising exception
       [2013-11-30T22:22:26+00:00] ERROR: Running exception handlers
       [2013-11-30T22:22:26+00:00] ERROR: Exception handlers complete
       [2013-11-30T22:22:26+00:00] FATAL: Stacktrace dumped to /tmp/kitchen/cache/chef-stacktrace.out
       Chef Client failed. 0 resources updated
       [2013-11-30T22:22:26+00:00] ERROR: package[git] (git::default line 1) had an error: Chef::Exceptions::Package: git has no candidate in the apt-cache
       [2013-11-30T22:22:26+00:00] FATAL: Chef::Exceptions::ChildConvergeError: Chef run process exited unsuccessfully (exit code 1)
>>>>>> Converge failed on instance <default-ubuntu-1004>.
>>>>>> Please see .kitchen/logs/default-ubuntu-1004.log for more details
>>>>>> ------Exception-------
>>>>>> Class: Kitchen::ActionFailed
>>>>>> Message: SSH exited (1) for command: [sudo -E chef-solo --config /tmp/kitchen/solo.rb --json-attributes /tmp/kitchen/dna.json  --log_level info]
>>>>>> ----------------------
~~~

Oh noes! Argh, why!? Let's login to the instance and see if we can figure out what the correct package is:

~~~
$ kitchen login 10
Linux default-ubuntu-1004 2.6.32-38-server #83-Ubuntu SMP Wed Jan 4 11:26:59 UTC 2012 x86_64 GNU/Linux
Ubuntu 10.04.4 LTS

Welcome to the Ubuntu Server!
 * Documentation:  http://www.ubuntu.com/server/doc
New release 'precise' available.
Run 'do-release-upgrade' to upgrade to it.

Last login: Sat Nov 30 22:22:24 2013 from 10.0.2.2
vagrant@default-ubuntu-1004:~$ sudo apt-cache search git | grep ^git
git-buildpackage - Suite to help with Debian packages in Git repositories
git-cola - highly caffeinated git gui
git-load-dirs - Import upstream archives into git
gitg - git repository viewer for gtk+/GNOME
gitmagic - guide about Git version control system
gitosis - git repository hosting application
gitpkg - tools for maintaining Debian packages with git
gitstats - statistics generator for git repositories
git-core - fast, scalable, distributed revision control system
git-doc - fast, scalable, distributed revision control system (documentation)
gitk - fast, scalable, distributed revision control system (revision tree visualizer)
git-arch - fast, scalable, distributed revision control system (arch interoperability)
git-cvs - fast, scalable, distributed revision control system (cvs interoperability)
git-daemon-run - fast, scalable, distributed revision control system (git-daemon service)
git-email - fast, scalable, distributed revision control system (email add-on)
git-gui - fast, scalable, distributed revision control system (GUI)
git-svn - fast, scalable, distributed revision control system (svn interoperability)
gitweb - fast, scalable, distributed revision control system (web interface)
vagrant@default-ubuntu-1004:~$ exit
logout
Connection to 127.0.0.1 closed.
~~~

Okay, it looks like we want to install the `git-core` package for this release of Ubuntu. Let's fix this up back in the default recipe. Open up `recipes/default.rb` and edit to something like:

~~~ruby
if node['platform'] == "ubuntu" && node['platform_version'].to_f <= 10.04
  package "git-core"
else
  package "git"
end

log "Well, that was too easy"
~~~

This may not be pretty but let's verify that it works first on Ubuntu 10.04:

~~~
$ kitchen verify 10
-----> Starting Kitchen (v1.0.0)
-----> Converging <default-ubuntu-1004>...
       Preparing files for transfer
       Preparing current project directory as a cookbook
       Removing non-cookbook files before transfer
       Transfering files to <default-ubuntu-1004>
       [2013-11-30T22:25:56+00:00] INFO: Forking chef instance to converge...
       Starting Chef Client, version 11.8.0
       [2013-11-30T22:25:56+00:00] INFO: *** Chef 11.8.0 ***
       [2013-11-30T22:25:56+00:00] INFO: Chef-client pid: 1172
       [2013-11-30T22:25:57+00:00] INFO: Setting the run_list to ["recipe[git::default]"] from JSON
       [2013-11-30T22:25:57+00:00] INFO: Run List is [recipe[git::default]]
       [2013-11-30T22:25:57+00:00] INFO: Run List expands to [git::default]
       [2013-11-30T22:25:57+00:00] INFO: Starting Chef Run for default-ubuntu-1004
       [2013-11-30T22:25:57+00:00] INFO: Running start handlers
       [2013-11-30T22:25:57+00:00] INFO: Start handlers complete.
       Compiling Cookbooks...
       Converging 2 resources
       Recipe: git::default
         * package[git-core] action install[2013-11-30T22:25:57+00:00] INFO: Processing package[git-core] action install (git::default line 2)

           - install version 1:1.7.0.4-1ubuntu0.2 of package git-core

         * log[Well, that was too easy] action write[2013-11-30T22:26:14+00:00] INFO: Processing log[Well, that was too easy] action write (git::default line 7)
       [2013-11-30T22:26:14+00:00] INFO: Well, that was too easy


       [2013-11-30T22:26:14+00:00] INFO: Chef Run complete in 17.21367679 seconds
       [2013-11-30T22:26:14+00:00] INFO: Running report handlers
       [2013-11-30T22:26:14+00:00] INFO: Report handlers complete
       Chef Client finished, 2 resources updated
       Finished converging <default-ubuntu-1004> (0m18.48s).
-----> Setting up <default-ubuntu-1004>...
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
             create  /tmp/bats20131130-1964-lmhebd/bats
             create  /tmp/bats20131130-1964-lmhebd/bats.tar.gz
       Installed Bats to /tmp/busser/vendor/bats/bin/bats
             remove  /tmp/bats20131130-1964-lmhebd
       Finished setting up <default-ubuntu-1004> (0m4.42s).
-----> Verifying <default-ubuntu-1004>...
       Suite path directory /tmp/busser/suites does not exist, skipping.
       Uploading /tmp/busser/suites/bats/git_installed.bats (mode=0644)
-----> Running bats test suite
 ✓ git binary is found in PATH

       1 test, 0 failures
       Finished verifying <default-ubuntu-1004> (0m0.89s).
-----> Kitchen is finished. (0m24.20s)
~~~

Back to green, good. Let's verify that the other two instances are still good. We'll use a Ruby regular expression to glob the two other instances into one Test Kitchen command:

~~~
$ kitchen verify '(12|64)'
-----> Starting Kitchen (v1.0.0)
-----> Creating <default-ubuntu-1204>...
       Bringing machine 'default' up with 'virtualbox' provider...
       [default] Importing base box 'opscode-ubuntu-12.04'...
       [default] Matching MAC address for NAT networking...
       [default] Setting the name of the VM...
       [default] Clearing any previously set forwarded ports...
       [default] Fixed port collision for 22 => 2222. Now on port 2200.
       [default] Creating shared folders metadata...
       [default] Clearing any previously set network interfaces...
       [default] Preparing network interfaces based on configuration...
       [default] Forwarding ports...
       [default] -- 22 => 2200 (adapter 1)
       [default] Running 'pre-boot' VM customizations...
       [default] Booting VM...
       [default] Waiting for machine to boot. This may take a few minutes...
       [default] Machine booted and ready!
       [default] Setting hostname...
       [default] Mounting shared folders...
       Vagrant instance <default-ubuntu-1204> created.
       Finished creating <default-ubuntu-1204> (0m48.28s).
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
Unpacking chef (from .../tmp.K5ozaWkv/chef__amd64.deb) ...
Setting up chef (11.8.0-1.ubuntu.12.04) ...
Thank you for installing Chef!
       Transfering files to <default-ubuntu-1204>
[2013-11-30T22:28:54+00:00] INFO: Forking chef instance to converge...
Starting Chef Client, version 11.8.0
[2013-11-30T22:28:55+00:00] INFO: *** Chef 11.8.0 ***
[2013-11-30T22:28:55+00:00] INFO: Chef-client pid: 1172
[2013-11-30T22:28:55+00:00] INFO: Setting the run_list to ["recipe[git::default]"] from JSON
[2013-11-30T22:28:55+00:00] INFO: Run List is [recipe[git::default]]
[2013-11-30T22:28:55+00:00] INFO: Run List expands to [git::default]
[2013-11-30T22:28:55+00:00] INFO: Starting Chef Run for default-ubuntu-1204
[2013-11-30T22:28:55+00:00] INFO: Running start handlers
[2013-11-30T22:28:55+00:00] INFO: Start handlers complete.
Compiling Cookbooks...
Converging 2 resources
Recipe: git::default
  * package[git] action install[2013-11-30T22:28:55+00:00] INFO: Processing package[git] action install (git::default line 4)

    - install version 1:1.7.9.5-1 of package git

  * log[Well, that was too easy] action write[2013-11-30T22:29:16+00:00] INFO: Processing log[Well, that was too easy] action write (git::default line 7)
[2013-11-30T22:29:16+00:00] INFO: Well, that was too easy


[2013-11-30T22:29:16+00:00] INFO: Chef Run complete in 21.557709331 seconds
[2013-11-30T22:29:16+00:00] INFO: Running report handlers
[2013-11-30T22:29:16+00:00] INFO: Report handlers complete
Chef Client finished, 2 resources updated
       Finished converging <default-ubuntu-1204> (0m55.32s).
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
      create  /tmp/bats20131130-4144-d2coam/bats
      create  /tmp/bats20131130-4144-d2coam/bats.tar.gz
Installed Bats to /tmp/busser/vendor/bats/bin/bats
      remove  /tmp/bats20131130-4144-d2coam
       Finished setting up <default-ubuntu-1204> (0m4.96s).
-----> Verifying <default-ubuntu-1204>...
       Suite path directory /tmp/busser/suites does not exist, skipping.
Uploading /tmp/busser/suites/bats/git_installed.bats (mode=0644)
-----> Running bats test suite
 ✓ git binary is found in PATH

1 test, 0 failures
       Finished verifying <default-ubuntu-1204> (0m0.86s).
-----> Creating <default-centos-64>...
       Bringing machine 'default' up with 'virtualbox' provider...
       [default] Importing base box 'opscode-centos-6.4'...
       [default] Matching MAC address for NAT networking...
       [default] Setting the name of the VM...
       [default] Clearing any previously set forwarded ports...
       [default] Fixed port collision for 22 => 2222. Now on port 2201.
       [default] Creating shared folders metadata...
       [default] Clearing any previously set network interfaces...
       [default] Preparing network interfaces based on configuration...
       [default] Forwarding ports...
       [default] -- 22 => 2201 (adapter 1)
       [default] Running 'pre-boot' VM customizations...
       [default] Booting VM...
[default] Waiting for machine to boot. This may take a few minutes...       [default] Machine booted and ready!
       [default] Setting hostname...
       [default] Mounting shared folders...
       Vagrant instance <default-centos-64> created.
       Finished creating <default-centos-64> (0m54.26s).
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
       warning: /tmp/tmp.YE63OB3z/chef-.x86_64.rpm: Header V4 DSA/SHA1 Signature, key ID 83ef826a: NOKEY
Preparing...                #####  ########################################### [100%]
   1:chef                          ########################################### [100%]
       Thank you for installing Chef!
       Transfering files to <default-centos-64>
       [2013-11-30T22:31:01+00:00] INFO: Forking chef instance to converge...
       Starting Chef Client, version 11.8.0
       [2013-11-30T22:31:01+00:00] INFO: *** Chef 11.8.0 ***
       [2013-11-30T22:31:01+00:00] INFO: Chef-client pid: 2471
       [2013-11-30T22:31:02+00:00] INFO: Setting the run_list to ["recipe[git::default]"] from JSON
       [2013-11-30T22:31:02+00:00] INFO: Run List is [recipe[git::default]]
       [2013-11-30T22:31:02+00:00] INFO: Run List expands to [git::default]
       [2013-11-30T22:31:02+00:00] INFO: Starting Chef Run for default-centos-64
       [2013-11-30T22:31:02+00:00] INFO: Running start handlers
       [2013-11-30T22:31:02+00:00] INFO: Start handlers complete.
       Compiling Cookbooks...
Converging 2 resources
       Recipe: git::default
         * package[git] action install[2013-11-30T22:31:02+00:00] INFO: Processing package[git] action install (git::default line 4)
        (up to date)
         * log[Well, that was too easy] action write[2013-11-30T22:31:55+00:00] INFO: Processing log[Well, that was too easy] action write (git::default line 7)
       [2013-11-30T22:31:55+00:00] INFO: Well, that was too easy


       [2013-11-30T22:31:55+00:00] INFO: Chef Run complete in 52.919344438 seconds
       [2013-11-30T22:31:55+00:00] INFO: Running report handlers
       [2013-11-30T22:31:55+00:00] INFO: Report handlers complete
       Chef Client finished, 1 resources updated
       Finished converging <default-centos-64> (1m39.61s).
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
             create  /tmp/bats20131130-2633-10aemp/bats
             create  /tmp/bats20131130-2633-10aemp/bats.tar.gz
       Installed Bats to /tmp/busser/vendor/bats/bin/bats
             remove  /tmp/bats20131130-2633-10aemp
       Finished setting up <default-centos-64> (0m43.89s).
-----> Verifying <default-centos-64>...
       Suite path directory /tmp/busser/suites does not exist, skipping.
       Uploading /tmp/busser/suites/bats/git_installed.bats (mode=0644)
-----> Running bats test suite
 ✓ git binary is found in PATH

       1 test, 0 failures
       Finished verifying <default-centos-64> (0m0.90s).
-----> Kitchen is finished. (5m8.42s)
$ echo $?
0
~~~

We've successfully verified all three instances, so let's shut them down.

~~~
$ kitchen destroy
-----> Starting Kitchen (v1.0.0)
-----> Destroying <default-ubuntu-1204>...
       [default] Forcing shutdown of VM...
       [default] Destroying VM and associated drives...
       Vagrant instance <default-ubuntu-1204> destroyed.
       Finished destroying <default-ubuntu-1204> (0m3.37s).
-----> Destroying <default-ubuntu-1004>...
       [default] Forcing shutdown of VM...
       [default] Destroying VM and associated drives...
       Vagrant instance <default-ubuntu-1004> destroyed.
       Finished destroying <default-ubuntu-1004> (0m2.94s).
-----> Destroying <default-centos-64>...
       [default] Forcing shutdown of VM...
       [default] Destroying VM and associated drives...
       Vagrant instance <default-centos-64> destroyed.
       Finished destroying <default-centos-64> (0m2.97s).
-----> Kitchen is finished. (0m9.60s)
~~~

And finally commit our code updates:

~~~
$ git add .kitchen.yml recipes/default.rb
$ git commit -m "Add support for Ubuntu 10.04."
[master 0c49ced] Add support for Ubuntu 10.04.
 2 files changed, 6 insertions(+), 1 deletion(-)
~~~
