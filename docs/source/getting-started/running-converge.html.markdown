---
title: "Running Kitchen Converge"
next:
  text: "Manually verifying"
  url: "manually-verifying"
---

Now that we have some code, let's let Test Kitchen run it for us on our Ubuntu 12.04 instance:

```
$ kitchen converge default-ubuntu-1204
-----> Starting Kitchen (v1.0.0.beta.3)
-----> Converging <default-ubuntu-1204>
-----> Installing Chef Omnibus (true)
--2013-10-17 06:30:01--  https://www.opscode.com/chef/install.sh
Resolving www.opscode.com (www.opscode.com)... 184.106.28.83
Connecting to www.opscode.com (www.opscode.com)|184.106.28.83|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 6790 (6.6K) [application/x-sh]
Saving to: `STDOUT'

100%[======================================>] 6,790       --.-K/s   in 0s

2013-10-17 06:30:01 (45.6 MB/s) - written to stdout [6790/6790]

Downloading Chef  for ubuntu...
Installing Chef
Selecting previously unselected package chef.
(Reading database ... 53291 files and directories currently installed.)
Unpacking chef (from .../tmp.DG6AAIZy/chef__amd64.deb) ...
Setting up chef (11.6.2-1.ubuntu.12.04) ...
Thank you for installing Chef!
       Preparing current project directory as a cookbook
       Removing non-cookbook files in sandbox
       Uploaded /var/folders/ld/ykg04kvx5y53v7qkhpp254y40000gn/T/default-ubuntu-1204-sandbox-20131017-64178-1uu6djw/cookbooks/git/metadata.rb (27 bytes)
       Uploaded /var/folders/ld/ykg04kvx5y53v7qkhpp254y40000gn/T/default-ubuntu-1204-sandbox-20131017-64178-1uu6djw/cookbooks/git/recipes/default.rb (45 bytes)
       Uploaded /var/folders/ld/ykg04kvx5y53v7qkhpp254y40000gn/T/default-ubuntu-1204-sandbox-20131017-64178-1uu6djw/dna.json (28 bytes)
       Uploaded /var/folders/ld/ykg04kvx5y53v7qkhpp254y40000gn/T/default-ubuntu-1204-sandbox-20131017-64178-1uu6djw/solo.rb (168 bytes)
[2013-10-17T06:30:28+00:00] INFO: Forking chef instance to converge...
Starting Chef Client, version 11.6.2
[2013-10-17T06:30:28+00:00] INFO: *** Chef 11.6.2 ***
[2013-10-17T06:30:28+00:00] INFO: Setting the run_list to ["recipe[git]"] from JSON
[2013-10-17T06:30:28+00:00] INFO: Run List is [recipe[git]]
[2013-10-17T06:30:28+00:00] INFO: Run List expands to [git]
[2013-10-17T06:30:28+00:00] INFO: Starting Chef Run for default-ubuntu-1204
[2013-10-17T06:30:28+00:00] INFO: Running start handlers
[2013-10-17T06:30:28+00:00] INFO: Start handlers complete.
Compiling Cookbooks...
Converging 2 resources
Recipe: git::default
  * package[git] action install

[2013-10-17T06:30:28+00:00] INFO: Processing package[git] action install (git::default line 1)

    - install version 1:1.7.9.5-1 of package git

  * log[Well, that was too easy] action write

[2013-10-17T06:30:45+00:00] INFO: Processing log[Well, that was too easy] action write (git::default line 3)
[2013-10-17T06:30:45+00:00] INFO: Well, that was too easy


[2013-10-17T06:30:45+00:00] INFO: Chef Run complete in 16.548136457 seconds
[2013-10-17T06:30:45+00:00] INFO: Running report handlers
[2013-10-17T06:30:45+00:00] INFO: Report handlers complete
Chef Client finished, 2 resources updated
       Finished converging <default-ubuntu-1204> (0m44.16s).
-----> Kitchen is finished. (0m44.45s)
```

To quote our Chef run, that **was** too easy. If you are a Chef user then part of the output above should look familiar to you. Here's what happened at a high level:

* Chef was installed on the instance by performing an [Omnibus pacakge installation](http://www.opscode.com/chef/install/)
* Your Git cookbook files and a minimal Chef Solo configuration were built and uploaded to the instance
* A Chef run was initiated using the run-list and node attributes specified in the `.kitchen.yml` file

There's nothing to stop you from running this command again (or over-and-over for that matter) so, let's see what happens:

```
$ kitchen converge default-ubuntu-1204
-----> Starting Kitchen (v1.0.0.beta.3)
-----> Converging <default-ubuntu-1204>
       Preparing current project directory as a cookbook
       Removing non-cookbook files in sandbox
       Uploaded /tmp/default-ubuntu-1204-sandbox-20131019-85020-14lhsfx/cookbooks/git/metadata.rb (27 bytes)
       Uploaded /tmp/default-ubuntu-1204-sandbox-20131019-85020-14lhsfx/cookbooks/git/recipes/default.rb (45 bytes)
       Uploaded /tmp/default-ubuntu-1204-sandbox-20131019-85020-14lhsfx/dna.json (28 bytes)
       Uploaded /tmp/default-ubuntu-1204-sandbox-20131019-85020-14lhsfx/solo.rb (168 bytes)
[2013-10-19T19:41:48+00:00] INFO: Forking chef instance to converge...
Starting Chef Client, version 11.6.2
[2013-10-19T19:41:48+00:00] INFO: *** Chef 11.6.2 ***
[2013-10-19T19:41:49+00:00] INFO: Setting the run_list to ["recipe[git]"] from JSON
[2013-10-19T19:41:49+00:00] INFO: Run List is [recipe[git]]
[2013-10-19T19:41:49+00:00] INFO: Run List expands to [git]
[2013-10-19T19:41:49+00:00] INFO: Starting Chef Run for default-ubuntu-1204
[2013-10-19T19:41:49+00:00] INFO: Running start handlers
[2013-10-19T19:41:49+00:00] INFO: Start handlers complete.
Compiling Cookbooks...
Converging 2 resources
Recipe: git::default
  * package[git] action install[2013-10-19T19:41:49+00:00] INFO: Processing package[git] action install (git::default line 1)
 (up to date)
  * log[Well, that was too easy] action write[2013-10-19T19:41:49+00:00] INFO: Processing log[Well, that was too easy] action write (git::default line 3)
[2013-10-19T19:41:49+00:00] INFO: Well, that was too easy


[2013-10-19T19:41:49+00:00] INFO: Chef Run complete in 0.069126629 seconds
[2013-10-19T19:41:49+00:00] INFO: Running report handlers
[2013-10-19T19:41:49+00:00] INFO: Report handlers complete
Chef Client finished, 1 resources updated
       Finished converging <default-ubuntu-1204> (0m1.95s).
-----> Kitchen is finished. (0m2.40s)
```

That ran a **lot** faster didn't it? Here's what happened this time:

* Test Kitchen found that Chef was present and installed so skipped a re-installation.
* The same Chef cookbook files and Chef Solo configuration was uploaded to the instance. Test Kitchen is optimizing for **freshness of code and configuration over speed**. Although we all like speed wherever possible.
* A Chef run is initiated and runs very quickly as we are in the desired state.

<div class="well">
  <h4><span class="glyphicon glyphicon-pushpin"></span> Pro-Tip</h4>
  <p>A lot of time and effort has gone into ensuring that the exit code of Test Kitchen is always appropriate. Here is the Kitchen Command Guarentee:</p>
  <ol>
    <li>I will always exit with code <strong>0</strong> if my operation was successful.</li>
    <li>I will always exit with a non-zero code if <strong>any</strong> part of my operation was not successful.</li>
    <li>Any behavior to the contrary <strong>is a bug</strong>.</li>
  </ol>
  <p>This exit code behavior is a funamental prerequisite for any tool working in a Continuous Integration (CI) environment.</p>
</div>

Let's check the status of our instance:

```
$ kitchen list
Instance             Driver   Provisioner  Last Action
default-ubuntu-1204  Vagrant  Chef Solo    Converged
```

A clean converge run, success! Let's commit our production code and move on:

```
$ git add recipes/default.rb
$ git commit -m "Implemented the default recipe, woot woot."
[master a333057] Implemented the default recipe, woot woot.
 1 file changed, 3 insertions(+)
```
