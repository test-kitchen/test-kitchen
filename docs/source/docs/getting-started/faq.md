---
title: "Frequently Asked Questions"
prev:
  text: "Next Steps"
  url: "next-steps"
---

### The defaults are way too small or missing something, how do I change the default Vagrant machine?

Sometimes you'd like to add another NIC to your vm, or bump up the memory. You might have a `forwarded_port` you'd like
to add also. The following snippet is a couple suggestions how. You can even turn on the `auto_correct` if you think
you'll need it.

~~~yaml
  name: vagrant
  network:
    - ["forwarded_port", {guest: 80, host: 8080, auto_correct: true}]
    - ["forwarded_port", {guest: 443, host: 8443}]
    - ["private_network", {ip: "10.0.0.1"}]
  customize:
    cpus: 2
    memory: 4096
~~~

As you can see this very close to the [Vagrantfile forwarded_port](https://docs.vagrantup.com/v2/networking/forwarded_ports.html)
and works exactly like how you'd expect it to.

Doubly, as you can see the [Vagrantfile private_network](https://docs.vagrantup.com/v2/networking/private_network.html)
looks just like you'd expect it to.

If you would like more information the [kitchen-vagrant](https://github.com/test-kitchen/kitchen-vagrant) github page has more.

### How do I add another driver other than Vagrant?

First, you need to make sure that the driver might already [exist](https://github.com/test-kitchen/test-kitchen/blob/master/ECOSYSTEM.md),
if it does:

~~~bash
~$ gem install kitchen-openstack # for instance
~$ vi cookbooks/demo/.kitchen.yml # wherever your .kitchen.yml is for your cookbook
~~~

Read the examples in, for instance, [kitchen-openstack](https://github.com/test-kitchen/kitchen-openstack#minimum-configuration)
or [kitchen-digitalocean](https://github.com/test-kitchen/kitchen-digitalocean#installation-and-setup)
and edit your `.kitchen.yml`.

It's suggested after doing this, to run `kitchen list` to verify that everything
is setup and working as suspected. There is a strong chance that the flavors, or
image names are different per driver, so you'll need to do the legwork to confirm.

### When would I want to use .kitchen.local.yml or .kitchen.cloud.yml?

A `.kitchen.local.yml` or `.kitchen.cloud.yml` is an override for the `.kitchen.yml`
in the directory already.

`.kitchen.local.yml`s are useful for instances where you want to have a "standard"
override on your laptop to talk to your cloud/system of choice.

`.kitchen.cloud.yml`s are useful for a shared cloud based `.kitchen.yml` for
everyone, for instance the [rabbitmq](https://github.com/jjasghar/rabbitmq/blob/master/.kitchen.cloud.yml)
has one for verifying on Digital Ocean. With a simple bash alias, you can change
and verify that it works as expected:

```bash
~$ alias cloud_testing='export KITCHEN_YAML=.kitchen.cloud.yml && chef exec kitchen list'
```

This is per setup of course, but you should get the point here.

### How do I update just test-kitchen if I'm using Chef-DK?

To take from [discourse.chef.io](https://discourse.chef.io/t/updating-to-test-kitchen-1-6-0-in-a-chefdk-0-11-2-or-lesser/7899), you can

```bash
chef gem install appbundle-updater
appbundle-updater chefdk test-kitchen v1.6.0 # or whatever version you want update to
```

The appbundle-updater gem can update a "appbundled" gem in a chef or chefdk omnibus install and reference a specific git branch, tag or sha. The above uses it to pull down the v1.6.0 tag of the test-kitchen repo and then propperly pins that inside an existing chefdk installation.

### How do I change the user to access the instance?

You can edit the `.kitchen.yml` with a `transport` option, for instance:

```yaml
transport:
  username: ubuntu
```
