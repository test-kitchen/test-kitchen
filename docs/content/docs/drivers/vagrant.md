---
title: HashiCorp Vagrant
menu:
  docs:
    parent: drivers
    weight: 15
---

kitchen-vagrant is a Test Kitchen *driver* for HashiCorp Vagrant 1.6 and later.

## Supported Virtualization Hypervisors

| Provider                          | vagrant plugin              | Paid
| ---------                         | ---------                   | ---------
| [VirtualBox][virtualbox_dl]       | built-in                    | N
| [VMware Fusion][fusion_dl]        | vagrant-vmware-fusion       | Y
| [VMware Workstation Pro][ws_dl]   | vagrant-vmware-workstation  | Y
| [Parallels Desktop][parallels_dl] | vagrant-parallels           | Y (plugin free)
| Hyper-V                           | n/a                         | N

If you would like to use VMware Fusion or Workstation you must purchase the software from VMware and also purchase the corresponding [Vagrant VMware Plugin][vmware_plugin].

Example **kitchen.yml**:

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

