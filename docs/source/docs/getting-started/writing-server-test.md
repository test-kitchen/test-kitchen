---
title: Writing a Server Test
prev:
  text: "Add a Suite"
  url: "adding-suite"
next:
  text: "Writing a Failing Recipe"
  url: "writing-failing-recipe"
---

Now to write a test or two. Previously we've seen the bats testing framework in action but this isn't always a viable option. For example if you needed to verify that a package was installed and you needed to test that on Ubuntu and CentOS platforms, then what would you do? You need to bust out some platform detection in order to run a Debian or RPM-based command. Feels like Chef would help us here since it's good at that sort of thing. On the other hand there are advantages to treating our Chef run as a black box - a configuration-management implementation detail, if you will. So what to do?

A nice solution to the platform-agnostic test issue exists called [Serverspec](http://serverspec.org/). It is a set of RSpec matchers that can assert things about servers like packages installed, services enabled, ports listening, etc. Let's see what this looks like for our Git Daemon tests.

First we're going to create a directory for our test file:

~~~
mkdir -p test/integration/server/serverspec
~~~

Next, create a file called `test/integration/server/serverspec/git_daemon_spec.rb` with the following:

~~~ruby
require 'serverspec'

include Serverspec::Helper::Exec
include Serverspec::Helper::DetectOS

RSpec.configure do |c|
  c.before :all do
    c.path = '/sbin:/usr/sbin'
  end
end

describe "Git Daemon" do

  it "is listening on port 9418" do
    expect(port(9418)).to be_listening
  end

  it "has a running service of git-daemon" do
    expect(service("git-daemon")).to be_running
  end

end
~~~

The beginning stanzas are RSpec and Serverspec setup and the meat of our testing is in the `describe "Git Daemon"` Ruby block. In short, it's asserting that we will have a server listening on port 9418 and a running service called "git-daemon".

As our primary target platform was Ubuntu 12.04, we'll target this one first for development. Now, in Test-Driven style we'll run `kitchen verify` to watch our tests fail spectacularly:

~~~
$ kitchen verify server-ubuntu-1204
-----> Starting Kitchen (v1.0.0)
-----> Creating <server-ubuntu-1204>...
       Bringing machine 'default' up with 'virtualbox' provider...
       [default] Importing base box 'opscode-ubuntu-12.04'...
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
       [default] Waiting for machine to boot. This may take a few minutes...
       [default] Machine booted and ready!
       [default] Setting hostname...
       [default] Mounting shared folders...
       Vagrant instance <server-ubuntu-1204> created.
       Finished creating <server-ubuntu-1204> (0m35.69s).
-----> Converging <server-ubuntu-1204>...
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
Unpacking chef (from .../tmp.H1RNfFn1/chef__amd64.deb) ...
Setting up chef (11.8.0-1.ubuntu.12.04) ...
Thank you for installing Chef!
       Transfering files to <server-ubuntu-1204>
[2013-12-01T18:32:58+00:00] INFO: Forking chef instance to converge...
Starting Chef Client, version 11.8.0
[2013-12-01T18:32:58+00:00] INFO: *** Chef 11.8.0 ***
[2013-12-01T18:32:58+00:00] INFO: Chef-client pid: 1147
[2013-12-01T18:32:58+00:00] INFO: Setting the run_list to ["recipe[git::server]"] from JSON
[2013-12-01T18:32:58+00:00] INFO: Run List is [recipe[git::server]]
[2013-12-01T18:32:58+00:00] INFO: Run List expands to [git::server]
[2013-12-01T18:32:58+00:00] INFO: Starting Chef Run for server-ubuntu-1204
[2013-12-01T18:32:58+00:00] INFO: Running start handlers
[2013-12-01T18:32:58+00:00] INFO: Start handlers complete.
Compiling Cookbooks...

================================================================================
Recipe Compile Error
================================================================================


Chef::Exceptions::RecipeNotFound
--------------------------------
could not find recipe server for cookbook git


[2013-12-01T18:32:58+00:00] ERROR: Running exception handlers
[2013-12-01T18:32:58+00:00] ERROR: Exception handlers complete
[2013-12-01T18:32:58+00:00] FATAL: Stacktrace dumped to /tmp/kitchen/cache/chef-stacktrace.out
Chef Client failed. 0 resources updated
[2013-12-01T18:32:58+00:00] ERROR: could not find recipe server for cookbook git
[2013-12-01T18:32:58+00:00] FATAL: Chef::Exceptions::ChildConvergeError: Chef run process exited unsuccessfully (exit code 1)
>>>>>> Converge failed on instance <server-ubuntu-1204>.
>>>>>> Please see .kitchen/logs/server-ubuntu-1204.log for more details
>>>>>> ------Exception-------
>>>>>> Class: Kitchen::ActionFailed
>>>>>> Message: SSH exited (1) for command: [sudo -E chef-solo --config /tmp/kitchen/solo.rb --json-attributes /tmp/kitchen/dna.json  --log_level info]
>>>>>> ----------------------
~~~

One quick check of `kitchen list` tells us that our instance was created by not successfully converged:

~~~
$ kitchen list server-ubuntu-1204
Instance            Driver   Provisioner  Last Action
server-ubuntu-1204  Vagrant  ChefSolo     Created
~~~

Yes, you can specify one or more instances with the same Ruby regular expression globbing as any other `kitchen` subcommands.

Okay, no recipe called `server` in our Git cookbook. Let's go start one.
