---
title: Drivers
menu:
  docs:
    parent: drivers
    weight: 15
---

A Test-Kitchen *driver*  is what supports configuring the compute instance that is used for isolated testing. This is typically a local hypervisor, hypervisor abstraction layer (Vagrant), or cloud service (EC2). While there are many drivers out there, below is a collection of ones which the core team is aware of and which ones we support.

ChefDK / Chef Workstation include:
- kitchen-vagrant
- kitchen-ec2
- kitchen-digitalocean
- kitchen-dokken
- kitchen-ec2
- kitchen-google
- kitchen-hyperv  

Other Drivers
kitchen-docker	A driver for Docker.
kitchen-hyperv	A driver for Hyper-V Server.
kitchen-openstack	A driver for OpenStack.
kitchen-terraform	A driver for Terraform.
kitchen-vagrant	A driver for Vagrant. The default driver packaged with the Chef development kit.

There are other drivers that have existed over the life of test-kitchen that we do not list here, either because they are un-maintained or have been supplanted by other drivers.
