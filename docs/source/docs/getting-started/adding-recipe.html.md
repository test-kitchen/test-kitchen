---
title: Adding a Recipe
---

So far our cookbook has no dependencies on other cookbooks to get its job done which is awesome! But let's say we require dependant cookbooks. For our example we'll be relying on the [runit](http://community.opscode.com/cookbooks/runit) cookbook to manage our Git Daemon service.


With this solution in mind we'll create a file called `recipes/server.rb` with the following:

~~~ruby
include_recipe "git_cookbook"
include_recipe "runit"

package "git-daemon-run"

runit_service "git-daemon" do
  sv_templates false
end
~~~

Reasonably straight forward code. Here's what is going on:

* We include our default Git recipe so that Git is installed. Hey we already solved that one, right?
* We include the default recipe from the runit cookbook which installs runit and provides the `runit_service` resource.
* We install the `git-daemon-run` package which gives us the `git-daemon` program, on Ubuntu 16.04 at least.
* Finally, we declare a runit service called `git-daemon` without generating the run and log scripts (they were provided by the Ubuntu package).

Now to see the fruits of our effort:

~~~
kitchen verify server-ubuntu-1604
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
       Installing Cookbook Gems:
       Compiling Cookbooks...
       [2017-05-08T15:52:47+00:00] WARN: MissingCookbookDependency:
       Recipe `runit` is not in the run_list, and cookbook 'runit'
       is not a dependency of any cookbook in the run_list.  To load this recipe,
       first add a dependency on cookbook 'runit' in the cookbook you're
       including it from in that cookbook's metadata.

       [2017-05-08T15:52:47+00:00] WARN: MissingCookbookDependency:
       Recipe `runit` is not in the run_list, and cookbook 'runit'
       is not a dependency of any cookbook in the run_list.  To load this recipe,
       first add a dependency on cookbook 'runit' in the cookbook you're
       including it from in that cookbook's metadata.


       ================================================================================
       Recipe Compile Error in /tmp/kitchen/cache/cookbooks/git_cookbook/recipes/server.rb
       ================================================================================

       Chef::Exceptions::CookbookNotFound
       ----------------------------------
       Cookbook runit not found. If you're loading runit from another cookbook, make sure you configure the dependency in your metadata

       Cookbook Trace:
       ---------------
         /tmp/kitchen/cache/cookbooks/git_cookbook/recipes/server.rb:8:in `from_file'

       Relevant File Content:
       ----------------------
       /tmp/kitchen/cache/cookbooks/git_cookbook/recipes/server.rb:

         1:  #
         2:  # Cookbook:: git_cookbook
         3:  # Recipe:: server
         4:  #
         5:  # Copyright:: 2017, The Authors, All Rights Reserved.
         6:  #
         7:  include_recipe "git_cookbook"
         8>> include_recipe "runit"
         9:
        10:  package "git-daemon-run"
        11:
        12:  runit_service "git-daemon" do
        13:    sv_templates false
        14:  end
        15:

       System Info:
       ------------
       chef_version=13.0.118
       platform=ubuntu
       platform_version=16.04
       ruby=ruby 2.4.1p111 (2017-03-22 revision 58053) [x86_64-linux]
       program_name=chef-client worker: ppid=1912;start=15:52:46;
       executable=/opt/chef/bin/chef-client


       Running handlers:
       [2017-05-08T15:52:47+00:00] ERROR: Running exception handlers
       [2017-05-08T15:52:47+00:00] ERROR: Running exception handlers
       Running handlers complete
       [2017-05-08T15:52:47+00:00] ERROR: Exception handlers complete
       [2017-05-08T15:52:47+00:00] ERROR: Exception handlers complete
       Chef Client failed. 0 resources updated in 01 seconds
       [2017-05-08T15:52:47+00:00] FATAL: Stacktrace dumped to /tmp/kitchen/cache/chef-stacktrace.out
       [2017-05-08T15:52:47+00:00] FATAL: Stacktrace dumped to /tmp/kitchen/cache/chef-stacktrace.out
       [2017-05-08T15:52:47+00:00] FATAL: Please provide the contents of the stacktrace.out file if you file a bug report
       [2017-05-08T15:52:47+00:00] FATAL: Please provide the contents of the stacktrace.out file if you file a bug report
       [2017-05-08T15:52:47+00:00] ERROR: Cookbook runit not found. If you're loading runit from another cookbook, make sure you configure the dependency in your metadata
       [2017-05-08T15:52:47+00:00] ERROR: Cookbook runit not found. If you're loading runit from another cookbook, make sure you configure the dependency in your metadata
       [2017-05-08T15:52:47+00:00] FATAL: Chef::Exceptions::ChildConvergeError: Chef run process exited unsuccessfully (exit code 1)
       [2017-05-08T15:52:47+00:00] FATAL: Chef::Exceptions::ChildConvergeError: Chef run process exited unsuccessfully (exit code 1)
>>>>>> ------Exception-------
>>>>>> Class: Kitchen::ActionFailed
>>>>>> Message: 1 actions failed.
>>>>>>     Converge failed on instance <server-ubuntu-1604>.  Please see .kitchen/logs/server-ubuntu-1604.log for more details
>>>>>> ----------------------
>>>>>> Please see .kitchen/logs/kitchen.log for more details
>>>>>> Also try running `kitchen diagnose --all` for configuration
~~~

See what the Chef run told you?

>> "Cookbook runit not found. If you're loading runit from another cookbook, make sure you configure the dependency in your metadata"

Hey, that's exactly what we need to do!

<div class="sidebar--footer">
<a class="button primary-cta" href="adding-dependency">Next - Adding a Dependency</a>
<a class="sidebar--footer--back" href="adding-test">Back to previous step</a>
</div>
