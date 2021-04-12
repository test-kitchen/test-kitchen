---
title: DigitalOcean
menu:
  docs:
    parent: drivers
    weight: 15
---

kitchen-digitalocean is a Test Kitchen *driver* for DigitalOcean.

### Example **kitchen.yml**

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

### Driver Configuration Options

The kitchen-digitalocean driver includes many configuration options that can be set globally in the driver section of your kitchen.yml config file or in each platform. Global settings apply to all platforms in the `kitchen.yml`, while platform level driver configuration is applied to only those platforms and override globally set configuration options.

**Example Global Driver Option**

```
driver:
  name: digitaloean
  some_config: true
```

**Example Platform Driver Option**

```
platforms:
  - name: ubuntu-20
    driver:
      some_config: true
```
