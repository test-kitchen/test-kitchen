---
title: "Frequently Asked Questions"
---

### FAQ

These are frequently asked questions or tips that don't have a better home just yet.


##### How do I add another driver other than Vagrant?

First, you need to make sure the driver [exists](https://github.com/test-kitchen/test-kitchen/blob/master/ECOSYSTEM.md),
if it does:

~~~bash
~$ gem install kitchen-openstack # for instance
~$ vi cookbooks/demo/.kitchen.yml # wherever your .kitchen.yml is for your cookbook
~~~

Examples:

- [kitchen-openstack](https://github.com/test-kitchen/kitchen-openstack#minimum-configuration)
- [kitchen-digitalocean](https://github.com/test-kitchen/kitchen-digitalocean#installation-and-setup)

Edit the `.kitchen.yml` as appropriate and run `kitchen list` to verify that everything
is working as expected. There is a strong chance that the flavors, or
image names are different per driver, so when migrating between drivers be prepared
to change these at the very least.

##### What is the deal with `.kitchen.BLAH.yml`?

Although there is no strict configuration supporting this, a convention has emerged among the
community that for public cookbooks the default `.kitchen.yml` remains vagrant and any additional drivers get their own configuration file in the form of `.kitchen.DRIVER.yml`

- .kitchen.ec2.yml
- .kitchen.dokken.yml

These are meant to be used in place `.kitchen.yml` via the environment variable `KITCHEN_YAML`
Note that it is `YAML` not `YML`.

~~~bash
$ KITCHEN_YAML=.kitchen.ec2.yml kitchen list

OR

$ export KITCHEN_YAML=.kitchen.ec2.yml
$ kitchen list
~~~

Certain drivers, like `kitchen-dokken` [recommend](https://github.com/someara/kitchen-dokken#usage) setting `KITCHEN_LOCAL_YAML` environment variable to ensure these configs are used when there are multiple in a directory.

##### How do I update just test-kitchen if I'm using ChefDK?

To borrow from this [discourse post](https://discourse.chef.io/t/updating-to-test-kitchen-1-6-0-in-a-chefdk-0-11-2-or-lesser/7899), one can:

~~~bash
chef gem install appbundle-updater
appbundle-updater chefdk test-kitchen v1.6.0 # or whatever version you want update to
~~~

The appbundle-updater gem can update an "appbundled" gem in a chef or chefdk omnibus install and reference a specific git branch, tag or sha. The above uses it to pull down the v1.6.0 tag of the test-kitchen repo and then properly pins that inside an existing ChefDK installation.

##### How do I change the user to access the instance?

Add/edit the `transport` section in `.kitchen.yml`, for instance:

~~~yaml
transport:
  username: ubuntu
~~~

##### I need to set up a cache or proxy using Vagrant, what are some options for me?

So there are a few things that already exist that sort of cover this in the kitchen world:

- the host ENV vars for proxies are automatically passed to instances
- Example of using [polipo](https://gist.github.com/fnichol/7551540) locally
- [vagrant-cachier](https://github.com/fgrehm/vagrant-cachier)

For the system level proxies and the polipo/squid locally you don't need to do much but you'll still need to edit the conf files for yum/apt as appropriate. If vagrant-cachier it will be used by `kitchen-vagrant` as default. This behaviour is documented [here](https://github.com/test-kitchen/kitchen-vagrant#-cachier).
