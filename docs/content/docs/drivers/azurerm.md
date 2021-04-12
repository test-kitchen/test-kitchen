---
title: Microsoft Azure
menu:
  docs:
    parent: drivers
    weight: 15
---

kitchen-azurerm is a Test Kitchen *driver* for Microsoft Azure. A full example reference can be found [here](https://github.com/test-kitchen/kitchen-azurerm#kitchenyml-example-1---linuxubuntu).

Example **kitchen.yml**:

```yaml
---
driver:
  name: azurerm
  subscription_id: '4801fa9d-YOUR-GUID-HERE-b265ff49ce21'
  location: 'West Europe'
  machine_size: 'Standard_D2_V2'

provisioner:
  name: chef_zero

verifier:
  name: inspec

platforms:
  - name: windows2016
    driver:
      image_urn: MicrosoftWindowsServer:WindowsServer:2016-Datacenter:latest
    transport:
      name: winrm
      elevated: true

suites:
  - name: default
    run_list:
      - recipe[my_cookbook::default]
    attributes:
```
