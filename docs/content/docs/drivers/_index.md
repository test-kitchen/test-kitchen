---
title: About Drivers
menu:
  docs:
    parent: drivers
    weight: 10
---

A Test Kitchen *driver* is what supports configuring the compute instance that is used for isolated testing. This is typically a local hypervisor (Hyper-V), hypervisor abstraction layer (Vagrant), or cloud service (AWS EC2).

Driver availability depends on the Ruby environment that runs `kitchen`. A system Ruby install, Cinc Workstation, and Chef Workstation may each provide a different set of installed driver gems. Check the environment you are using before assuming a driver is available:

```bash
gem list kitchen-vagrant
chef gem list kitchen-vagrant
```

Install missing driver gems into that same environment. Common driver plugin projects include:

- [kitchen-azurerm](https://github.com/test-kitchen/kitchen-azurerm)
- [kitchen-cloudstack](https://github.com/test-kitchen/kitchen-cloudstack)
- [kitchen-digitalocean](https://github.com/test-kitchen/kitchen-digitalocean)
- [kitchen-docker](https://github.com/test-kitchen/kitchen-docker)
- [kitchen-dokken](https://github.com/test-kitchen/kitchen-dokken)
- [kitchen-ec2](https://github.com/test-kitchen/kitchen-ec2)
- [kitchen-google](https://github.com/test-kitchen/kitchen-google)
- [kitchen-habitat](https://github.com/test-kitchen/kitchen-habitat)
- [kitchen-hyperv](https://github.com/test-kitchen/kitchen-hyperv)
- [kitchen-opennebula](https://github.com/test-kitchen/kitchen-opennebula)
- [kitchen-openstack](https://github.com/test-kitchen/kitchen-openstack)
- [kitchen-rackspace](https://github.com/test-kitchen/kitchen-rackspace)
- [kitchen-vagrant](https://github.com/test-kitchen/kitchen-vagrant)
- [kitchen-vcair](https://github.com/test-kitchen/kitchen-vcair)
- [kitchen-vcenter](https://github.com/chef/kitchen-vcenter)
- [kitchen-vra](https://github.com/test-kitchen/kitchen-vra)
- [kitchen-vro](https://github.com/test-kitchen/kitchen-vro)

There are other drivers that have existed over the life of Test Kitchen that we do not list here, either because they are un-maintained or have been supplanted by other drivers.
