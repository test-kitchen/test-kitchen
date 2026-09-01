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

Install missing driver gems into that same environment.

### Drivers documented here

| Driver | Target |
| ---- | ---- |
| [Amazon AWS (EC2)](/docs/drivers/aws) | Amazon EC2 |
| [Apache CloudStack](/docs/drivers/cloudstack) | Apache CloudStack, Citrix CloudPlatform |
| [DigitalOcean](/docs/drivers/digitalocean) | DigitalOcean droplets |
| [Dokken (Docker)](/docs/drivers/dokken) | Docker containers, optimized for Chef Infra |
| [Google Cloud Platform](/docs/drivers/google) | Google Compute Engine |
| [Hetzner Cloud](/docs/drivers/hetzner) | Hetzner Cloud servers |
| [HashiCorp Vagrant](/docs/drivers/vagrant) | Local hypervisors via Vagrant |
| [Microsoft Azure](/docs/drivers/azurerm) | Azure Resource Manager |
| [Microsoft Hyper-V](/docs/drivers/hyperv) | Local Hyper-V |
| [OpenStack](/docs/drivers/openstack) | OpenStack, including Rackspace OpenStack Flex |
| [VMware vCenter](/docs/drivers/vcenter) | VMware vCenter |
| [VMware vRealize Automation](/docs/drivers/vra) | vRealize Automation |

### Other driver projects

These drivers exist but are not documented on this site. Check each project for current status before adopting it:

- [kitchen-docker](https://github.com/test-kitchen/kitchen-docker) — Docker containers. Currently without a maintainer and has known issues; use [kitchen-dokken](/docs/drivers/dokken) instead.
- [kitchen-rackspace](https://github.com/test-kitchen/kitchen-rackspace) — Legacy Rackspace Cloud. Unmaintained; current Rackspace Cloud runs OpenStack, so use [kitchen-openstack](/docs/drivers/openstack) instead.
- [kitchen-vro](https://github.com/test-kitchen/kitchen-vro) — VMware vRealize Orchestrator workflows. For VMware, see [kitchen-vcenter](/docs/drivers/vcenter) or [kitchen-vra](/docs/drivers/vra).
- [kitchen-opennebula](https://github.com/test-kitchen/kitchen-opennebula) — OpenNebula
- [kitchen-linode](https://github.com/ssplatt/kitchen-linode) — Linode
- [kitchen-oci](https://github.com/stephenpearson/kitchen-oci) — Oracle Cloud Infrastructure
- [kitchen-qemu](https://github.com/esmil/kitchen-qemu) — QEMU
- [kitchen-lxd](https://github.com/mabegh/kitchen-lxd) — LXD containers

There are other drivers that have existed over the life of Test Kitchen that we do not list here, either because they are unmaintained or have been supplanted by other drivers.
