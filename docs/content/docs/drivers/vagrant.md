---
title: HashiCorp Vagrant
menu:
  docs:
    parent: drivers
    weight: 15
---

kitchen-vagrant is a Test Kitchen *driver* for HashiCorp Vagrant. A full example reference can be found [here](https://github.com/test-kitchen/kitchen-vagrant/blob/main/example/kitchen.vagrant.yml)

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
