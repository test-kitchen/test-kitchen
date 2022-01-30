---
title: Microsoft Hyper-V
menu:
  docs:
    parent: drivers
    weight: 15
---

kitchen-hyperv is a Test Kitchen *driver* for Microsoft Hyper-V.

Example **kitchen.yml**:

```yaml
---
driver:
  name: hyperv
  parent_vhd_folder: C:\HyperV\WindowsServer
  parent_vhd_name: Server2016.vhdx
  vm_switch: ExternalSwitch
  memory_startup_bytes: 4GB
​
provisioner:
  name: chef_infra
​
transport:
  password: password123
  elevated: true
  name: winrm
​
verifier:
  name: inspec
​
platforms:
  - name: windows-kitchen
​
suites:
  - name: default
    run_list:
      - recipe[learn_chef_iis::default]
    verifier:
      inspec_tests:
        - test/smoke/default

suites:
  - name: default
    run_list:
      - recipe[my_cookbook::default]
    attributes:
```
