---
title: Drivers
menu:
  docs:
    parent: drivers
    weight: 10
---

A Test-Kitchen *driver*  is what supports configuring the compute instance that is used for isolated testing. This is typically a local hypervisor, hypervisor abstraction layer (Vagrant), or cloud service (EC2).

ChefDK / Chef Workstation include:

* [kitchen-vagrant](https://github.com/test-kitchen/kitchen-vagrant)
* [kitchen-ec2](https://github.com/test-kitchen/kitchen-ec2)
* [kitchen-digitalocean](https://github.com/test-kitchen/kitchen-digitalocean)
* [kitchen-dokken](https://github.com/someara/kitchen-dokken)
* [kitchen-google](https://github.com/test-kitchen/kitchen-google)
* [kitchen-hyperv](https://github.com/test-kitchen/kitchen-hyperv)
* [kitchen-azurerm](https://github.com/test-kitchen/kitchen-azurerm)

Community Drivers:

* [kitchen-docker](https://github.com/test-kitchen/kitchen-docker)
* [kitchen-openstack](https://github.com/test-kitchen/kitchen-openstack)
* [kitchen-terraform](https://github.com/newcontext-oss/kitchen-terraform)

There are other drivers that have existed over the life of test-kitchen that we do not list here, either because they are un-maintained or have been supplanted by other drivers.
