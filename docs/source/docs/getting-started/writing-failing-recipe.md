---
title: Writing a Failing Recipe
prev:
  text: "Writing a Server Test"
  url: "writing-server-test"
next:
  text: "Adding a Dependency"
  url: "adding-dependency"
---

So far our cookbook has no dependencies on other cookbooks to get its job done which is awesome! But let's say we require dependant cookbooks. For our example we'll be relying on the [runit](http://community.opscode.com/cookbooks/runit) cookbook to manage our Git Daemon service.


With this solution in mind we'll create a file called `recipes/server.rb` with the following:

~~~ruby
include_recipe "git"
include_recipe "runit"

package "git-daemon-run"

runit_service "git-daemon" do
  sv_templates false
end
~~~

Reasonably straight forward code. Here's what is going on:

* We include our default Git recipe so that Git is installed. Hey we already solved that one, right?
* We include the default recipe from the runit cookbook which installs runit and provides the `runit_service` resource.
* We install the `git-daemon-run` package which gives us the `git-daemon` program, on Ubuntu 12.04 at least.
* Finally, we declare a runit service called `git-daemon` without generating the run and log scripts (they were provided by the Ubuntu package).

Now to see the fruits of our effort:

~~~
$ kitchen verify server-ubuntu-1204
-----> Starting Kitchen (v1.0.0)
-----> Converging <server-ubuntu-1204>...
       Preparing files for transfer
       Preparing current project directory as a cookbook
       Removing non-cookbook files before transfer
       Transfering files to <server-ubuntu-1204>
[2013-12-01T23:59:22+00:00] INFO: Forking chef instance to converge...
Starting Chef Client, version 11.8.0
[2013-12-01T23:59:22+00:00] INFO: *** Chef 11.8.0 ***
[2013-12-01T23:59:22+00:00] INFO: Chef-client pid: 1307
[2013-12-01T23:59:22+00:00] INFO: Setting the run_list to ["recipe[git::server]"] from JSON
[2013-12-01T23:59:22+00:00] INFO: Run List is [recipe[git::server]]
[2013-12-01T23:59:22+00:00] INFO: Run List expands to [git::server]
[2013-12-01T23:59:22+00:00] INFO: Starting Chef Run for server-ubuntu-1204
[2013-12-01T23:59:22+00:00] INFO: Running start handlers
[2013-12-01T23:59:22+00:00] INFO: Start handlers complete.
Compiling Cookbooks...

================================================================================
Recipe Compile Error in /tmp/kitchen/cookbooks/git/recipes/server.rb
================================================================================


Chef::Exceptions::CookbookNotFound
----------------------------------
Cookbook runit not found. If you're loading runit from another cookbook, make sure you configure the dependency in your metadata


Cookbook Trace:
---------------
  /tmp/kitchen/cookbooks/git/recipes/server.rb:2:in `from_file'


Relevant File Content:
----------------------
/tmp/kitchen/cookbooks/git/recipes/server.rb:

  1:  include_recipe "git"
  2>> include_recipe "runit"
  3:
  4:  package "git-daemon-run"
         5:
         6:  runit_service "git-daemon" do
         7:      sv_templates false
         8:  end
         9:


[2013-12-01T23:59:22+00:00] ERROR: Running exception handlers
[2013-12-01T23:59:22+00:00] ERROR: Exception handlers complete
       [2013-12-01T23:59:22+00:00] FATAL: Stacktrace dumped to /tmp/kitchen/cache/chef-stacktrace.out

Chef Client failed. 0 resources updated
[2013-12-01T23:59:22+00:00] ERROR: Cookbook runit not found. If you're loading runit from another cookbook, make sure you configure the dependency in your metadata
[2013-12-01T23:59:22+00:00] FATAL: Chef::Exceptions::ChildConvergeError: Chef run process exited unsuccessfully (exit code 1)
>>>>>> Converge failed on instance <server-ubuntu-1204>.
>>>>>> Please see .kitchen/logs/server-ubuntu-1204.log for more details
>>>>>> ------Exception-------
>>>>>> Class: Kitchen::ActionFailed
>>>>>> Message: SSH exited (1) for command: [sudo -E chef-solo --config /tmp/kitchen/solo.rb --json-attributes /tmp/kitchen/dna.json  --log_level info]
>>>>>> ----------------------
~~~

See what the Chef run told you?

>> "Cookbook runit not found. If you're loading runit from another cookbook, make sure you configure the dependency in your metadata"

Hey, that's exactly what we need to do!
