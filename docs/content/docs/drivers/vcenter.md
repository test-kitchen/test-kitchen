---
title: VMware vCenter
menu:
  docs:
    parent: drivers
    weight: 15
---

kitchen-vcenter is a Test Kitchen *driver* for VMware vCenter.

Example **kitchen.yml**:

```yaml
---
driver:
  name: vcenter
  vcenter_username: 'administrator@vsphere.local'
  vcenter_password: <%= ENV['VCENTER_PASSWORD'] %>
  vcenter_host:  <%= ENV['VCENTER_HOST'] %>
  vcenter_disable_ssl_verify: true
  customize:
    annotation: "Kitchen VM by <%= ENV['USER'] %> on <%= Time.now.to_s %>"

provisioner:
  name: chef_zero

verifier:
  name: inspec

platforms:
  - name: ubuntu-1604
    driver:
      targethost: 10.0.0.42
      template: ubuntu16-template
      interface: "VM Network"
      datacenter: "Datacenter"
    transport:
      username: "admini"
      password: admini

  - name: centos-7
    driver:
      targethost: 10.0.0.42
      template: centos7-template
      datacenter: "Datacenter"
    transport:
      username: "root"
      password: admini

  - name: windows2012R2
    driver:
      targethost: 10.0.0.42
      network_name: "Internal"
      template: folder/windows2012R2-template
      datacenter: "Datacenter"
      customize:
        numCPUs: 4
        memoryMB: 1024
        add_disks:
         - type: "thin"
           size_mb: 10240
    transport:
      username: "Administrator"
      password: "p@ssW0rd!"

suites:
  - name: default
    run_list:
      - recipe[my_cookbook::default]
```
