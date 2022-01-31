---
title: HashiCorp Vagrant
menu:
  docs:
    parent: drivers
    weight: 15
---

kitchen-vagrant is a Test Kitchen *driver* for HashiCorp Vagrant 1.6 and later.

## Supported Virtualization Hypervisors

| Provider                             | Vagrant Plugin              | Paid Hypervisor
| ---------                            | ---------                   | ---------
| [Oracle VirtualBox][virtualbox_dl]   | built-in                    | N
| [VMware Fusion][fusion_dl]           | vagrant-vmware-desktop      | Y
| [VMware Workstation Pro][ws_dl]      | vagrant-vmware-desktop      | Y
| [Parallels Desktop][parallels_dl]    | vagrant-parallels           | Y
| Microsoft Hyper-V                    | built-in                    | N

### Installing Hypervisor Plugins

VMware and Parallels hypervisors require the installation hypervisor plugins in Vagrant.

For VMware Fusion or Workstation Pro run:

```shell
vagrant plugin install vagrant-vmware-desktop
```

For Parallels Desktop run:

```shell
vagrant plugin install vagrant-parallels
```

To learn more about the installation, upgrade, and usage of these plugins see [Vagrant VMware Desktop Plugin Documentation][vmware_plugin] and [Parallels + Vagrant Documentation][parallels_plugin].

## Example **kitchen.yml**

```yaml
---
driver:
  name: vagrant

provisioner:
  name: chef_infra

verifier:
  name: inspec

platforms:
  - name: ubuntu-20.04
  - name: centos-8
  - name: openbsd-5.6
    driver:
      box: openbsd-5.6
      box_url: http://url.tld/openbsd-5.6.box

suites:
  - name: default
    attributes:
      cookbook:
        attribute: 'value'
    run_list:
      - recipe[cookbook::default]
```

[vagrant_dl]:               https://www.vagrantup.com/downloads
[virtualbox_dl]:            https://www.virtualbox.org/wiki/Downloads
[ws_dl]:                    https://www.vmware.com/products/workstation-pro.html
[fusion_dl]:                https://www.vmware.com/products/fusion.html
[parallels_dl]:             https://www.parallels.com/products/desktop/download/
[vmware_plugin]:            http://www.vagrantup.com/vmware
[parallels_plugin]:         https://parallels.github.io/vagrant-parallels/docs/installation/
