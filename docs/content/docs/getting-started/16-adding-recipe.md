---
title: Adding a Recipe
slug: adding-recipe
menu:
  docs:
    parent: getting_started
    weight: 160
---

As we've already added our tests, we have a pretty good idea of what needs to happen.

With this solution in mind we'll create a file called `recipes/server.rb` with the following:

~~~
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
~~~

Before we give our new recipe a go, a quick detour to cover how we might exclude a particular platform from a suite's tests.

<div class="sidebar--footer">
<a class="button primary-cta" href="/docs/getting-started/excluding-platforms">Next - Excluding Platforms</a>
<a class="sidebar--footer--back" href="/docs/getting-started/adding-test">Back to previous step</a>
</div>
