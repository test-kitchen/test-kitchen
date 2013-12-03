---
title: "Running Kitchen Converge"
prev:
  text: "Writing a Recipe"
  url: "writing-recipe"
next:
  text: "Manually verifying"
  url: "manually-verifying"
---

Now that we have some code, let's let Test Kitchen run it for us on our Ubuntu 12.04 instance:

~~~
$ kitchen converge default-ubuntu-1204
-----> Starting Kitchen (v1.0.0)
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
Unpacking chef (from .../tmp.GUasmrcD/chef__amd64.deb) ...
Setting up chef (11.8.0-1.ubuntu.12.04) ...
Thank you for installing Chef!
       Transfering files to <default-ubuntu-1204>
[2013-11-30T21:55:45+00:00] INFO: Forking chef instance to converge...
Starting Chef Client, version 11.8.0
[2013-11-30T21:55:45+00:00] INFO: *** Chef 11.8.0 ***
[2013-11-30T21:55:45+00:00] INFO: Chef-client pid: 1162
[2013-11-30T21:55:46+00:00] INFO: Setting the run_list to ["recipe[git::default]"] from JSON
[2013-11-30T21:55:46+00:00] INFO: Run List is [recipe[git::default]]
[2013-11-30T21:55:46+00:00] INFO: Run List expands to [git::default]
[2013-11-30T21:55:46+00:00] INFO: Starting Chef Run for default-ubuntu-1204
[2013-11-30T21:55:46+00:00] INFO: Running start handlers
[2013-11-30T21:55:46+00:00] INFO: Start handlers complete.
Compiling Cookbooks...
Converging 2 resources
Recipe: git::default
  * package[git] action install[2013-11-30T21:55:46+00:00] INFO: Processing package[git] action install (git::default line 1)

    - install version 1:1.7.9.5-1 of package git

  * log[Well, that was too easy] action write[2013-11-30T21:56:14+00:00] INFO: Processing log[Well, that was too easy] action write (git::default line 3)
[2013-11-30T21:56:14+00:00] INFO: Well, that was too easy


[2013-11-30T21:56:14+00:00] INFO: Chef Run complete in 28.139177847 seconds
[2013-11-30T21:56:14+00:00] INFO: Running report handlers
[2013-11-30T21:56:14+00:00] INFO: Report handlers complete
Chef Client finished, 2 resources updated
       Finished converging <default-ubuntu-1204> (1m3.91s).
-----> Kitchen is finished. (1m4.22s)
~~~

To quote our Chef run, that **was** too easy. If you are a Chef user then part of the output above should look familiar to you. Here's what happened at a high level:

* Chef was installed on the instance by performing an [Omnibus package installation](http://www.opscode.com/chef/install/)
* Your Git cookbook files and a minimal Chef Solo configuration were built and uploaded to the instance
* A Chef run was initiated using the run-list and node attributes specified in the `.kitchen.yml` file

There's nothing to stop you from running this command again (or over-and-over for that matter) so, let's see what happens:

~~~
$ kitchen converge default-ubuntu-1204
-----> Starting Kitchen (v1.0.0)
-----> Converging <default-ubuntu-1204>...
       Preparing files for transfer
       Preparing current project directory as a cookbook
       Removing non-cookbook files before transfer
       Transfering files to <default-ubuntu-1204>
[2013-11-30T21:57:00+00:00] INFO: Forking chef instance to converge...
Starting Chef Client, version 11.8.0
[2013-11-30T21:57:00+00:00] INFO: *** Chef 11.8.0 ***
[2013-11-30T21:57:00+00:00] INFO: Chef-client pid: 4142
[2013-11-30T21:57:01+00:00] INFO: Setting the run_list to ["recipe[git::default]"] from JSON
[2013-11-30T21:57:01+00:00] INFO: Run List is [recipe[git::default]]
[2013-11-30T21:57:01+00:00] INFO: Run List expands to [git::default]
[2013-11-30T21:57:01+00:00] INFO: Starting Chef Run for default-ubuntu-1204
[2013-11-30T21:57:01+00:00] INFO: Running start handlers
[2013-11-30T21:57:01+00:00] INFO: Start handlers complete.
Compiling Cookbooks...
Converging 2 resources
Recipe: git::default
  * package[git] action install[2013-11-30T21:57:01+00:00] INFO: Processing package[git] action install (git::default line 1)
 (up to date)
  * log[Well, that was too easy] action write[2013-11-30T21:57:01+00:00] INFO: Processing log[Well, that was too easy] action write (git::default line 3)
[2013-11-30T21:57:01+00:00] INFO: Well, that was too easy


[2013-11-30T21:57:01+00:00] INFO: Chef Run complete in 0.069998015 seconds
[2013-11-30T21:57:01+00:00] INFO: Running report handlers
[2013-11-30T21:57:01+00:00] INFO: Report handlers complete
Chef Client finished, 1 resources updated
       Finished converging <default-ubuntu-1204> (0m1.67s).
-----> Kitchen is finished. (0m1.99s)
~~~

That ran a **lot** faster didn't it? Here's what happened this time:

* Test Kitchen found that Chef was present and installed so skipped a re-installation.
* The same Chef cookbook files and Chef Solo configuration was uploaded to the instance. Test Kitchen is optimizing for **freshness of code and configuration over speed**. Although we all like speed wherever possible.
* A Chef run is initiated and runs very quickly as we are in the desired state.

|| Pro-Tip
|| A lot of time and effort has gone into ensuring that the exit code of Test Kitchen is always appropriate. Here is the Kitchen Command Guarentee:
|| 1. I will always exit with code **0** if my operation was successful.
|| 2. I will always exit with a non-zero code if **any** part of my operation was not successful.
|| 3. Any behavior to the contrary **is a bug**.
|| This exit code behavior is a funamental prerequisite for any tool working in a Continuous Integration (CI) environment.

Let's check the status of our instance:

~~~
$ kitchen list
Instance             Driver   Provisioner  Last Action
default-ubuntu-1204  Vagrant  ChefSolo     Converged
~~~

A clean converge run, success! Let's commit our production code and move on:

~~~
$ git add recipes/default.rb
$ git commit -m "Implemented the default recipe, woot woot."
[master 4d54a16] Implemented the default recipe, woot woot.
 1 file changed, 3 insertions(+)
~~~
