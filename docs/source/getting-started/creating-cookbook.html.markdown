---
title: "Creating a Cookbook"
next:
  text: "Writing a Recipe"
  url: "writing-recipe"
---

In order to keep our worked example as simple as possible let's create a Chef cookbook to automate the installation and management of the [Git](http://git-scm.com/) distributed version control tool. It's true that there is already a very capable [Git cookbook](http://community.opscode.com/cookbooks/git) availble on the [Opscode Community Site](http://community.opscode.com/cookbooks) (not to mention we just installed Git by hand in the **Installing** section) but this lets us focus on Test Kitchen usage and workflow rather than [building more awesome](http://www.youtube.com/watch?v=OU8ihx3nT6I).

In the "real world" most Chef cookbook authors are likely to use a cookbook project generator but we're going to skip that step in the interests of transparency. A simple Chef cookbook has very few moving parts so let's start from there.

First of all, let's create an empty Git repository and enter into that directory:

```
$ git init git-cookbook
Initialized empty Git repository in /tmpt-cookbook/git-cookbook/.git/
$ cd git-cookbook
```

Next we need a [metadata.rb](http://docs.opscode.com/config_rb_metadata.html) file so that various Chef-aware tooling can understand our cookbook. Test Kitchen is no different and there are minimally only 2 things that Test Kitchen cares about: cookbook **name** and cookbook **version** attributes. Use your favorite text editor and create a file called `metadata.rb` with the following:


```ruby
name "git"
version "0.1.0"
```

Now let's setup the default recipe in this cookbook. It doesn't have to do anything for the moment but if we add it, Test Kitchen can wire this up for us without any further work.

```
$ mkdir recipes
$ touch recipes/default.rb
```

> **Congratulations. You've authored a Chef cookbook.**

Okay, it's a little light on implementation but let's commit it anyway:

```
$ git add metadata.rb recipes/default.rb
$ git commit -m "Git Chef cookbook - the lean version"
[master (root-commit) 087db85] Git Chef cookbook - the lean version
 1 file changed, 2 insertions(+)
 create mode 100644 metadata.rb
 create mode 100644 recipes/default.rb
```

Now we'll add Test Kitchen to our project by using the **init** subcommand:

```
$ kitchen init --driver=kitchen-vagrant
      create  .kitchen.yml
      create  test/integration/default
      create  .gitignore
      append  .gitignore
      append  .gitignore
         run  gem install kitchen-vagrant from "."
Successfully installed kitchen-vagrant-0.11.1
1 gem installed
```

What's going on here? The `kitchen init` subcommand will create an initial configuration file for Test Kitchen called `.kitchen.yml`. We'll look at that in a moment.

A few directories were created but these are only a convenience--you don't strictly need `test/integration/default` in your project.

You can see that you have a `.gitignore` file in your project's root which will tell Git to never commit a directory called `.kitchen` and something called `.kitchen.local.yml`. Don't worry about these for now, just some housekeeping details.

Finally, a gem call `kitchen-vagrant` was installed. By itself Test Kitchen can't do very much. It needs one or more **Drivers** which are responsible for managing the virtual machines we need for testing. At present there are many different Test Kitchen Drivers but we're going to stick with the [Kitchen Vagrant Driver](https://github.com/opscode/kitchen-vagrant) for now.

<div class="well">
  <h4><span class="glyphicon glyphicon-pushpin"></span> Pro-Tip</h4>
  <p>The Kitchen Vagrant Driver is the default driver chosen when you omit <code>--driver-kitchen-vagrant</code> from the command. After a few projects, feel free to simply <code>kitchen init</code>.</p>
</div>

Let's turn our attention to the `.kitchen.yml` file for a minute. While Test Kitchen may have created the initial file automatically, it's expected that you read and edit this file. After all, you know what you want to test... right? Opening this file in your editor of choice we see something like the following:

```yaml
---
driver_plugin: vagrant
driver_config:
  require_chef_omnibus: true

platforms:
- name: ubuntu-12.04
- name: ubuntu-10.04
- name: centos-6.4
- name: centos-5.9

suites:
- name: default
  run_list: ["recipe[git]"]
  attributes: {}
```

Very briefly we can cover the 4 main sections you're likely to find in a `.kitchen.yml` file:

* `driver_plugin`: This tells Test Kitchen that we want to use the `kitchen-vagrant` driver by default.
* `driver_config`: This is the default configuration passed to each Driver instance. The `require_chef_omnibus: true` tells the Driver that the latest version of the Chef omnibus package needs to be installed
* `platforms`: This is a list of operation systems on which we want to run our code. Note that the operation system's version, architecture, cloud environment, etc. might be relavent to what Test Kitchen considers a **Platform**.
* `suites`: This is a list of Chef run-list and node attribute setups that we want run on each **Platform** above. For example, we might want to test the MySQL client cookbook code seperately from the server cookbook code for maximum isolation.

Let's say for argument's sake that we only care about running our Chef cookbook on Ubuntu 12.04 distributions. In that case, edit the `.kitchen.yml` file so that the list of `platforms` has only one entry like so:

```yaml
---
driver_plugin: vagrant
driver_config:
  require_chef_omnibus: true

platforms:
- name: ubuntu-12.04

suites:
- name: default
  run_list: ["recipe[git]"]
  attributes: {}
```

To see the results of our work, let's run the `kitchen list` subcommand:

```
$ kitchen list
Instance             Driver   Provisioner  Last Action
default-ubuntu-1204  Vagrant  Chef Solo    <Not Created>
```

So what's this `default-ubuntu-1204` thing and what's an "Instance"? A Test Kitchen **Instance** is a pairwise combination of a **Suite** and a **Platform** as laid out in your `.kitchen.yml` file. Test Kitchen has auto-named your only instance by combining the **Suite** name (`"default"`) and the **Platform** name (`"ubuntu-12.04"`) into a form that is safe for DNS and hostname records, namely `"default-ubuntu-1204"`.

Okay, let's spin this **Instance** up to see what happens. Test Kitchen calls this the **Create Action**. We're going to be painfully explicit and ask Test Kitchen to only create the `default-ubuntu-1204` instance:

```
$ kitchen create default-ubuntu-1204
-----> Starting Kitchen (v1.0.0.beta.3)
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
       [default] Running 'pre-boot' VM customizations...
       [default] Booting VM...
       [default] Waiting for machine to boot. This may take a few minutes...
       [default] Machine booted and ready!
       [default] Setting hostname...
       [default] Mounting shared folders...
       [kitchen::driver::vagrant command] END (0m29.18s)
       [kitchen::driver::vagrant command] BEGIN (vagrant ssh-config)
       [kitchen::driver::vagrant command] END (0m0.84s)
       Vagrant instance <default-ubuntu-1204> created.
       Finished creating <default-ubuntu-1204> (0m33.02s).
-----> Kitchen is finished. (0m33.31s)
```

If you are a Vagrant user then the line containing `vagrant up --no-provision` will look familiar. Let's check the status of our instance now:

```
$ kitchen list
Instance             Driver   Provisioner  Last Action
default-ubuntu-1204  Vagrant  Chef Solo    Created
```

Let's commit our glorious work:

```
$ git add .gitignore .kitchen.yml
$ git commit -m "Add Test Kitchen to the project."
[master d119471] Add Test Kitchen to the project.
 2 files changed, 14 insertions(+)
 create mode 100644 .gitignore
 create mode 100644 .kitchen.yml
```

Ok, we have a instance created and ready for some Chef code. Onward!
