---
title: Backfilling Platforms
next:
  text: "Next Steps"
  url: "next-steps"
---

Let's see if our server recipe works on the older Ubuntu 10.04 platform. Fingers crossed, here we go:

~~~
$ kitchen verify server-ubuntu-1004
-----> Starting Kitchen (v1.0.0)
-----> Creating <server-ubuntu-1004>...
       Bringing machine 'default' up with 'virtualbox' provider...
       [default] Importing base box 'opscode-ubuntu-10.04'...
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
       Vagrant instance <server-ubuntu-1004> created.
       Finished creating <server-ubuntu-1004> (0m50.83s).
-----> Converging <server-ubuntu-1004>...
       Preparing files for transfer
       Resolving cookbook dependencies with Berkshelf...
       Removing non-cookbook files before transfer
-----> Installing Chef Omnibus (true)
       downloading https://www.opscode.com/chef/install.sh
         to file /tmp/install.sh
       trying wget...
       Downloading Chef  for ubuntu...
       Installing Chef
       Selecting previously deselected package chef.
       (Reading database ...
(Reading database ... 44103 files and directories currently installed.)
       Unpacking chef (from .../tmp.g6F0KqZE/chef__amd64.deb) ...
       Setting up chef (11.8.0-1.ubuntu.10.04) ...
       Thank you for installing Chef!

       Transfering files to <server-ubuntu-1004>
       [2013-12-02T02:44:11+00:00] INFO: Forking chef instance to converge...
       Starting Chef Client, version 11.8.0
       [2013-12-02T02:44:11+00:00] INFO: *** Chef 11.8.0 ***
       [2013-12-02T02:44:11+00:00] INFO: Chef-client pid: 968
       [2013-12-02T02:44:11+00:00] INFO: Setting the run_list to ["recipe[git::server]"] from JSON
       [2013-12-02T02:44:11+00:00] INFO: Run List is [recipe[git::server]]
       [2013-12-02T02:44:11+00:00] INFO: Run List expands to [git::server]
       [2013-12-02T02:44:11+00:00] INFO: Starting Chef Run for server-ubuntu-1004
       [2013-12-02T02:44:11+00:00] INFO: Running start handlers
       [2013-12-02T02:44:11+00:00] INFO: Start handlers complete.
       Compiling Cookbooks...
       Converging 9 resources
       Recipe: git::default
         * package[git-core] action install[2013-12-02T02:44:11+00:00] INFO: Processing package[git-core] action install (git::default line 2)

           - install version 1:1.7.0.4-1ubuntu0.2 of package git-core

         * log[Well, that was too easy] action write[2013-12-02T02:44:24+00:00] INFO: Processing log[Well, that was too easy] action write (git::default line 7)
       [2013-12-02T02:44:24+00:00] INFO: Well, that was too easy


       Recipe: runit::default
         * service[runit] action nothing[2013-12-02T02:44:24+00:00] INFO: Processing service[runit] action nothing (runit::default line 20)
        (skipped due to action :nothing)
         * execute[start-runsvdir] action nothing[2013-12-02T02:44:24+00:00] INFO: Processing execute[start-runsvdir] action nothing (runit::default line 24)
        (skipped due to action :nothing)
         * execute[runit-hup-init] action nothing[2013-12-02T02:44:24+00:00] INFO: Processing execute[runit-hup-init] action nothing (runit::default line 33)
        (skipped due to action :nothing)
         * package[runit] action install[2013-12-02T02:44:24+00:00] INFO: Processing package[runit] action install (runit::default line 95)
       Recipe: <Dynamically Defined Resource>
         * cookbook_file[/tmp/kitchen/cache/preseed/runit/runit-2.0.0-1ubuntu4.seed] action create[2013-12-02T02:44:25+00:00] INFO: Processing cookbook_file[/tmp/kitchen/cache/preseed/runit/runit-2.0.0-1ubuntu4.seed] action create (dynamically defined)
       [2013-12-02T02:44:25+00:00] INFO: cookbook_file[/tmp/kitchen/cache/preseed/runit/runit-2.0.0-1ubuntu4.seed] created file /tmp/kitchen/cache/preseed/runit/runit-2.0.0-1ubuntu4.seed

           - create new file /tmp/kitchen/cache/preseed/runit/runit-2.0.0-1ubuntu4.seed[2013-12-02T02:44:25+00:00] INFO: cookbook_file[/tmp/kitchen/cache/preseed/runit/runit-2.0.0-1ubuntu4.seed] updated file contents /tmp/kitchen/cache/preseed/runit/runit-2.0.0-1ubuntu4.seed

           - update content in file /tmp/kitchen/cache/preseed/runit/runit-2.0.0-1ubuntu4.seed from none to 9c6758
        --- /tmp/kitchen/cache/preseed/runit/runit-2.0.0-1ubuntu4.seed  2013-12-02 02:44:25.030657115 +0000
        +++ /tmp/.runit-2.0.0-1ubuntu4.seed20131202-968-79dchx  2013-12-02 02:44:25.030657115 +0000
        @@ -1 +1,2 @@
        +runit   runit/signalinit        boolean true

       [2013-12-02T02:44:25+00:00] INFO: package[runit] pre-seeding package installation instructions

           - preseed package runit

           - install version 2.0.0-1ubuntu4 of package runit

       [2013-12-02T02:44:26+00:00] INFO: package[runit] sending nothing action to execute[start-runsvdir] (immediate)
       Recipe: runit::default
         * execute[start-runsvdir] action nothing[2013-12-02T02:44:26+00:00] INFO: Processing execute[start-runsvdir] action nothing (runit::default line 24)
        (skipped due to action :nothing)
       [2013-12-02T02:44:26+00:00] INFO: package[runit] sending nothing action to execute[runit-hup-init] (immediate)
         * execute[runit-hup-init] action nothing[2013-12-02T02:44:26+00:00] INFO: Processing execute[runit-hup-init] action nothing (runit::default line 33)
        (skipped due to action :nothing)
       Recipe: git::server
         * package[git-daemon-run] action install[2013-12-02T02:44:26+00:00] INFO: Processing package[git-daemon-run] action install (git::server line 4)

           - install version 1:1.7.0.4-1ubuntu0.2 of package git-daemon-run

       Recipe: <Dynamically Defined Resource>
         * service[git-daemon] action nothing[2013-12-02T02:44:29+00:00] INFO: Processing service[git-daemon] action nothing (dynamically defined)
        (skipped due to action :nothing)
       Recipe: git::server
         * runit_service[git-daemon] action enable[2013-12-02T02:44:29+00:00] INFO: Processing runit_service[git-daemon] action enable (git::server line 6)
       Recipe: <Dynamically Defined Resource>
         * link[/etc/init.d/git-daemon] action create[2013-12-02T02:44:29+00:00] INFO: Processing link[/etc/init.d/git-daemon] action create (dynamically defined)
       [2013-12-02T02:44:29+00:00] INFO: link[/etc/init.d/git-daemon] created

           - create symlink at /etc/init.d/git-daemon to /usr/bin/sv

       [2013-12-02T02:44:29+00:00] INFO: runit_service[git-daemon] configured

           - configure service runit_service[git-daemon]

       [2013-12-02T02:44:29+00:00] INFO: Chef Run complete in 17.598448178 seconds
       [2013-12-02T02:44:29+00:00] INFO: Running report handlers
       [2013-12-02T02:44:29+00:00] INFO: Report handlers complete
       Chef Client finished, 7 resources updated
       Finished converging <server-ubuntu-1004> (0m51.11s).
-----> Setting up <server-ubuntu-1004>...
Fetching: thor-0.18.1.gem (100%)
Fetching: busser-0.6.0.gem (100%)
       Successfully installed thor-0.18.1
       Successfully installed busser-0.6.0
       2 gems installed
-----> Setting up Busser
       Creating BUSSER_ROOT in /tmp/busser
       Creating busser binstub
       Plugin serverspec installed (version 0.2.5)
-----> Running postinstall for serverspec plugin
       Finished setting up <server-ubuntu-1004> (0m14.07s).
-----> Verifying <server-ubuntu-1004>...
       Suite path directory /tmp/busser/suites does not exist, skipping.
       Uploading /tmp/busser/suites/serverspec/git_daemon_spec.rb (mode=0644)
-----> Running serverspec test suite
       /opt/chef/embedded/bin/ruby -I/tmp/busser/suites/serverspec -S /opt/chef/embedded/bin/rspec /tmp/busser/suites/serverspec/git_daemon_spec.rb --color --format documentation

       Git Daemon
         is listening on port 9418
         has a running service of git-daemon

       Finished in 0.03267 seconds
       2 examples, 0 failures
       Finished verifying <server-ubuntu-1004> (0m1.22s).
-----> Kitchen is finished. (1m57.54s)
~~~

Well that was easy!

I'm going to spare us all a great deal of pain and say that getting CentOS working with Git Daemon and runit is, well, kinda nuts. Ultimately not worth it for the sake of this guide. So should we leave a Platform/Suite combination lying around that we know we won't support? Naw!

> **Add a platform name to an `excludes` array in a suite to remove the the platform/suite combination from testing.**

Let's exclude the `server-centos-64` instance so that it doesn't accidentally get run. Update `.kitchen.yml` to look like the following:

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
  - name: server
    run_list:
      - recipe[git::server]
    attributes:
    excludes:
      - centos-6.4
~~~

Now let's run `kitchen list` to ensure the instance is gone:

~~~
$ kitchen list
Instance             Driver   Provisioner  Last Action
default-ubuntu-1204  Vagrant  ChefSolo     <Not Created>
default-ubuntu-1004  Vagrant  ChefSolo     <Not Created>
default-centos-64    Vagrant  ChefSolo     <Not Created>
server-ubuntu-1204   Vagrant  ChefSolo     Verified
server-ubuntu-1004   Vagrant  ChefSolo     Verified
~~~

After so much success we should commit our working code. We want to leave our `Berksfile.lock` out of version control so first we'll edit `.gitignore` to read:

~~~
Berksfile.lock
.kitchen/
.kitchen.local.yml
~~~

Now to commit:

~~~
$ git add .gitignore .kitchen.yml metadata.rb Berksfile recipes/server.rb test/integration/server/serverspec/git_daemon_spec.rb
$ git commit -m "Add git-daemon support for Ubuntu 10.04 & 12.04."
[master 1bb6ead] Add git-daemon support for Ubuntu 10.04 & 12.04.
 6 files changed, 44 insertions(+)
 create mode 100644 Berksfile
 create mode 100644 recipes/server.rb
 create mode 100644 test/integration/server/serverspec/git_daemon_spec.rb
~~~

Finally let's destroy our running instances:

~~~
$ kitchen destroy
-----> Starting Kitchen (v1.0.0)
-----> Destroying <default-ubuntu-1204>...
       Finished destroying <default-ubuntu-1204> (0m0.00s).
-----> Destroying <default-ubuntu-1004>...
       Finished destroying <default-ubuntu-1004> (0m0.00s).
-----> Destroying <default-centos-64>...
       Finished destroying <default-centos-64> (0m0.00s).
-----> Destroying <server-ubuntu-1204>...
       [default] Forcing shutdown of VM...
       [default] Destroying VM and associated drives...
       Vagrant instance <server-ubuntu-1204> destroyed.
       Finished destroying <server-ubuntu-1204> (0m3.05s).
-----> Destroying <server-ubuntu-1004>...
       [default] Forcing shutdown of VM...
       [default] Destroying VM and associated drives...
       Vagrant instance <server-ubuntu-1004> destroyed.
       Finished destroying <server-ubuntu-1004> (0m3.31s).
-----> Kitchen is finished. (0m6.69s)
~~~

Okay, let's cut it off here, ship it!
