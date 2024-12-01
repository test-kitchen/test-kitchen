---
title: About Drivers
menu:
  docs:
    parent: drivers
    weight: 10
---

A Test Kitchen *driver* is what supports configuring the compute instance that is used for isolated testing. This is typically a local hypervisor (Hyper-V), hypervisor abstraction layer (Vagrant), or cloud service (AWS EC2).

[Chef Workstation](https://community.chef.io/tools/chef-workstation) includes Test Kitchen along with the following drivers:

- Amazon EC2 (AWS) via the [kitchen-ec2](https://github.com/test-kitchen/kitchen-ec2) project
- DigitalOcean via the [kitchen-digitalocean](https://github.com/test-kitchen/kitchen-digitalocean) project
- Dokken (Chef Infra specific Docker driver) via the [kitchen-dokken](https://github.com/test-kitchen/kitchen-dokken) project
- Google Cloud Platform via the [kitchen-google](https://github.com/test-kitchen/kitchen-google) project
- HashiCorp Vagrant via the [kitchen-vagrant](https://github.com/test-kitchen/kitchen-vagrant) project
- Microsoft Azure via the [kitchen-azurerm](https://github.com/test-kitchen/kitchen-azurerm) project
- Microsoft Hyper-V via the [kitchen-hyperv](https://github.com/test-kitchen/kitchen-hyperv) project
- Openstack via the [kitchen-openstack](https://github.com/test-kitchen/kitchen-openstack) project
- VMware vCenter via the [kitchen-vcenter](https://github.com/chef/kitchen-vcenter) project
- VMware vRealize Automation via the [kitchen-vra](https://github.com/test-kitchen/kitchen-vra) project

The Test Kitchen community also maintains several additional plugins not bundled directly in Chef Workstation:

- [kitchen-docker](https://github.com/test-kitchen/kitchen-docker)
- [kitchen-rackspace](https://github.com/test-kitchen/kitchen-rackspace)
- [kitchen-vcair](https://github.com/test-kitchen/kitchen-vcair)
- [kitchen-vro](https://github.com/test-kitchen/kitchen-vro)

There are other drivers that have existed over the life of Test Kitchen that we do not list here, either because they are un-maintained or have been supplanted by other drivers.
