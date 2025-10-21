---
title: Adding a Recipe
slug: adding-recipe
menu:
  docs:
    parent: getting_started
    weight: 160
---

As we've already added our tests, we have a pretty good idea of what needs to happen.

First let's add the `server` named run list to the `Policyfile.rb` in our cookbook by making that file look something like this:

```ruby
# Policyfile.rb - Describe how you want Chef Infra Client to build your system.
#
# For more information on the Policyfile feature, visit
# https://docs.chef.io/policyfile/

# Use the cookbook's metadata.rb file for sourcing the name and other details
metadata

# Where to find external cookbooks:
default_source :supermarket

# run_list: chef-client will run these recipes in the order specified.
run_list 'git_cookbook::default'

named_run_list :server, "git_cookbook::server"
```

To apply the changes we've just made to `Policyfile.rb` let's now run `chef update`.

With our Policyfile updated to point to the server recipe it's time to create that recipe by creating a file called `recipes/server.rb` with the following:

```ruby
# the default recipe is implied if only the cookbook name is provided
# effectively `include_recipe "git_cookbook::default"`
include_recipe "git_cookbook"

# install the above `daemon_pkg`
package 'git-daemon-run'

# create our data directory
directory '/opt/git'

# setup the systemd unit (service) with the above `daemon_bin`, enable, and
# start it
systemd_unit 'git-daemon.service' do
  content <<-EOU.gsub(/^\s+/, '')
    [Unit]
    Description=Git Repositories Server Daemon
    Documentation=man:git-daemon(1)

    [Service]
    ExecStart=/usr/bin/git daemon \
    --reuseaddr \
    --base-path=/opt/git/ \
    /opt/git/

    [Install]
    WantedBy=getty.target
    DefaultInstance=tty1
    EOU

  action [ :create, :enable, :start ]
end
```

Before we give our new recipe a go, a quick detour to cover how we might exclude a particular platform from a suite's tests.

<div class="sidebar--footer">
<a class="button primary-cta" href="17-excluding-platforms.md">Next - Excluding Platforms</a>
<a class="sidebar--footer--back" href="15-adding-test.md">Back to previous step</a>
</div>
