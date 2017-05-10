---
title: Adding a Test
---

##### Adding a Test

Our first test was created for us automatically for us by our cookbook generator so here we will create the folders and files manually.

First we're going to create a directory for our test file:

~~~
mkdir -p test/smoke/server
~~~

Next, create a file called `test/smoke/server/git_daemon_test.rb` with the following:

~~~
# # encoding: utf-8

# Inspec test for recipe git_cookbook::server

describe port(9418) do
  it { should be_listening }
end

describe runit_service('git-daemon') do
  it { should be_installed }
  it { should be_enabled }
  it { should be_running }
end
~~~

In short, this test asserting that we will have a server listening on port 9418 and running a runit service called "git-daemon".

As our primary target platform was Ubuntu 16.04, we'll target this one first for development. Now, in Test-Driven style we'll run `kitchen verify` to watch our tests fail spectacularly:

~~~
kitchen verify server-ubuntu-1604
-----> Starting Kitchen (v1.16.0)
-----> Creating <server-ubuntu-1604>...
       Bringing machine 'default' up with 'virtualbox' provider...
       ==> default: Importing base box 'bento/ubuntu-16.04'...
==> default: Matching MAC address for NAT networking...
       ==> default: Checking if box 'bento/ubuntu-16.04' is up to date...
       ==> default: Setting the name of the VM: kitchen-git_cookbook-server-ubuntu-1604_default_1494257800017_29990
       ==> default: Clearing any previously set network interfaces...
       ==> default: Preparing network interfaces based on configuration...
           default: Adapter 1: nat
       ==> default: Forwarding ports...
           default: 22 (guest) => 2222 (host) (adapter 1)
       ==> default: Booting VM...
       ==> default: Waiting for machine to boot. This may take a few minutes...
           default: SSH address: 127.0.0.1:2222
           default: SSH username: vagrant
           default: SSH auth method: private key
           default:
           default: Vagrant insecure key detected. Vagrant will automatically replace
           default: this with a newly generated keypair for better security.
           default:
           default: Inserting generated public key within guest...
           default: Removing insecure key from the guest if it's present...
           default: Key inserted! Disconnecting and reconnecting using new SSH key...
       ==> default: Machine booted and ready!
       ==> default: Checking for guest additions in VM...
       ==> default: Setting hostname...
       ==> default: Mounting shared folders...
           default: /tmp/omnibus/cache => /Users/cheeseplus/.kitchen/cache
       ==> default: Machine not provisioned because `--no-provision` is specified.
       [SSH] Established
       Vagrant instance <server-ubuntu-1604> created.
       Finished creating <server-ubuntu-1604> (0m37.16s).
-----> Converging <server-ubuntu-1604>...
       Preparing files for transfer
       Preparing dna.json
       Resolving cookbook dependencies with Berkshelf 5.6.4...
       Removing non-cookbook files before transfer
       Preparing validation.pem
       Preparing client.rb
-----> Installing Chef Omnibus (13)
       Downloading https://omnitruck.chef.io/install.sh to file /tmp/install.sh
       Trying wget...
       Download complete.
       ubuntu 16.04 x86_64
       Getting information for chef stable 13 for ubuntu...
       downloading https://omnitruck.chef.io/stable/chef/metadata?v=13&p=ubuntu&pv=16.04&m=x86_64
         to file /tmp/install.sh.1550/metadata.txt
       trying wget...
       sha1     da845676ff2e17b3049ca6e52541389318183f89
       sha256   650e80ad44584ca48716752d411989ab155845af4af7a50c530155d9718843eb
       url      https://packages.chef.io/files/stable/chef/13.0.118/ubuntu/16.04/chef_13.0.118-1_amd64.deb
       version  13.0.118
       downloaded metadata file looks valid...
       /tmp/omnibus/cache/chef_13.0.118-1_amd64.deb already exists, verifiying checksum...
       Comparing checksum with sha256sum...
       checksum compare succeeded, using existing file!
       Installing chef 13
       installing with dpkg...
       Selecting previously unselected package chef.
(Reading database ... 37825 files and directories currently installed.)
       Preparing to unpack .../chef_13.0.118-1_amd64.deb ...
       Unpacking chef (13.0.118-1) ...
       Setting up chef (13.0.118-1) ...
       Thank you for installing Chef!
       Transferring files to <server-ubuntu-1604>
       Starting Chef Client, version 13.0.118
       Creating a new client identity for server-ubuntu-1604 using the validator key.
       resolving cookbooks for run list: ["git_cookbook::server"]
       Synchronizing Cookbooks:
         - git_cookbook (0.1.0)
       Installing Cookbook Gems:
       Compiling Cookbooks...

       ================================================================================
       Recipe Compile Error
       ================================================================================

       Chef::Exceptions::RecipeNotFound
       --------------------------------
       could not find recipe server for cookbook git_cookbook

       System Info:
       ------------
       chef_version=13.0.118
       platform=ubuntu
       platform_version=16.04
       ruby=ruby 2.4.1p111 (2017-03-22 revision 58053) [x86_64-linux]
       program_name=chef-client worker: ppid=1629;start=15:37:17;
       executable=/opt/chef/bin/chef-client


       Running handlers:
       [2017-05-08T15:37:18+00:00] ERROR: Running exception handlers
       [2017-05-08T15:37:18+00:00] ERROR: Running exception handlers
       Running handlers complete
       [2017-05-08T15:37:18+00:00] ERROR: Exception handlers complete
       [2017-05-08T15:37:18+00:00] ERROR: Exception handlers complete
       Chef Client failed. 0 resources updated in 01 seconds
       [2017-05-08T15:37:18+00:00] FATAL: Stacktrace dumped to /tmp/kitchen/cache/chef-stacktrace.out
       [2017-05-08T15:37:18+00:00] FATAL: Stacktrace dumped to /tmp/kitchen/cache/chef-stacktrace.out
       [2017-05-08T15:37:18+00:00] FATAL: Please provide the contents of the stacktrace.out file if you file a bug report
       [2017-05-08T15:37:18+00:00] FATAL: Please provide the contents of the stacktrace.out file if you file a bug report
       [2017-05-08T15:37:18+00:00] ERROR: could not find recipe server for cookbook git_cookbook
       [2017-05-08T15:37:18+00:00] ERROR: could not find recipe server for cookbook git_cookbook
       [2017-05-08T15:37:18+00:00] FATAL: Chef::Exceptions::ChildConvergeError: Chef run process exited unsuccessfully (exit code 1)
       [2017-05-08T15:37:18+00:00] FATAL: Chef::Exceptions::ChildConvergeError: Chef run process exited unsuccessfully (exit code 1)
>>>>>> ------Exception-------
>>>>>> Class: Kitchen::ActionFailed
>>>>>> Message: 1 actions failed.
>>>>>>     Converge failed on instance <server-ubuntu-1604>.  Please see .kitchen/logs/server-ubuntu-1604.log for more details
>>>>>> ----------------------
>>>>>> Please see .kitchen/logs/kitchen.log for more details
>>>>>> Also try running `kitchen diagnose --all` for configuration
~~~

One quick check of `kitchen list` tells us that our instance was created but not successfully converged:

~~~
$ kitchen list server-ubuntu-1604
Instance            Driver   Provisioner  Verifier  Transport  Last Action  Last Error
server-ubuntu-1604  Vagrant  ChefZero     Inspec    Ssh        Created      Kitchen::ActionFailed
~~~

Yes, you can specify one or more instances with the same Ruby regular expression globbing as any other `kitchen` subcommands.

Okay, no recipe called `server` in our Git cookbook. Let's go create one.

<div class="sidebar--footer">
<a class="button primary-cta" href="/docs/getting-started/adding-recipe">Next - Adding a Recipe</a>
<a class="sidebar--footer--back" href="/docs/getting-started/adding-suite">Back to previous step</a>
</div>
