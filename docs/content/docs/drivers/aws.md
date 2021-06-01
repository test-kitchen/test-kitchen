---
title: Amazon AWS (EC2)
menu:
  docs:
    parent: drivers
    weight: 15
---

kitchen-ec2 is a Test Kitchen *driver* for EC2 in Amazon AWS.

Example **kitchen.yml**:

```
---
driver:
  name: ec2
  aws_ssh_key_id: id_rsa-aws
  security_group_ids: ["sg-1a2b3c4d"]
  region: us-west-2
  availability_zone: b
  subnet_id: subnet-6e5d4c3b
  iam_profile_name: chef-client
  instance_type: m3.medium
  associate_public_ip: true
  interface: dns

provisioner:
  name: chef_zero

verifier:
  name: inspec

transport:
  ssh_key: /path/to/id_rsa-aws
  connection_timeout: 10
  connection_retries: 5
  username: ubuntu

platforms:
  - name: ubuntu-16.04
  - name: centos-6.9
  - name: centos-7
    driver:
      image_id: ami-c7d092f7
      block_device_mappings:
        - device_name: /dev/sdb
          ebs:
            volume_type: gp2
            virtual_name: test
            volume_size: 8
            delete_on_termination: true
    transport:
      username: centos
  - name: windows-2012r2
  - name: windows-2016

suites:
  - name: default
    run_list:
      - recipe[my_cookbook::default]
    attributes:
```
