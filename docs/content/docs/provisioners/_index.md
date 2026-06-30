---
title: About Provisioners
menu:
  docs:
    parent: provisioners
    weight: 1
---

A Test Kitchen *provisioner* takes care of configuring the compute instance provided by the *driver*. The `test-kitchen` gem includes the `shell` provisioner, which is the default provisioner, and a `dummy` provisioner for tests. Chef, Cinc, and other configuration management provisioners are supplied by plugin gems installed in the Ruby environment that runs `kitchen`.

There are common settings that all provisioners inherit and can override. These are typically set in the context of a specific provisioner but are provided here for reference.

```ruby
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
  uploads: # a Hash of local => remote file mappings to upload at the start of invocation
    "contrib/some_file.cfg": "/etc"
  downloads: # a Hash of remote => local file mappings to download after converge (downloaded even when converge fails, so logs can be retrieved)
  # if the local value is an existing dir, the file will be copied into it
  # if the local value does not exist, a file with that value as name will be created
    "/tmp/kitchen/client.rb": "./downloads"
    "/tmp/kitchen/validation.pem": "./downloads/validation.pem"
```

Common provisioner plugins:

* [kitchen-omnibus-chef](https://github.com/test-kitchen/kitchen-omnibus-chef)
* [kitchen-cinc](https://github.com/test-kitchen/kitchen-cinc)
* [kitchen-ansible](https://github.com/neillturner/kitchen-ansible)
* [kitchen-dsc](https://github.com/test-kitchen/kitchen-dsc)
* [kitchen-puppet](https://github.com/neillturner/kitchen-puppet)
* [kitchen-salt](https://github.com/saltstack/kitchen-salt)
