---
title: DigitalOcean
menu:
  docs:
    parent: drivers
    weight: 15
---

kitchen-digitalocean is a Test Kitchen *driver* for DigitalOcean.

Example **kitchen.yml**:

```
---
driver:
  name: digitaloean

provisioner:
  name: chef_zero

verifier:
  name: inspec

platforms:
  - name: ubuntu-20
  - name: ubuntu-18
    region: sfo1
    driver:
      tags:
        - test-kitchen-instance
      monitoring: true # disabled by default
      vpcs:
        - 3a92ae2d-f1b7-4589-81b8-8ef144374453
      ipv6: true # disabled by default
      private_networking: false # enabled by default

suites:
  - name: default
    run_list:
      - recipe[my_cookbook::default]
    attributes:
```
