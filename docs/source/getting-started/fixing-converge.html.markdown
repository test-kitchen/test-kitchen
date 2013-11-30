---
title: Fixing Converge
---

News of the amazing Git cookbook starts to spread to all corners of your workplace. Now a colleague has expressed interest in running the cookbook on a fleet of older Ubuntu 10.04 systems. No problem, they should be good to go, right? Just to be sure let's add explicit testing for this platform.

Open `.kitchen.yml` in your editor and add a `ubuntu-10.04` entry to the platforms list:

```yaml
---
driver_plugin: vagrant
driver_config:
  require_chef_omnibus: true

platforms:
- name: ubuntu-12.04
- name: ubuntu-10.04
- name: centos-6.4

suites:
- name: default
  run_list: ["recipe[git]"]
  attributes: {}
```

And run `kitchen list` to confirm the introduction of our latest instance:

```
$ kitchen list
Instance             Driver   Provisioner  Last Action
default-ubuntu-1204  Vagrant  Chef Solo    <Not Created>
default-ubuntu-1004  Vagrant  Chef Solo    <Not Created>
default-centos-64    Vagrant  Chef Solo    <Not Created>
```

Now we'll run the **test** subcommand and go grab a coffee:

```
$ kitchen test 10
-----> Starting Kitchen (v1.0.0.beta.3)
-----> Cleaning up any prior instances of <default-ubuntu-1004>
-----> Destroying <default-ubuntu-1004>
       Finished destroying <default-ubuntu-1004> (0m0.00s).
-----> Testing <default-ubuntu-1004>
-----> Creating <default-ubuntu-1004>
       [kitchen::driver::vagrant command] BEGIN (vagrant up --no-provision)
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
[default] Waiting for machine to boot. This may take a few minutes...[default] Machine booted and ready!       [default] Setting hostname...
       [default] Mounting shared folders...
       [kitchen::driver::vagrant command] END (0m47.10s)
       [kitchen::driver::vagrant command] BEGIN (vagrant ssh-config)
       [kitchen::driver::vagrant command] END (0m1.09s)
       Vagrant instance <default-ubuntu-1004> created.
       Finished creating <default-ubuntu-1004> (0m52.71s).
-----> Converging <default-ubuntu-1004>
-----> Installing Chef Omnibus (true)
       --2013-10-21 03:24:31--  https://www.opscode.com/chef/install.sh
       Resolving www.opscode.com... 184.106.28.83
       Connecting to www.opscode.com|184.106.28.83|:443...
       connected.
HTTP request sent, awaiting response...        200 OK
       Length: 6790 (6.6K) [application/x-sh]
       Saving to: `STDOUT'

100%[======================================>] 6,790       --.-K/s   in 0s

       2013-10-21 03:24:31 (714 MB/s) - written to stdout [6790/6790]

       Downloading Chef  for ubuntu...
       Installing Chef
       Selecting previously deselected package chef.
       (Reading database ...
(Reading database ... 44103 files and directories currently installed.)
       Unpacking chef (from .../tmp.0jn9i61M/chef__amd64.deb) ...
       Setting up chef (11.6.2-1.ubuntu.10.04) ...
       Thank you for installing Chef!

       Preparing current project directory as a cookbook
       Removing non-cookbook files in sandbox
       Uploaded /tmp/default-ubuntu-1004-sandbox-20131020-93846-qtdywv/cookbooks/git/metadata.rb (27 bytes)
       Uploaded /tmp/default-ubuntu-1004-sandbox-20131020-93846-qtdywv/cookbooks/git/recipes/default.rb (45 bytes)
       Uploaded /tmp/default-ubuntu-1004-sandbox-20131020-93846-qtdywv/dna.json (28 bytes)
       Uploaded /tmp/default-ubuntu-1004-sandbox-20131020-93846-qtdywv/solo.rb (168 bytes)
       [2013-10-21T03:24:55+00:00] INFO: Forking chef instance to converge...
       Starting Chef Client, version 11.6.2
       [2013-10-21T03:24:55+00:00] INFO: *** Chef 11.6.2 ***
       [2013-10-21T03:24:56+00:00] INFO: Setting the run_list to ["recipe[git]"] from JSON
       [2013-10-21T03:24:56+00:00] INFO: Run List is [recipe[git]]
       [2013-10-21T03:24:56+00:00] INFO: Run List expands to [git]
       [2013-10-21T03:24:56+00:00] INFO: Starting Chef Run for default-ubuntu-1004
       [2013-10-21T03:24:56+00:00] INFO: Running start handlers
       [2013-10-21T03:24:56+00:00] INFO: Start handlers complete.
       Compiling Cookbooks...
       Converging 2 resources
       Recipe: git::default
         * package[git] action install[2013-10-21T03:24:56+00:00] INFO: Processing package[git] action install (git::default line 1)

       ================================================================================
       Error executing action `install` on resource 'package[git]'
       ================================================================================


       Chef::Exceptions::Package
       -------------------------
       git has no candidate in the apt-cache


       Resource Declaration:
       ---------------------
       # In /tmp/kitchen-chef-solo/cookbooks/git/recipes/default.rb

         1: package "git"
         2:



       Compiled Resource:
       ------------------
       # Declared in /tmp/kitchen-chef-solo/cookbooks/git/recipes/default.rb:1:in `from_file'

       package("git") do
         action :install
         retries 0
         retry_delay 2
         package_name "git"
         cookbook_name :git
         recipe_name "default"
       end



       [2013-10-21T03:24:56+00:00] INFO: Running queued delayed notifications before re-raising exception
       [2013-10-21T03:24:56+00:00] ERROR: Running exception handlers
       [2013-10-21T03:24:56+00:00] ERROR: Exception handlers complete
       [2013-10-21T03:24:56+00:00] FATAL: Stacktrace dumped to /tmp/kitchen-chef-solo/cache/chef-stacktrace.out
       Chef Client failed. 0 resources updated
       [2013-10-21T03:24:56+00:00] FATAL: Chef::Exceptions::ChildConvergeError: Chef run process exited unsuccessfully (exit code 1)
>>>>>> Converge failed on instance <default-ubuntu-1004>.
>>>>>> Please see .kitchen/logs/default-ubuntu-1004.log for more details
>>>>>> ------Exception-------
>>>>>> Class: Kitchen::ActionFailed
>>>>>> Message: SSH exited (1) for command: [sudo -E chef-solo --config /tmp/kitchen-chef-solo/solo.rb --json-attributes /tmp/kitchen-chef-solo/dna.json  --log_level info]
>>>>>> ----------------------
```

Oh noes! Argh, why!? Let's login to the instance and see if we can figure out what the correct package is:

```
$ kitchen login 10
Linux default-ubuntu-1004 2.6.32-38-server #83-Ubuntu SMP Wed Jan 4 11:26:59 UTC 2012 x86_64 GNU/Linux
Ubuntu 10.04.4 LTS

Welcome to the Ubuntu Server!
 * Documentation:  http://www.ubuntu.com/server/doc
New release 'precise' available.
Run 'do-release-upgrade' to upgrade to it.

Last login: Mon Oct 21 03:24:54 2013 from 10.0.2.2
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
```

Okay, it looks like we want to install the `git-core` package for this release of Ubuntu. Let's fix this up back in the default recipe. Open up `recipes/default.rb` and edit to something like:

```ruby
if node['platform'] == "ubuntu" && node['platform_version'].to_f <= 10.04
  package "git-core"
else
  package "git"
end

log "Well, that was too easy"
```

This may not be pretty but let's verify that it works first on Ubuntu 10.04:

```
> kitchen verify 10
-----> Starting Kitchen (v1.0.0.beta.3)
-----> Converging <default-ubuntu-1004>
       Preparing current project directory as a cookbook
       Removing non-cookbook files in sandbox
       Uploaded /tmp/default-ubuntu-1004-sandbox-20131020-94521-1haj8kg/cookbooks/git/metadata.rb (27 bytes)
       Uploaded /tmp/default-ubuntu-1004-sandbox-20131020-94521-1haj8kg/cookbooks/git/recipes/default.rb (151 bytes)
       Uploaded /tmp/default-ubuntu-1004-sandbox-20131020-94521-1haj8kg/dna.json (28 bytes)
       Uploaded /tmp/default-ubuntu-1004-sandbox-20131020-94521-1haj8kg/solo.rb (168 bytes)
       [2013-10-21T03:34:06+00:00] INFO: Forking chef instance to converge...
       Starting Chef Client, version 11.6.2
       [2013-10-21T03:34:06+00:00] INFO: *** Chef 11.6.2 ***
       [2013-10-21T03:34:06+00:00] INFO: Setting the run_list to ["recipe[git]"] from JSON
       [2013-10-21T03:34:06+00:00] INFO: Run List is [recipe[git]]
       [2013-10-21T03:34:06+00:00] INFO: Run List expands to [git]
       [2013-10-21T03:34:06+00:00] INFO: Starting Chef Run for default-ubuntu-1004
       [2013-10-21T03:34:06+00:00] INFO: Running start handlers
       [2013-10-21T03:34:06+00:00] INFO: Start handlers complete.
       Compiling Cookbooks...
       Converging 2 resources
       Recipe: git::default
         * package[git-core] action install

       [2013-10-21T03:34:06+00:00] INFO: Processing package[git-core] action install (git::default line 2)

           - install version 1:1.7.0.4-1ubuntu0.2 of package git-core

         * log[Well, that was too easy] action write

       [2013-10-21T03:34:19+00:00] INFO: Processing log[Well, that was too easy] action write (git::default line 7)
       [2013-10-21T03:34:19+00:00] INFO: Well, that was too easy


       [2013-10-21T03:34:19+00:00] INFO: Chef Run complete in 12.718145721 seconds
       [2013-10-21T03:34:19+00:00] INFO: Running report handlers
       [2013-10-21T03:34:19+00:00] INFO: Report handlers complete
       Chef Client finished, 2 resources updated
       Finished converging <default-ubuntu-1004> (0m13.98s).
-----> Setting up <default-ubuntu-1004>
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
             create  /tmp/bats20131021-2111-1xcvqim/bats
             create  /tmp/bats20131021-2111-1xcvqim/bats.tar.gz
       Installed Bats to /opt/busser/vendor/bats/bin/bats
             remove  /tmp/bats20131021-2111-1xcvqim
       Finished setting up <default-ubuntu-1004> (0m10.70s).
-----> Verifying <default-ubuntu-1004>
       Suite path directory /opt/busser/suites does not exist, skipping.
       Uploading /opt/busser/suites/bats/git_installed.bats (mode=0644)
-----> Running bats test suite
       1..1
       ok 1 git binary is found in PATH
       Finished verifying <default-ubuntu-1004> (0m1.02s).
-----> Kitchen is finished. (0m25.98s)
```

Back to green, good. Let's verify that the other two instances are still good. We'll use a Ruby regular expression to glob the two other instances into one Test Kitchen command:

```
$ kitchen verify '(12|64)'
-----> Starting Kitchen (v1.0.0.beta.3)
-----> Creating <default-ubuntu-1204>
       [kitchen::driver::vagrant command] BEGIN (vagrant up --no-provision)
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
       [kitchen::driver::vagrant command] END (0m45.03s)
       [kitchen::driver::vagrant command] BEGIN (vagrant ssh-config)
       [kitchen::driver::vagrant command] END (0m0.96s)
       Vagrant instance <default-ubuntu-1204> created.
       Finished creating <default-ubuntu-1204> (0m50.00s).
-----> Converging <default-ubuntu-1204>
-----> Installing Chef Omnibus (true)
--2013-10-21 03:38:30--  https://www.opscode.com/chef/install.sh
Resolving www.opscode.com (www.opscode.com)... 184.106.28.83
Connecting to www.opscode.com (www.opscode.com)|184.106.28.83|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 6790 (6.6K) [application/x-sh]
Saving to: `STDOUT'

100%[======================================>] 6,790       --.-K/s   in 0s

2013-10-21 03:38:30 (836 MB/s) - written to stdout [6790/6790]

Downloading Chef  for ubuntu...
Installing Chef
Selecting previously unselected package chef.
(Reading database ... 53291 files and directories currently installed.)
Unpacking chef (from .../tmp.sJfQqWFO/chef__amd64.deb) ...
Setting up chef (11.6.2-1.ubuntu.12.04) ...
Thank you for installing Chef!
       Preparing current project directory as a cookbook
       Removing non-cookbook files in sandbox
       Uploaded /tmp/default-ubuntu-1204-sandbox-20131020-94797-w843la/cookbooks/git/metadata.rb (27 bytes)
       Uploaded /tmp/default-ubuntu-1204-sandbox-20131020-94797-w843la/cookbooks/git/recipes/default.rb (151 bytes)
       Uploaded /tmp/default-ubuntu-1204-sandbox-20131020-94797-w843la/dna.json (28 bytes)
       Uploaded /tmp/default-ubuntu-1204-sandbox-20131020-94797-w843la/solo.rb (168 bytes)
[2013-10-21T03:39:02+00:00] INFO: Forking chef instance to converge...
Starting Chef Client, version 11.6.2
[2013-10-21T03:39:02+00:00] INFO: *** Chef 11.6.2 ***
[2013-10-21T03:39:02+00:00] INFO: Setting the run_list to ["recipe[git]"] from JSON
[2013-10-21T03:39:02+00:00] INFO: Run List is [recipe[git]]
[2013-10-21T03:39:02+00:00] INFO: Run List expands to [git]
[2013-10-21T03:39:02+00:00] INFO: Starting Chef Run for default-ubuntu-1204
[2013-10-21T03:39:02+00:00] INFO: Running start handlers
[2013-10-21T03:39:02+00:00] INFO: Start handlers complete.
Compiling Cookbooks...
Converging 2 resources
Recipe: git::default
  * package[git] action install

[2013-10-21T03:39:02+00:00] INFO: Processing package[git] action install (git::default line 4)

    - install version 1:1.7.9.5-1 of package git

  * log[Well, that was too easy] action write

[2013-10-21T03:39:21+00:00] INFO: Processing log[Well, that was too easy] action write (git::default line 7)
[2013-10-21T03:39:21+00:00] INFO: Well, that was too easy


[2013-10-21T03:39:21+00:00] INFO: Chef Run complete in 18.429224992 seconds
[2013-10-21T03:39:21+00:00] INFO: Running report handlers
[2013-10-21T03:39:21+00:00] INFO: Report handlers complete
Chef Client finished, 2 resources updated
       Finished converging <default-ubuntu-1204> (0m51.30s).
-----> Setting up <default-ubuntu-1204>
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
      create  /tmp/bats20131021-4121-n3q4x6/bats
      create  /tmp/bats20131021-4121-n3q4x6/bats.tar.gz
Installed Bats to /opt/busser/vendor/bats/bin/bats
      remove  /tmp/bats20131021-4121-n3q4x6
       Finished setting up <default-ubuntu-1204> (0m10.12s).
-----> Verifying <default-ubuntu-1204>
       Suite path directory /opt/busser/suites does not exist, skipping.
Uploading /opt/busser/suites/bats/git_installed.bats (mode=0644)
-----> Running bats test suite
1..1
ok 1 git binary is found in PATH
       Finished verifying <default-ubuntu-1204> (0m1.22s).
-----> Creating <default-centos-64>
       [kitchen::driver::vagrant command] BEGIN (vagrant up --no-provision)
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
       [default] Setting hostname...
       [default] Mounting shared folders...
       [kitchen::driver::vagrant command] END (0m53.46s)
       [kitchen::driver::vagrant command] BEGIN (vagrant ssh-config)
       [kitchen::driver::vagrant command] END (0m1.01s)
       Vagrant instance <default-centos-64> created.
       Finished creating <default-centos-64> (0m59.13s).
-----> Converging <default-centos-64>
-----> Installing Chef Omnibus (true)
       --2013-10-21 03:40:29--  https://www.opscode.com/chef/install.sh
Resolving www.opscode.com...        184.106.28.83
       Connecting to www.opscode.com|184.106.28.83|:443...
       connected.
HTTP request sent, awaiting response...        200 OK
       Length: 6790 (6.6K) [application/x-sh]
       Saving to: `STDOUT'

 0% [                                       ] 0           --.-K/s
100%[======================================>] 6,790       --.-K/s   in 0s

       2013-10-21 03:40:34 (568 MB/s) - written to stdout [6790/6790]

       Downloading Chef  for el...
       Installing Chef
       warning: /tmp/tmp.KIawvD7s/chef-.x86_64.rpm: Header V4 DSA/SHA1 Signature, key ID 83ef826a: NOKEY
Preparing...                #####  ########################################### [100%]
   1:chef                          ########################################### [100%]
       Thank you for installing Chef!
       Preparing current project directory as a cookbook
       Removing non-cookbook files in sandbox
       Uploaded /tmp/default-centos-64-sandbox-20131020-94797-ixj8x0/cookbooks/git/metadata.rb (27 bytes)
       Uploaded /tmp/default-centos-64-sandbox-20131020-94797-ixj8x0/cookbooks/git/recipes/default.rb (151 bytes)
       Uploaded /tmp/default-centos-64-sandbox-20131020-94797-ixj8x0/dna.json (28 bytes)
       Uploaded /tmp/default-centos-64-sandbox-20131020-94797-ixj8x0/solo.rb (166 bytes)
       [2013-10-21T03:41:20+00:00] INFO: Forking chef instance to converge...
       Starting Chef Client, version 11.6.2
       [2013-10-21T03:41:20+00:00] INFO: *** Chef 11.6.2 ***
       [2013-10-21T03:41:21+00:00] INFO: Setting the run_list to ["recipe[git]"] from JSON
       [2013-10-21T03:41:21+00:00] INFO: Run List is [recipe[git]]
       [2013-10-21T03:41:21+00:00] INFO: Run List expands to [git]
       [2013-10-21T03:41:21+00:00] INFO: Starting Chef Run for default-centos-64
       [2013-10-21T03:41:21+00:00] INFO: Running start handlers
       [2013-10-21T03:41:21+00:00] INFO: Start handlers complete.
       Compiling Cookbooks...
       Converging 2 resources
       Recipe: git::default
         * package[git] action install

       [2013-10-21T03:41:21+00:00] INFO: Processing package[git] action install (git::default line 4)
        (up to date)
  * log[Well, that was too easy] action write

       [2013-10-21T03:41:49+00:00] INFO: Processing log[Well, that was too easy] action write (git::default line 7)
       [2013-10-21T03:41:49+00:00] INFO: Well, that was too easy


       [2013-10-21T03:41:49+00:00] INFO: Chef Run complete in 27.949585729 seconds
       [2013-10-21T03:41:49+00:00] INFO: Running report handlers
       [2013-10-21T03:41:49+00:00] INFO: Report handlers complete
       Chef Client finished, 1 resources updated
       Finished converging <default-centos-64> (1m20.21s).
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
             create  /tmp/bats20131021-2628-xhuvzh/bats
             create  /tmp/bats20131021-2628-xhuvzh/bats.tar.gz
       Installed Bats to /opt/busser/vendor/bats/bin/bats
             remove  /tmp/bats20131021-2628-xhuvzh
       Finished setting up <default-centos-64> (0m55.02s).
-----> Verifying <default-centos-64>
       Suite path directory /opt/busser/suites does not exist, skipping.
       Uploading /opt/busser/suites/bats/git_installed.bats (mode=0644)
-----> Running bats test suite
       1..1
       ok 1 git binary is found in PATH
       Finished verifying <default-centos-64> (0m1.08s).
-----> Kitchen is finished. (5m8.38s)
$ echo $?
0
```

We've successfully verified all three instances, so let's shut them down.

```
$ kitchen destroy
-----> Starting Kitchen (v1.0.0.beta.3)
-----> Destroying <default-ubuntu-1204>
       [kitchen::driver::vagrant command] BEGIN (vagrant destroy -f)
       [default] Forcing shutdown of VM...
       [default] Destroying VM and associated drives...
       [kitchen::driver::vagrant command] END (0m3.01s)
       Vagrant instance <default-ubuntu-1204> destroyed.
       Finished destroying <default-ubuntu-1204> (0m3.32s).
-----> Destroying <default-ubuntu-1004>
       [kitchen::driver::vagrant command] BEGIN (vagrant destroy -f)
       [default] Forcing shutdown of VM...
       [default] Destroying VM and associated drives...
       [kitchen::driver::vagrant command] END (0m3.24s)
       Vagrant instance <default-ubuntu-1004> destroyed.
       Finished destroying <default-ubuntu-1004> (0m3.55s).
-----> Destroying <default-centos-64>
       [kitchen::driver::vagrant command] BEGIN (vagrant destroy -f)
       [default] Forcing shutdown of VM...
       [default] Destroying VM and associated drives...
       [kitchen::driver::vagrant command] END (0m2.83s)
       Vagrant instance <default-centos-64> destroyed.
       Finished destroying <default-centos-64> (0m3.10s).
-----> Kitchen is finished. (0m10.27s)
```

And finally commit our code updates:

```
$ git add .kitchen.yml recipes/default.rb
> git commit -m "Add support for Ubuntu 10.04."
[master 99073a6] Add support for Ubuntu 10.04.
 2 files changed, 6 insertions(+), 1 deletion(-)
```
