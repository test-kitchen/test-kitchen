---
title: "kitchen converge"
slug: running-converge
menu:
  docs:
    parent: getting_started
    weight: 70
---

Now that we have a recipe, let's use `kitchen converge` to see if it works:

```text
-----> Starting Test Kitchen (v3.2.2)
-----> Converging <default-ubuntu-2004>...
       Preparing files for transfer
       Policy lock file doesn't exist, running `chef install` for Policyfile /Users/tsmith/git_cookbook/Policyfile.rb...
       Building policy git_cookbook
       Expanded run list: recipe[git_cookbook::default]
       Caching Cookbooks...
       Installing git_cookbook >= 0.0.0 from path

       Lockfile written to /Users/tsmith/git_cookbook/Policyfile.lock.json
       Policy revision id: f9aaaeaa7a929e3370d5224a3c7f07c605721933b9a893d383d0dc478aa48ce8
       Preparing dna.json
       Exporting cookbook dependencies from Policyfile /var/folders/99/1b6ms59j59sbl9t85sm75y8h0000gp/T/default-ubuntu-2004-sandbox-20200610-73309-h1lqd...
       Exported policy 'git_cookbook' to /var/folders/99/1b6ms59j59sbl9t85sm75y8h0000gp/T/default-ubuntu-2004-sandbox-20200610-73309-h1lqd

       To converge this system with the exported policy, run:
         cd /var/folders/99/1b6ms59j59sbl9t85sm75y8h0000gp/T/default-ubuntu-2004-sandbox-20200610-73309-h1lqd
         chef-client -z
       Removing non-cookbook files before transfer
       Preparing validation.pem
       Preparing client.rb
-----> Installing Chef install only if missing package
       Downloading https://omnitruck.chef.io/install.sh to file /tmp/install.sh
       Trying wget...
       Download complete.
       ubuntu 20.04 x86_64
       Getting information for chef stable  for ubuntu...
       downloading https://omnitruck.chef.io/stable/chef/metadata?v=&p=ubuntu&pv=20.04&m=x86_64
         to file /tmp/install.sh.1526/metadata.txt
       trying wget...
       sha1 1466b9dbfcce80987e145d58e12c076216f9a5b5
       sha256 f1f1cc5787bb56d5d3cb37339bb458f8d715e0be9a58abaad7e52ade90a2bfec
       url https://packages.chef.io/files/stable/chef/17.9.42/ubuntu/20.04/chef_17.9.42-1_amd64.deb
       version 17.9.42
       downloaded metadata file looks valid...
       /tmp/omnibus/cache/chef_17.9.42-1_amd64.deb exists
       Comparing checksum with sha256sum...

       WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING

       You are installing a package without a version pin.  If you are installing
       on production servers via an automated process this is DANGEROUS and you will
       be upgraded without warning on new releases, even to new major releases.
       Letting the version float is only appropriate in desktop, test, development or
       CI/CD environments.

       WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING

       Installing chef
       installing with dpkg...
       Selecting previously unselected package chef.
(Reading database ... 44414 files and directories currently installed.)
       Preparing to unpack .../cache/chef_17.9.42-1_amd64.deb ...
       Unpacking chef (17.9.42-1) ...
       Setting up chef (17.9.42-1) ...
       Thank you for installing Chef Infra Client! For help getting started visit https://learn.chef.io
       Transferring files to <default-ubuntu-2004>
       +---------------------------------------------+
       ✔ 2 product licenses accepted.
       +---------------------------------------------+
       Starting Chef Infra Client, version 17.9.42
       Creating a new client identity for default-ubuntu-2004 using the validator key.
       Using policy 'git_cookbook' at revision 'f9aaaeaa7a929e3370d5224a3c7f07c605721933b9a893d383d0dc478aa48ce8'
       resolving cookbooks for run list: ["git_cookbook::default@0.1.0 (4def6b4)"]
       Synchronizing Cookbooks:
         - git_cookbook (0.1.0)
       Installing Cookbook Gems:
       Compiling Cookbooks...
       Converging 1 resources
       Recipe: git_cookbook::default
         * apt_package[git] action install (up to date)

       Running handlers:
       Running handlers complete
       Chef Infra Client finished, 0/1 resources updated in 01 seconds
       Downloading files from <default-ubuntu-2004>
       Finished converging <default-ubuntu-2004> (0m13.07s).
-----> Test Kitchen is finished. (0m14.99s)
```

If you are a Chef Infra user then part of the output above should look familiar to you. Here's what happened at a high level:

* Chef Infra Client was installed on the instance
* The `git_cookbook` files and a minimal Chef Infra Client configuration were built and uploaded to the instance
* A Chef Infra Client run was initiated using the run-list and node attributes specified in the `kitchen.yml` file

Looking closely at the run, there are two important things we want to note: git was already installed as part of the base image so Chef Infra Client reports `(up to date)` as it didn't have to do anything.

<div class="callout">
<h3 class="callout--title">Pro Tip</h3>
This highlights a property of configuration management systems, like Chef Infra, called <b>idempotence</b> - in this context, Chef Infra Client saw that we requested to install git but as it was already installed there was nothing to do. This concept is very useful when thinking about configuration management generally as unlike a bash script, Chef Infra cookbooks aren't a series of commands but a set of declarations about the desired state.
</div>

A **converge** will leave the machine running and kitchen automatically uploads changes each converge so that one can iterate rapidly on configuration code. A lot of time and effort has gone into ensuring that the exit code of kitchen is always appropriate. Here is the Test Kitchen Command Guarantee:

* I will always exit with code **0** if my operation was successful.
* I will always exit with a non-zero code if **any** part of my operation was not successful.
* Any behavior to the contrary **is a bug**.

This exit code behavior is a fundamental prerequisite for any tool working in a Continuous Integration (CI) environment.

<div class="sidebar--footer">
<a class="button primary-cta" href="/docs/getting-started/manually-verifying">Next - Manually Verifying</a>
<a class="sidebar--footer--back" href="/docs/getting-started/writing-recipe">Back to previous step</a>
</div>
