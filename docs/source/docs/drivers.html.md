---
title: "Drivers"
---

Kitchen supports a driver plugin architecture which allows a user to run code
on a variety of public cloud providers and local virtualization technologies.

Some of these are included in `chef-dk` and some are not.

There are drivers not included in this list, and it is not intended to be
exhaustive. However, as a sample of some of the supported platforms:

- [kitchen-vagrant](https://github.com/test-kitchen/kitchen-vagrant): Vagrant driver for Kitchen
- [kitchen-google](https://github.com/test-kitchen/kitchen-google): Google Compute Engine driver for Test-Kitchen.
- [kitchen-hyperv](https://github.com/test-kitchen/kitchen-hyperv): Hyper-V Driver for Test-Kitchen
- [kitchen-docker](https://github.com/test-kitchen/kitchen-docker): A Test Kitchen Driver for Docker
- [kitchen-digitalocean](https://github.com/test-kitchen/kitchen-digitalocean): A Test Kitchen driver for DigitalOcean
- [kitchen-ec2](https://github.com/test-kitchen/kitchen-ec2): A Test Kitchen Driver for Amazon EC2
- [kitchen-azurerm](https://github.com/test-kitchen/kitchen-azurerm): A driver for Test Kitchen that works with Azure Resource Manager
- [kitchen-rackspace](https://github.com/test-kitchen/kitchen-rackspace): A Rackspace Cloud driver for Test Kitchen

Some notes about specific drivers below.


##### Vagrant

Vagrant is often considered the "minimum-viable" driver. Many projects include
a `.kitchen.yml` which can run under Vagrant, in addition to any specific
drivers which they may use internally or on continuous integration servers.

Vagrant runs using Virtualbox VMs, so it requires a platform which supports
virtualization. For example, it cannot run on top of Xen HVM.

Vagrant is supported via the
[kitchen-vagrant](https://rubygems.org/gems/kitchen-vagrant) gem, included by
default in `chef-dk`.
([Source](https://github.com/test-kitchen/kitchen-vagrant))

`kitchen-vagrant` requires that you additionally have Vagrant installed.


##### Amazon EC2

Amazon Web Services' EC2 service can be used to spin up new EC2 instances for
testing.

It is supported via the [kitchen-ec2](https://rubygems.org/gems/kitchen-ec2)
gem.
([Source](https://github.com/test-kitchen/kitchen-ec2))

`kitchen-ec2` does not have any external requirements on your system, but you
need to configure AWS credentials which are used to manage the EC2 instances.
This is a common property of many of the cloud-based drivers: rather than
locally installed software, they require credentials into the service which
they use to launch and destroy VMs.

##### Docker

Using Docker containers for testing often offers faster runtimes than its
alternatives. Because containers are lighter weight than full virtualization,
the numerous creation and deletion operations performed by Kitchen over a large
test matrix can make this an attractive option.

It is supported via the
[kitchen-docker](https://rubygems.org/gems/kitchen-docker)
gem.
([Source](https://github.com/test-kitchen/kitchen-docker))

`kitchen-docker` requires that you have Docker installed locally. Additionally,
it is useful to configure your user to have sudo-less access to Docker.

###### kitchen-dokken

A popular alternative to `kitchen-docker`, `kitchen-dokken` is a driver which
only works with the Chef provisioner.

It is supported via the
[kitchen-dokken](https://rubygems.org/gems/kitchen-dokken) gem.
([Source](https://github.com/someara/kitchen-dokken))

`kitchen-dokken` differs significantly from `kitchen-docker` by using bind
mounts to share data without the need to copy it into the container.
This can result in significant speed improvements with no additional
configuration burden.
