---
title: Provisioners
menu:
  docs:
    parent: provisioners
    weight: 1
---

A Test-Kitchen *provisioner* takes care of configuring the compute instance provided by the *driver*. This is most commonly a configuration management framework like Chef or the Shell provisioner, both of which are included in test-kitchen by default.

There are common settings that all provisioners inherit and can override. These are typically set in the context of a specific provisioner but are provided here for reference.

```
provisioner:
  root_path: '/tmp/kitchen' # when platform is Windows '$env:TEMP\\kitchen'
  sudo: true # when platform is Windows, nil
  sudo_command: 'sudo -E' # when platform is Windows, nil
  command_prefix: nil # prefix the provisioner exec with a command
  http_proxy: nil
  https_proxy: nil
  ftp_proxy: nil
  retry_on_exit_code: []
  max_retries: 1
  wait_for_retry: 30
  downloads: # a Hash of remote => local file mappings to download post-converge
  # if the local value is an existing dir, the file will be copied into it
  # if the local value does not exist, a file with that value as name will be created
    "/tmp/kitchen/client.rb": "./downloads"
    "/tmp/kitchen/validation.pem": "./downloads/validation.pem"
```

Community provisioners:

* [kitchen-ansible](https://github.com/neillturner/kitchen-ansible)
* [kitchen-puppet](https://github.com/neillturner/kitchen-puppet)
* [kitchen-dsc](https://github.com/test-kitchen/kitchen-dsc)
