---
title: Adding a Dependency
---

##### Adding a Dependency

To add a dependency to our cookbook we edit the `metadata.rb` file and the runit cookbook with a `depends` statement:

~~~
name 'git_cookbook'
maintainer 'The Authors'
maintainer_email 'you@example.com'
license 'All Rights Reserved'
description 'Installs/Configures git_cookbook'
long_description 'Installs/Configures git_cookbook'
version '0.1.0'
chef_version '>= 12.1' if respond_to?(:chef_version)

depends "runit", "~> 3.0.0"
~~~

Note that we're adding a constraint on the version of the runit cookbook. While this isn't strictly required it is something you want to consider as cookbooks can introduce breaking changes in the future.

Now, let's see if we get to pass our tests:

~~~
$ kitchen verify server-ubuntu-1604
-----> Starting Kitchen (v1.16.0)
-----> Converging <server-ubuntu-1604>...
       Preparing files for transfer
       Preparing dna.json
       Resolving cookbook dependencies with Berkshelf 5.6.4...
       Removing non-cookbook files before transfer
       Preparing validation.pem
       Preparing client.rb
-----> Chef Omnibus installation detected (13)
       Transferring files to <server-ubuntu-1604>
       Starting Chef Client, version 13.0.118
       resolving cookbooks for run list: ["git_cookbook::server"]
       Synchronizing Cookbooks:
         - git_cookbook (0.1.0)
         - packagecloud (0.3.0)
         - runit (3.0.5)
         - yum-epel (2.1.1)
         - compat_resource (12.19.0)
       Installing Cookbook Gems:
       Compiling Cookbooks...
       /tmp/kitchen/cache/cookbooks/packagecloud/resources/repo.rb:10: warning: constant ::Fixnum is deprecated
       Converging 9 resources
       Recipe: git_cookbook::default
         * apt_update[] action periodic
           - update new lists of packages
           * directory[/var/lib/apt/periodic] action create (up to date)
           * directory[/etc/apt/apt.conf.d] action create (up to date)
           * file[/etc/apt/apt.conf.d/15update-stamp] action create_if_missing (up to date)
           * execute[apt-get -q update] action run
             - execute apt-get -q update

         * apt_package[git] action install (up to date)
         * log[Well, that was too easy] action write

       Recipe: runit::default
         * service[runit] action nothing (skipped due to action :nothing)
         * execute[start-runsvdir] action nothing (skipped due to action :nothing)
         * apt_package[runit] action install
         Recipe: <Dynamically Defined Resource>
           * cookbook_file[/tmp/kitchen/cache/preseed/runit/runit-2.1.2-3ubuntu1.seed] action create
             - create new file /tmp/kitchen/cache/preseed/runit/runit-2.1.2-3ubuntu1.seed
             - update content in file /tmp/kitchen/cache/preseed/runit/runit-2.1.2-3ubuntu1.seed from none to 9c6758
             --- /tmp/kitchen/cache/preseed/runit/runit-2.1.2-3ubuntu1.seed     2017-05-08 16:00:10.182241135 +0000
             +++ /tmp/kitchen/cache/preseed/runit/.chef-runit-220170508-2473-1wy9caq.1.2-3ubuntu1.seed  2017-05-08 16:00:10.182241135 +0000
             @@ -1 +1,2 @@
             +runit   runit/signalinit        boolean true
           - preseed package runit
           - install version 2.1.2-3ubuntu1 of package runit
       Recipe: git_cookbook::server
         * apt_package[git-daemon-run] action install
           - install version 1:2.7.4-0ubuntu1 of package git-daemon-run
       Recipe: <Dynamically Defined Resource>
         * service[git-daemon] action nothing (skipped due to action :nothing)
       Recipe: git_cookbook::server
         * runit_service[git-daemon] action enable
           * ruby_block[restart_service] action nothing (skipped due to action :nothing)
           * ruby_block[restart_log_service] action nothing (skipped due to action :nothing)
           * directory[/etc/service] action create (up to date)
           * link[/etc/service/git-daemon] action create (up to date)
           * ruby_block[wait for git-daemon service socket] action run
             - execute the ruby block wait for git-daemon service socket


       Running handlers:
       Running handlers complete
       Chef Client finished, 8/19 resources updated in 19 seconds
       Finished converging <server-ubuntu-1604> (0m26.84s).
-----> Setting up <server-ubuntu-1604>...
       Finished setting up <server-ubuntu-1604> (0m0.00s).
-----> Verifying <server-ubuntu-1604>...
       Loaded tests from test/smoke/server

Profile: tests from test/smoke/server
Version: (not specified)
Target:  ssh://vagrant@127.0.0.1:2222


  Port 9418
     ✔  should be listening
  Service git-daemon
   ✔  should be installed
   ✔  should be enabled
   ✔  should be running

Test Summary: 4 successful, 0 failures, 0 skipped
     Finished verifying <server-ubuntu-1604> (0m0.39s).
-----> Kitchen is finished. (0m1.83s)
~~~

Awesome, our tests worked for the first time and all we had to do was add one line - MAGIC. But how and where did we get this `runit` cookbook?

When we generated out cookbook earlier one of the files was a `Berksfile`, this file is used by an application called Berkshelf to resolve dependencies for Chef cookbooks. Let's look at it:

~~~
$ cat Berksfile
source 'https://supermarket.chef.io'

metadata
~~~

- `source` tells Berkshelf what endpoint to resolve dependencies against
- `metadata` tells Berkshelf to parse `metadata.rb` for dependencies

In our case, Kitchen uses Berkshelf to fetch a version of `runit` that fits the constraints we set from the Chef Supermarket and takes care of uploading the entire cookbook set to the instance. The Chef provisioner of Kitchen supports other alternatives for cookbook dependency resolution, though Berkshelf is the most commmon default.

~~~
$ kitchen list server
Instance            Driver   Provisioner  Verifier  Transport  Last Action    Last Error
server-ubuntu-1604  Vagrant  ChefZero     Inspec    Ssh        Verified       <None>
server-centos-73    Vagrant  ChefZero     Inspec    Ssh        <Not Created>  <None>
~~~
