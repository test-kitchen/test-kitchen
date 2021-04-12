---
title: OpenStack
menu:
  docs:
    parent: drivers
    weight: 15
---

kitchen-openstack is a Test Kitchen *driver* for OpenStack.

Example **kitchen.yml**:

```
---
driver:
  name: openstack
  openstack_username: [YOUR OPENSTACK USERNAME]
  openstack_api_key: [YOUR OPENSTACK API KEY] # AKA your OPENSTACK PASSWORD
  openstack_auth_url: [YOUR OPENSTACK AUTH URL]
  openstack_domain_id: [default is 'default'; otherwise YOUR OPENSTACK DOMAIN ID]
  require_chef_omnibus: [e.g. 'true' or a version number if you need Chef]
  image_ref: [SERVER IMAGE ID]
  flavor_ref: [SERVER FLAVOR ID]
  key_name: [KEY NAME]
  read_timeout: 180
  write_timeout: 180
  connect_timeout: 180

transport:
  ssh_key: /path/to/id_rsa #Path to private key that matches the above openstack key_name
  connection_timeout: 10
  connection_retries: 5
  username: ubuntu
  password: mysecreatpassword

platforms:
  - name: ubuntu-14.04
  - name: ubuntu-15.04
  - name: centos-7
    transport:
      username: centos
  - name: windows-2012r2
    transport:
      password: myadministratorpassword

suites:
  - name: default
    run_list:
      - recipe[my_cookbook::default]
    attributes:
```
