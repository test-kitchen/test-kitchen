---
title: Kitchen Dokken
menu:
  docs:
    parent: drivers
    weight: 15
---

kitchen-dokken is a Test Kitchen driver for that uses specially created Docker containers and a docker container of Chef Infra for rapid testing that can be run on a local workstation or in CI pipelines.

Example **kitchen.yml**:

```
---
driver:
  name: dokken
  privileged: true  # allows systemd services to start

provisioner:
  name: dokken

transport:
  name: dokken

verifier:
  name: inspec

platforms:
  - name: ubuntu-20.04
    driver:
      image: dokken/ubuntu-20.04
      pid_one_command: /bin/systemd
      intermediate_instructions:
        - RUN /usr/bin/apt-get update

  - name: centos-8
    driver:
      image: dokken/centos-8
      pid_one_command: /usr/lib/systemd/systemd

suites:
  - name: default
    run_list:
      - recipe[my_cookbook::default]
    verifier:
      inspec_tests:
        - test/integration/default
    attributes:
```
