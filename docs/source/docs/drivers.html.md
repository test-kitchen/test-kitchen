---
title: "Drivers"
---

### Drivers

Kitchen supports a driver plugin architecture which allows a user to run code
on a variety of cloud providers and virtualization technologies.

#### Vagrant

[kitchen-vagrant](https://github.com/test-kitchen/kitchen-vagrant) is the de facto driver as it is free and keeps everything on a the local machine.
Vagrant itself abstracts other hypervisors, using Virtualbox by default which requires a platform which supports virtualization. For example, most hypervisors cannot run nested under other hypervisors or cloud VMs unless they explicitly support Nested Virtualization.
The side effect is that it is often difficult to implement in CI given most CI as a Service presents VMs or Containers

`kitchen-vagrant` requires that you have [Vagrant](https://www.vagrantup.com/downloads.html) and at least one hypervisor, such as VirtualBox installed.

#### Amazon EC2

Amazon Web Services' EC2 service can be used to spin up new EC2 instances for
testing.

It is supported via the [kitchen-ec2](https://rubygems.org/gems/kitchen-ec2)
gem.
([Source](https://github.com/test-kitchen/kitchen-ec2))

[kitchen-ec2](https://github.com/test-kitchen/kitchen-ec2) does not have any external requirements on your system, but you
need to configure AWS credentials which are used to manage the EC2 instances.
This is a common property of many of the cloud-based drivers: rather than
locally installed software, they require credentials into the service which
they use to launch and destroy VMs.

#### Docker

Using Docker containers for testing often offers faster runtimes than its
alternatives. Because containers are lighter weight than full virtualization,
the numerous creation and deletion operations performed by Kitchen over a large
test matrix can make this an attractive option.

We have two drivers in the ecosystem for Docker and a [post](https://blog.chef.io/2018/03/06/kitchen-docker-or-kitchen-dokken-using-test-kitchen-and-docker-for-fast-cookbook-testing/) to help you choose the best for your needs.

##### kitchen-dokken

[kitchen-dokken](https://github.com/test-kitchen/kitchen-dokken) differs significantly from `kitchen-docker` by using bind
mounts to share data without the need to copy it into the container.
This can result in significant speed improvements with no additional
configuration burden. `kitchen-dokken` only works with the Chef provisioner and is part of the ChefDK.
It utlizes the `docker-api` gem for communicating with Docker.

##### kitchen-docker

[kitchen-docker](https://github.com/test-kitchen/kitchen-docker) requires that you have Docker installed locally. Additionally,
it is useful to configure your user to have sudo-less access to Docker. This driver
operates more "traditionally" like the other drivers and supports other provisioners besides Chef.
It's useful for more complex scenarios and as it utilizes the `docker` binary directly, supports most
things Docker does.

We've covered the three most popular hypervisor options and their drivers but there are many other drivers out there. Below is a non-exhaustive list of some additional ones:

- [kitchen-google](https://github.com/test-kitchen/kitchen-google)
- [kitchen-hyperv](https://github.com/test-kitchen/kitchen-hyperv)
- [kitchen-azurerm](https://github.com/test-kitchen/kitchen-azurerm)
