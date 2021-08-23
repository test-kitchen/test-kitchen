---
title: Google Cloud Platform
menu:
  docs:
    parent: drivers
    weight: 15
---

kitchen-google is a Test Kitchen *driver* for Google Cloud Platform.

Example **kitchen.yml**:

```yaml
---
driver:
  name: gce
  project: mycompany-test
  zone: us-east1-c
  email: me@mycompany.com
  tags:
    - devteam
    - test-kitchen
  service_account_scopes:
    - devstorage.read_write
    - userinfo.email

provisioner:
  name: chef_zero

verifier:
  name: inspec

transport:
  username: chefuser

platforms:
  - name: centos-7
    driver:
      image_project: centos-cloud
      image_name: centos-7-v20170124
      metadata:
        application: centos
        release: a
        version: 7
  - name: ubuntu-16.04
    driver:
      image_project: ubuntu-os-cloud
      image_family: ubuntu-1604-lts
      metadata:
        application: ubuntu
        release: a
        version: 1604
  - name: windows
    driver:
      image_project: windows-cloud
      image_name: windows-server-2012-r2-dc-v20170117
      disk_size: 50
      metadata:
        application: windows
        release: a
        version: cloud

suites:
  - name: default
    run_list:
      - recipe[my_cookbook::default]
    attributes:
```
