---
title: "FAQ"
menu:
  docs:
    parent: reference
    weight: 15
---

### FAQ

These are frequently asked questions or tips that don't have a better home just yet.

#### How do I add another driver other than Vagrant?

First check whether the driver is installed in the Ruby environment that runs `kitchen`. With system Ruby, use `gem list`. With Chef Workstation, use `chef gem list`. If your selected Workstation package does not bundle the plugin, install it into that same environment.

```bash
~$ gem list kitchen-openstack
~$ chef gem list kitchen-openstack
~$ gem install kitchen-openstack # or chef gem install kitchen-openstack
~$ vi cookbooks/demo/kitchen.yml # wherever your kitchen.yml is for your cookbook
```

Examples:

- [kitchen-openstack](https://github.com/test-kitchen/kitchen-openstack#minimum-configuration)
- [kitchen-digitalocean](https://github.com/test-kitchen/kitchen-digitalocean#installation-and-setup)

Edit the `kitchen.yml` as appropriate and run `kitchen list` to verify that everything
is working as expected. There is a strong chance that the flavors, or
image names are different per driver, so when migrating between drivers be prepared
to change these at the very least.

Certain drivers, like `kitchen-dokken` [recommend](https://github.com/test-kitchen/kitchen-dokken#usage) setting `KITCHEN_LOCAL_YAML` environment variable to ensure these configs are used when there are multiple in a directory.

##### How do I update just Test Kitchen if I'm using Chef Workstation?

Due to the nature of how Workstation packages are built, it is not possible to update a gem that is part of the package in place. To get newer component versions, install a newer Workstation build or run Test Kitchen from a separate Ruby environment where you control the gem versions.

##### How do I change the user to access the instance?

Add/edit the `transport` section in `kitchen.yml`, for instance:

```yaml
transport:
  username: ubuntu
```

##### I need to set up a cache or proxy using Vagrant, what are some options for me?

So there are a few things that already exist that sort of cover this in the Test Kitchen world:

- the host ENV vars for proxies are automatically passed to instances
- Example of using [polipo](https://gist.github.com/fnichol/7551540) locally
- [vagrant-cachier](https://github.com/fgrehm/vagrant-cachier)

For system-level proxies and local polipo/squid setups, minimal configuration is needed, but you should still update the yum/apt configuration files as necessary. If you use vagrant-cachier, it will be utilized by `kitchen-vagrant` by default. This behavior is explained in the [kitchen-vagrant cachier documentation](https://github.com/test-kitchen/kitchen-vagrant#-cachier).
