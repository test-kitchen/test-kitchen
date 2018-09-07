---
title: "FAQ"
menu:
  docs:
    parent: reference
    weight: 20
---

### FAQ

These are frequently asked questions or tips that don't have a better home just yet.


##### How do I add another driver other than Vagrant?

If you're using ChefDK, check for it`chef gem list | grep $DRIVER` you need to make sure the driver [exists](https://github.com/test-kitchen/test-kitchen/blob/master/ECOSYSTEM.md),
if it does:

~~~
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

Certain drivers, like `kitchen-dokken` [recommend](https://github.com/someara/kitchen-dokken#usage) setting `KITCHEN_LOCAL_YAML` environment variable to ensure these configs are used when there are multiple in a directory.

##### How do I update just test-kitchen if I'm using ChefDK?

Due to the nature of how the ChefDK is built, it is not possible to update a gem that is part of the package. To get the latest versions of component software, builds from the [current](https://downloads.chef.io/chefdk/current) channel can be consumed.

##### How do I change the user to access the instance?

Add/edit the `transport` section in `.kitchen.yml`, for instance:

~~~
transport:
  username: ubuntu
~~~

##### I need to set up a cache or proxy using Vagrant, what are some options for me?

So there are a few things that already exist that sort of cover this in the kitchen world:

- the host ENV vars for proxies are automatically passed to instances
- Example of using [polipo](https://gist.github.com/fnichol/7551540) locally
- [vagrant-cachier](https://github.com/fgrehm/vagrant-cachier)

For the system level proxies and the polipo/squid locally you don't need to do much but you'll still need to edit the conf files for yum/apt as appropriate. If vagrant-cachier it will be used by `kitchen-vagrant` as default. This behaviour is documented [here](https://github.com/test-kitchen/kitchen-vagrant#-cachier).

