---
title: Full Example
---

Full Example
============
Sometimes it is easier to learn by example. This section serves as a walkthrough guide for creating a cookbook with Test Kitchen support from start-to-finish.


Background
----------
This cookbook has a single recipe (`default.rb`) that installs [tmux](http://tmux.org) and writes a custom tmux configuration file.

```ruby
package 'tmux'

template '/etc/tmux.conf' do
  source 'tmux.conf.erb'
  mode   '0644'
end
```

There is an associated `tmux.conf.erb` template, but it is not shown.


Install
-------
Install test-kitchen:

```text
$ gem install test-kitchen
```

And then bootstrap the cookbook using the `init` command:

```text
$ kitchen init
```

Alter the stock-generated `.kitchen.yml` file to test the default recipe against the Ubuntu 12.04 platform:

```yaml
driver_plugin: vagrant
driver_config:
  require_chef_omnibus: true

platforms:
  - name: ubuntu-12.04

suites:
  - name: default
    run_list:
      - recipe[tmux::default]
```


Test
----
Since Chef is self-testing, sometimes a successful converge is "enough of a test". Even without any post-convergence tests, Test Kitchen is an excellent way to make sure your cookbooks run.

```text
$ kitchen test
```

Running `kitchen test` will create a new Virtual Machine and converge the default tmux recipe. But sometimes a successful Chef run does not guarantee the state of the system. For example, just because a service is started and running, that does not mean it is accessible by other services on the system. In these instances, you can use a busser to run post-convergence verification tests on the server.

Note: You should avoid re-asserting Chef declarations in your tests. Chef is self-testing, so your post-convergence tests should assert the overall state of the system or universe. In other words, these tests should add business value and should be more like monitors than tests.

Write your first integration test. There are a variety of bussers to choose from, but this guide uses bats because it is the easiest.

```bash
# test/integration/default/bats/verify_installed.bats

@test "tmux is installed and in the path" {
  which tmux
}

@test "tmux configuration exists" {
  cat /etc/tmux.conf | grep "map" # this could be a more complex test
}
```

Run the `kitchen test` command again. This will converge the node and then run the post-convergence verification tests:

```text
$ kitchen test
```

The output should look like this:

```text
$ bundle exec kitchen test
-----> Starting Kitchen (v1.0.0)
-----> Cleaning up any prior instances of <default-ubuntu-1204>
-----> Destroying <default-ubuntu-1204>
       [kitchen::driver::vagrant command] BEGIN (vagrant destroy -f)
       [default] Forcing shutdown of VM...
       [default] Destroying VM and associated drives...
       [kitchen::driver::vagrant command] END (0m3.59s)
       Vagrant instance <default-ubuntu-1204> destroyed.
       Finished destroying <default-ubuntu-1204> (0m3.92s).
-----> Testing <default-ubuntu-1204>
-----> Creating <default-ubuntu-1204>
       [kitchen::driver::vagrant command] BEGIN (vagrant up --no-provision)
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
       [default] Running any VM customizations...
       [default] Booting VM...
       [default] Waiting for VM to boot. This can take a few minutes.
       [default] VM booted and ready for use!
       [default] Setting hostname...
       [default] Configuring and enabling network interfaces...
       [default] Mounting shared folders...
       [default] -- /vagrant
       [kitchen::driver::vagrant command] END (0m33.01s)
       [kitchen::driver::vagrant command] BEGIN (vagrant ssh-config)
       [kitchen::driver::vagrant command] END (0m1.76s)
       Vagrant instance <default-ubuntu-1204> created.
       Finished creating <default-ubuntu-1204> (0m36.85s).
-----> Converging <default-ubuntu-1204>
       Uploaded tmux/metadata.rb (259 bytes)
       Uploaded tmux/README.md (914 bytes)
       Uploaded tmux/recipes/default.rb (680 bytes)
       Uploaded tmux/templates/default/tmux.conf.erb (431 bytes)
Starting Chef Client, version 11.6.0
[2013-05-15T19:07:52+00:00] INFO: *** Chef 11.6.0 ***
[2013-05-15T19:07:52+00:00] INFO: Setting the run_list to ["tmux::default"] from JSON
[2013-05-15T19:07:52+00:00] INFO: Run List is [recipe[tmux::default]]
[2013-05-15T19:07:52+00:00] INFO: Run List expands to [tmux::default]
[2013-05-15T19:07:52+00:00] INFO: Starting Chef Run for default-ubuntu-1204
[2013-05-15T19:07:52+00:00] INFO: Running start handlers
[2013-05-15T19:07:52+00:00] INFO: Start handlers complete.
Compiling Cookbooks...
Converging 2 resources
Recipe: tmux::default
  * package[tmux] action install[2013-05-15T19:07:52+00:00] INFO: Processing package[tmux] action install (tmux::default line 19)

    - install version 1.6-1ubuntu1 of package tmux

  * template[/etc/tmux.conf] action create[2013-05-15T19:07:56+00:00] INFO: Processing template[/etc/tmux.conf] action create (tmux::default line 21)
[2013-05-15T19:07:56+00:00] INFO: template[/etc/tmux.conf] updated content
[2013-05-15T19:07:56+00:00] INFO: template[/etc/tmux.conf] mode changed to 644

    - create template[/etc/tmux.conf]
        --- /tmp/chef-tempfile20130515-1047-1phg51c 2013-05-15 19:07:56.797504430 +0000
        +++ /tmp/chef-rendered-template20130515-1047-1f3d3vd  2013-05-15 19:07:56.797504430 +0000
        @@ -0,0 +1,23 @@
        +# Use a better prefix:
        +set -g prefix C-a
        +unbind C-b
        +

        +# Change the default delay:
        +set -sg escape-time 1
        +
        +# Set the window and panes index
        +set -g base-index 1
        +setw -g pane-base-index 1
        +

        +# Send prefix to ohter apps:
        +bind C-a send-prefix
        +
        +# Split windows with more logical keys

        +bind | split-window -h

        +bind - split-window -v

        +
        +# Remap movement keys
        +bind h select-pane -L
        +bind j select-pane -D

        +bind k select-pane -U
        +bind l select-pane -R

[2013-05-15T19:07:56+00:00] INFO: Chef Run complete in 3.930695673 seconds
[2013-05-15T19:07:56+00:00] INFO: Running report handlers
       [2013-05-15T19:07:56+00:00] INFO: Report handlers complete
       Chef Client finished, 2 resources updated

       Finished converging <default-ubuntu-1204> (0m5.50s).
-----> Setting up <default-ubuntu-1204>
Fetching: thor-0.18.1.gem (100%)
Fetching: busser-0.4.1.gem (100%)
Successfully installed thor-0.18.1
Successfully installed busser-0.4.1
2 gems installed
-----> Setting up Busser
       Creating BUSSER_ROOT in /opt/busser
       Creating busser binstub
       Plugin bats installed (version 0.1.0)
-----> Running postinstall for bats plugin
      create  /tmp/bats20130515-1418-a5fn31/bats
      create  /tmp/bats20130515-1418-a5fn31/bats.tar.gz
Installed Bats to /opt/busser/vendor/bats/bin/bats
      remove  /tmp/bats20130515-1418-a5fn31
       Finished setting up <default-ubuntu-1204> (0m6.55s).
-----> Verifying <default-ubuntu-1204>
       Suite path directory /opt/busser/suites does not exist, skipping.
Uploading /opt/busser/suites/bats/verify_installed.bats (mode=0644)
-----> Running bats test suite
1..2
ok 1 tmux is installed and in the path
ok 2 tmux configuration exists
       Finished verifying <default-ubuntu-1204> (0m1.43s).
-----> Destroying <default-ubuntu-1204>
       [kitchen::driver::vagrant command] BEGIN (vagrant destroy -f)
       [default] Forcing shutdown of VM...
       [default] Destroying VM and associated drives...
       [kitchen::driver::vagrant command] END (0m3.55s)
       Vagrant instance <default-ubuntu-1204> destroyed.
       Finished destroying <default-ubuntu-1204> (0m3.90s).
       Finished testing <default-ubuntu-1204> (0m58.16s).
-----> Kitchen is finished. (0m59.76s)
```

That's all folks! Happy testing!
