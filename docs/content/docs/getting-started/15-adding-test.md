---
title: Adding a Test
slug: adding-test
menu:
  docs:
    parent: getting_started
    weight: 150
---

Our first test was created for us automatically for us by our cookbook generator so here we will create the folders and files manually.

First we're going to create a directory for our test file:

```bash
mkdir -p test/integration/server
```

Next, create a file called `test/integration/server/git_daemon_test.rb` with the following:

```ruby
# InSpec test for recipe git_cookbook::server

describe port(9418) do
  it { should be_listening }
end

describe service('git-daemon') do
  it { should be_enabled }
  it { should be_running }
end
```

This test checks that a process is listening on port 9418 and a service called "git-daemon" is installed, enabled, and running.

As our primary target platform was Ubuntu 24.04, we'll target this one first for development. Now, in test driven development (TDD) style we'll run `kitchen test server` to watch our tests fail spectacularly:

```ruby
...
================================================================================
Chef encountered an error attempting to load the node data for "server-ubuntu-2404"
================================================================================

Unexpected Error:
-----------------
Chef::PolicyBuilder::Policyfile::ConfigurationError: Policy 'git_cookbook' revision 'f9aaaeaa7a929e3370d5224a3c7f07c605721933b9a893d383d0dc478aa48ce8' does not have named_run_list 'server'(available named_run_lists: [])
...
```

One quick check of `kitchen list` tells us that our instance was created but not successfully converged:

```ruby
$ kitchen list server-ubuntu-2404
Instance            Driver   Provisioner  Verifier  Transport  Last Action  Last Error
server-ubuntu-2404  Vagrant  ChefInfra     Inspec    Ssh        Created      Kitchen::ActionFailed
```

Yes, you can specify one or more instances with the same Ruby regular expression globbing as any other `kitchen` sub-commands.

Test Kitchen fails because we've set up our `server` suite to run a Policyfile named run list of `server`, but no named run list exists in our Policyfile and we haven't created the `server` recipe in our Git cookbook. Let's go fix our Policyfile and create our recipe.

<div class="sidebar--footer">
<a class="button primary-cta" href="/docs/getting-started/adding-recipe">Next - Adding a Recipe</a>
<a class="sidebar--footer--back" href="/docs/getting-started/adding-suite">Back to previous step</a>
</div>
