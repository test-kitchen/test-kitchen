---
title: About Drivers
menu:
  docs:
    parent: drivers
    weight: 10
---

A Test Kitchen *driver* is what supports configuring the compute instance that is used for isolated testing. This is typically a local hypervisor (Hyper-V), hypervisor abstraction layer (Vagrant), or cloud service (EC2).

Chef Workstation includes:

* [kitchen-azurerm](https://github.com/test-kitchen/kitchen-azurerm)
* [kitchen-digitalocean](https://github.com/test-kitchen/kitchen-digitalocean)
* [kitchen-dokken](https://github.com/test-kitchen/kitchen-dokken) (Chef Infra specific Docker driver)
* [kitchen-ec2](https://github.com/test-kitchen/kitchen-ec2)
* [kitchen-google](https://github.com/test-kitchen/kitchen-google)
* [kitchen-hyperv](https://github.com/test-kitchen/kitchen-hyperv)
* [kitchen-openstack](https://github.com/test-kitchen/kitchen-openstack)
* [kitchen-vagrant](https://github.com/test-kitchen/kitchen-vagrant)
* [kitchen-vcenter](https://github.com/chef/kitchen-vcenter)
* [kitchen-vra](https://github.com/chef/kitchen-vra)

Community Drivers:

* [kitchen-docker](https://github.com/test-kitchen/kitchen-docker)
* [kitchen-rackspace](https://github.com/test-kitchen/kitchen-rackspace)
* [kitchen-terraform](https://github.com/newcontext-oss/kitchen-terraform)
* [kitchen-vcair](https://github.com/test-kitchen/kitchen-vcair)
* [kitchen-vro](https://github.com/test-kitchen/kitchen-vro)

There are other drivers that have existed over the life of Test Kitchen that we do not list here, either because they are un-maintained or have been supplanted by other drivers.
