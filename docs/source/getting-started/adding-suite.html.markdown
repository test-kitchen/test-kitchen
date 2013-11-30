---
title: Adding a Suite
---

We're going to call our new Test Kitchen Suite `"server"` by opening `.kitchen.yml` in your editor of choice so that it looks similar to:

```yaml
---
driver_plugin: vagrant
driver_config:
  require_chef_omnibus: true

platforms:
- name: ubuntu-12.04
- name: ubuntu-10.04
- name: centos-6.4

suites:
- name: default
  run_list:
  - recipe[git]
  attributes: {}
- name: server
  run_list:
  - recipe[git::server]
  attributes: {}
```

Now run `kitchen list` to see our new suite in action:

```
$ kitchen list
Instance             Driver   Provisioner  Last Action
default-ubuntu-1204  Vagrant  Chef Solo    <Not Created>
default-ubuntu-1004  Vagrant  Chef Solo    <Not Created>
default-centos-64    Vagrant  Chef Solo    <Not Created>
server-ubuntu-1204   Vagrant  Chef Solo    <Not Created>
server-ubuntu-1004   Vagrant  Chef Solo    <Not Created>
server-centos-64     Vagrant  Chef Solo    <Not Created>
```

Woah, we've doubled our number of instances! Yes, that is going to happen. This explosion of test cases is just one reason why testing is hard.
