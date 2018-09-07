---
title: Adding a Test
slug: adding-test
menu:
  docs:
    parent: getting_started
    weight: 150
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

describe service('git-daemon') do
  it { should be_enabled }
  it { should be_running }
end
~~~

This test checks that a process is listening on port 9418 and a service called "git-daemon" is installed, enabled, and running.

As our primary target platform was Ubuntu 16.04, we'll target this one first for development. Now, in Test-Driven style we'll run `kitchen verify` to watch our tests fail spectacularly:

~~~
...
================================================================================
Recipe Compile Error
================================================================================

Chef::Exceptions::RecipeNotFound
--------------------------------
could not find recipe server for cookbook git_cookbook
...
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
