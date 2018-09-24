---
title: Vagrant
menu:
  docs:
    parent: drivers
    weight: 15
---

Full example reference can be found [here](https://github.com/test-kitchen/kitchen-vagrant/blob/master/example/kitchen.vagrant.yml)


```
---
driver:
  name: vagrant
  provider: virtualbox

provisioner:
  name: chef_zero

verifier:
  name: inspec  

platforms:
  - name: ubuntu-16.04
  - name: centos-7
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
