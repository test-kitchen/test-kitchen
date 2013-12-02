---
title: Adding a Dependency
prev:
  text: "Writing a Failing Recipe"
  url: "writing-failing-recipe"
next:
  text: "Backfilling Platforms"
  url: "backfilling-platforms"
---

To add a dependency to our cookbook we edit the `metadata.rb` file and the runit cookbook with a `depends` statement:

~~~ruby
name "git"
version "0.1.0"

depends "runit", "~> 1.4.0"
~~~

Note that we're adding a contstraint on the version of the runit cookbook. While this isn't strictly required it is something you want to consider as cookbooks can introduce breaking changes in the future.

Now, let's see if we get to pass our tests:

~~~
$ kitchen verify server-ubuntu-1204
-----> Starting Kitchen (v1.0.0)
-----> Converging <server-ubuntu-1204>...
       Preparing files for transfer
       Preparing current project directory as a cookbook
       Removing non-cookbook files before transfer
       Transfering files to <server-ubuntu-1204>
[2013-12-02T00:04:57+00:00] INFO: Forking chef instance to converge...
Starting Chef Client, version 11.8.0
[2013-12-02T00:04:57+00:00] INFO: *** Chef 11.8.0 ***
[2013-12-02T00:04:57+00:00] INFO: Chef-client pid: 1462
[2013-12-02T00:04:58+00:00] INFO: Setting the run_list to ["recipe[git::server]"] from JSON
[2013-12-02T00:04:58+00:00] INFO: Run List is [recipe[git::server]]
[2013-12-02T00:04:58+00:00] INFO: Run List expands to [git::server]
[2013-12-02T00:04:58+00:00] INFO: Starting Chef Run for server-ubuntu-1204
[2013-12-02T00:04:58+00:00] INFO: Running start handlers
[2013-12-02T00:04:58+00:00] INFO: Start handlers complete.
Compiling Cookbooks...
[2013-12-02T00:04:58+00:00] ERROR: Running exception handlers
[2013-12-02T00:04:58+00:00] ERROR: Exception handlers complete
[2013-12-02T00:04:58+00:00] FATAL: Stacktrace dumped to /tmp/kitchen/cache/chef-stacktrace.out
Chef Client failed. 0 resources updated
[2013-12-02T00:04:58+00:00] ERROR: Cookbook runit not found. If you're loading runit from another cookbook, make sure you configure the dependency in your metadata
[2013-12-02T00:04:58+00:00] FATAL: Chef::Exceptions::ChildConvergeError: Chef run process exited unsuccessfully (exit code 1)
>>>>>> Converge failed on instance <server-ubuntu-1204>.
>>>>>> Please see .kitchen/logs/server-ubuntu-1204.log for more details
>>>>>> ------Exception-------
>>>>>> Class: Kitchen::ActionFailed
>>>>>> Message: SSH exited (1) for command: [sudo -E chef-solo --config /tmp/kitchen/solo.rb --json-attributes /tmp/kitchen/dna.json  --log_level info]
>>>>>> ----------------------
~~~

Hmm, Chef still seems to be confused. We've told Chef that we depend on the runit cookbook yet it's still complaining about our metadata.

What we need is a Chef cookbook dependency resolver tool to fetch our missing cookbooks so that Test Kitchen can use them in the Chef run. Here's the high level logic that Test Kitchen traverses in order to help you with your cookbook dependencies (again, first match wins):

1. Do you have a `Berksfile` in your project directory? If so, Test Kitchen will use [Berkshelf](http://berkshelf.com/) to resolve dependencies.
2. Do you have a `Cheffile` in your project directory? If so, Test Kitchen will use [Librarian-Chef](https://github.com/applicationsonline/librarian-chef) to resolve dependencies.
3. Do you have a `cookbooks/` directory in your project directory? If so, Test Kitchen will use that.
4. Do you have a `metadata.rb` file in your project directory? If so, then this project is a cookbook and Test Kitchen will use that.
5. Otherwise we're out of options, so Test Kitchen will create a fake cookbook and use that so that Chef has just enough to perform an empty Chef run.

For this guide, we'll use Berkshelf to fetch runit for us.

To get started we need to install the berkshelf gem--Test Kitchen doesn't depend on this library directly since it's one of many options:

~~~
$ gem install berkshelf
Fetching: i18n-0.6.5.gem (100%)
Successfully installed i18n-0.6.5
Fetching: multi_json-1.8.2.gem (100%)
Successfully installed multi_json-1.8.2
Fetching: activesupport-3.2.15.gem (100%)
Successfully installed activesupport-3.2.15
Fetching: addressable-2.3.5.gem (100%)
Successfully installed addressable-2.3.5
Fetching: buff-ruby_engine-0.1.0.gem (100%)
Successfully installed buff-ruby_engine-0.1.0
Fetching: buff-shell_out-0.1.1.gem (100%)
Successfully installed buff-shell_out-0.1.1
Fetching: hashie-2.0.5.gem (100%)
Successfully installed hashie-2.0.5
Fetching: chozo-0.6.1.gem (100%)
Successfully installed chozo-0.6.1
Fetching: multipart-post-1.2.0.gem (100%)
Successfully installed multipart-post-1.2.0
Fetching: faraday-0.8.8.gem (100%)
Successfully installed faraday-0.8.8
Fetching: minitar-0.5.4.gem (100%)
Successfully installed minitar-0.5.4
Fetching: retryable-1.3.3.gem (100%)
Successfully installed retryable-1.3.3
Fetching: buff-extensions-0.5.0.gem (100%)
Successfully installed buff-extensions-0.5.0
Fetching: varia_model-0.2.0.gem (100%)
Successfully installed varia_model-0.2.0
Fetching: buff-config-0.4.0.gem (100%)
Successfully installed buff-config-0.4.0
Fetching: buff-ignore-1.1.1.gem (100%)
Successfully installed buff-ignore-1.1.1
Fetching: timers-1.1.0.gem (100%)
Successfully installed timers-1.1.0
Fetching: celluloid-0.14.1.gem (100%)
Successfully installed celluloid-0.14.1
Fetching: nio4r-0.5.0.gem (100%)
Building native extensions.  This could take a while...
Successfully installed nio4r-0.5.0
Fetching: celluloid-io-0.14.1.gem (100%)
Successfully installed celluloid-io-0.14.1
Fetching: erubis-2.7.0.gem (100%)
Successfully installed erubis-2.7.0
Fetching: mixlib-log-1.6.0.gem (100%)
Successfully installed mixlib-log-1.6.0
Fetching: mixlib-authentication-1.3.0.gem (100%)
Successfully installed mixlib-authentication-1.3.0
Fetching: net-http-persistent-2.9.gem (100%)
Successfully installed net-http-persistent-2.9
Fetching: solve-0.8.2.gem (100%)
Successfully installed solve-0.8.2
Fetching: ffi-1.9.3.gem (100%)
Building native extensions.  This could take a while...
Successfully installed ffi-1.9.3
Fetching: gssapi-1.0.3.gem (100%)
Successfully installed gssapi-1.0.3
Fetching: httpclient-2.3.4.1.gem (100%)
Successfully installed httpclient-2.3.4.1
Fetching: mini_portile-0.5.2.gem (100%)
Successfully installed mini_portile-0.5.2
Fetching: nokogiri-1.6.0.gem (100%)
Building native extensions.  This could take a while...
Successfully installed nokogiri-1.6.0
Fetching: rubyntlm-0.1.1.gem (100%)
Successfully installed rubyntlm-0.1.1
Fetching: uuidtools-2.1.4.gem (100%)
Successfully installed uuidtools-2.1.4
Fetching: builder-3.2.2.gem (100%)
Successfully installed builder-3.2.2
Fetching: nori-1.1.5.gem (100%)
Successfully installed nori-1.1.5
Fetching: rack-1.5.2.gem (100%)
Successfully installed rack-1.5.2
Fetching: httpi-0.9.7.gem (100%)
Successfully installed httpi-0.9.7
Fetching: wasabi-1.0.0.gem (100%)
Successfully installed wasabi-1.0.0
Fetching: gyoku-1.1.0.gem (100%)
Successfully installed gyoku-1.1.0
Fetching: akami-1.2.0.gem (100%)
Successfully installed akami-1.2.0
Fetching: savon-0.9.5.gem (100%)
Successfully installed savon-0.9.5
Fetching: little-plugger-1.1.3.gem (100%)
Successfully installed little-plugger-1.1.3
Fetching: logging-1.8.1.gem (100%)
Successfully installed logging-1.8.1
Fetching: winrm-1.1.3.gem (100%)
Successfully installed winrm-1.1.3
Fetching: ridley-1.5.3.gem (100%)
Successfully installed ridley-1.5.3
Fetching: rbzip2-0.2.0.gem (100%)
Successfully installed rbzip2-0.2.0
Fetching: berkshelf-2.0.10.gem (100%)
Successfully installed berkshelf-2.0.10
46 gems installed
~~~

Next we'll create the smallest `Berksfile`, using your editor of choice:

~~~ruby
site :opscode

metadata
~~~

The `metadata` command tells Berkshelf that the current project is a Chef cookbook and to use its `metadata.rb` as a source of cookbook dependencies.

Now, let's re-run `kitchen verify`:

~~~
$ kitchen verify server-ubuntu-1204
-----> Starting Kitchen (v1.0.0)
-----> Converging <server-ubuntu-1204>...
       Preparing files for transfer
       Resolving cookbook dependencies with Berkshelf...
       Removing non-cookbook files before transfer
       Transfering files to <server-ubuntu-1204>
[2013-12-02T02:36:51+00:00] INFO: Forking chef instance to converge...
Starting Chef Client, version 11.8.0
[2013-12-02T02:36:51+00:00] INFO: *** Chef 11.8.0 ***
[2013-12-02T02:36:51+00:00] INFO: Chef-client pid: 1621
[2013-12-02T02:36:51+00:00] INFO: Setting the run_list to ["recipe[git::server]"] from JSON
[2013-12-02T02:36:51+00:00] INFO: Run List is [recipe[git::server]]
[2013-12-02T02:36:51+00:00] INFO: Run List expands to [git::server]
[2013-12-02T02:36:51+00:00] INFO: Starting Chef Run for server-ubuntu-1204
[2013-12-02T02:36:51+00:00] INFO: Running start handlers
[2013-12-02T02:36:51+00:00] INFO: Start handlers complete.
Compiling Cookbooks...
Converging 9 resources
Recipe: git::default
  * package[git] action install[2013-12-02T02:36:51+00:00] INFO: Processing package[git] action install (git::default line 4)

    - install version 1:1.7.9.5-1 of package git

  * log[Well, that was too easy] action write[2013-12-02T02:37:08+00:00] INFO: Processing log[Well, that was too easy] action write (git::default line 7)
[2013-12-02T02:37:08+00:00] INFO: Well, that was too easy


Recipe: runit::default
  * service[runit] action nothing[2013-12-02T02:37:08+00:00] INFO: Processing service[runit] action nothing (runit::default line 20)
 (skipped due to action :nothing)
  * execute[start-runsvdir] action nothing[2013-12-02T02:37:08+00:00] INFO: Processing execute[start-runsvdir] action nothing (runit::default line 24)
 (skipped due to action :nothing)
  * execute[runit-hup-init] action nothing[2013-12-02T02:37:08+00:00] INFO: Processing execute[runit-hup-init] action nothing (runit::default line 33)
 (skipped due to action :nothing)
  * package[runit] action install[2013-12-02T02:37:08+00:00] INFO: Processing package[runit] action install (runit::default line 95)
Recipe: <Dynamically Defined Resource>
  * cookbook_file[/tmp/kitchen/cache/preseed/runit/runit-2.1.1-6.2ubuntu2.seed] action create[2013-12-02T02:37:08+00:00] INFO: Processing cookbook_file[/tmp/kitchen/cache/preseed/runit/runit-2.1.1-6.2ubuntu2.seed] action create (dynamically defined)
[2013-12-02T02:37:08+00:00] INFO: cookbook_file[/tmp/kitchen/cache/preseed/runit/runit-2.1.1-6.2ubuntu2.seed] created file /tmp/kitchen/cache/preseed/runit/runit-2.1.1-6.2ubuntu2.seed

    - create new file /tmp/kitchen/cache/preseed/runit/runit-2.1.1-6.2ubuntu2.seed[2013-12-02T02:37:08+00:00] INFO: cookbook_file[/tmp/kitchen/cache/preseed/runit/runit-2.1.1-6.2ubuntu2.seed] updated file contents /tmp/kitchen/cache/preseed/runit/runit-2.1.1-6.2ubuntu2.seed

    - update content in file /tmp/kitchen/cache/preseed/runit/runit-2.1.1-6.2ubuntu2.seed from none to 9c6758
        --- /tmp/kitchen/cache/preseed/runit/runit-2.1.1-6.2ubuntu2.seed        2013-12-02 02:37:08.627719079 +0000
        +++ /tmp/.runit-2.1.1-6.2ubuntu2.seed20131202-1621-1hysxxf      2013-12-02 02:37:08.635723077 +0000
        @@ -1 +1,2 @@
        +runit   runit/signalinit        boolean true

[2013-12-02T02:37:08+00:00] INFO: package[runit] pre-seeding package installation instructions

    - preseed package runit
    - install version 2.1.1-6.2ubuntu2 of package runit

[2013-12-02T02:37:11+00:00] INFO: package[runit] sending nothing action to execute[start-runsvdir] (immediate)
Recipe: runit::default
  * execute[start-runsvdir] action nothing[2013-12-02T02:37:11+00:00] INFO: Processing execute[start-runsvdir] action nothing (runit::default line 24)
 (skipped due to action :nothing)
[2013-12-02T02:37:11+00:00] INFO: package[runit] sending nothing action to execute[runit-hup-init] (immediate)
  * execute[runit-hup-init] action nothing[2013-12-02T02:37:11+00:00] INFO: Processing execute[runit-hup-init] action nothing (runit::default line 33)
 (skipped due to action :nothing)
Recipe: git::server
  * package[git-daemon-run] action install[2013-12-02T02:37:11+00:00] INFO: Processing package[git-daemon-run] action install (git::server line 4)

    - install version 1:1.7.9.5-1 of package git-daemon-run

Recipe: <Dynamically Defined Resource>
  * service[git-daemon] action nothing[2013-12-02T02:37:12+00:00] INFO: Processing service[git-daemon] action nothing (dynamically defined)
 (skipped due to action :nothing)
Recipe: git::server
  * runit_service[git-daemon] action enable[2013-12-02T02:37:12+00:00] INFO: Processing runit_service[git-daemon] action enable (git::server line 6)
Recipe: <Dynamically Defined Resource>
  * link[/etc/init.d/git-daemon] action create[2013-12-02T02:37:12+00:00] INFO: Processing link[/etc/init.d/git-daemon] action create (dynamically defined)
[2013-12-02T02:37:12+00:00] INFO: link[/etc/init.d/git-daemon] created

    - create symlink at /etc/init.d/git-daemon to /usr/bin/sv

[2013-12-02T02:37:12+00:00] INFO: runit_service[git-daemon] configured

    - configure service runit_service[git-daemon]

[2013-12-02T02:37:12+00:00] INFO: Chef Run complete in 21.335525906 seconds
[2013-12-02T02:37:12+00:00] INFO: Running report handlers
[2013-12-02T02:37:12+00:00] INFO: Report handlers complete
Chef Client finished, 7 resources updated
       Finished converging <server-ubuntu-1204> (0m24.09s).
-----> Setting up <server-ubuntu-1204>...
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
       Finished setting up <server-ubuntu-1204> (0m15.49s).
-----> Verifying <server-ubuntu-1204>...
       Suite path directory /tmp/busser/suites does not exist, skipping.
Uploading /tmp/busser/suites/serverspec/git_daemon_spec.rb (mode=0644)
-----> Running serverspec test suite
/opt/chef/embedded/bin/ruby -I/tmp/busser/suites/serverspec -S /opt/chef/embedded/bin/rspec /tmp/busser/suites/serverspec/git_daemon_spec.rb --color --format documentation

Git Daemon
  is listening on port 9418
  has a running service of git-daemon

Finished in 0.0344 seconds
2 examples, 0 failures
       Finished verifying <server-ubuntu-1204> (0m1.20s).
-----> Kitchen is finished. (0m41.16s)
~~~

Awesome, and tests pass! Did you notice the `Resolving cookbook dependencies with Berkshelf...` line near the beginning? Confirming our success:

~~~
$ kitchen list server
Instance            Driver   Provisioner  Last Action
server-ubuntu-1204  Vagrant  ChefSolo     Verified
server-ubuntu-1004  Vagrant  ChefSolo     <Not Created>
server-centos-64    Vagrant  ChefSolo     <Not Created>
~~~

Now let's backfill the other platforms.
