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
  downloads: # a Hash of remote => local file mappings to download after converge
  # files are downloaded even when converge fails, so logs can be retrieved
  # a file that cannot be downloaded logs a warning and does not fail the converge
  # if the local value is an existing dir, the file will be copied into it
  # if the local value does not exist, a file with that value as name will be created
    "/tmp/kitchen/client.rb": "./downloads"
    "/tmp/kitchen/validation.pem": "./downloads/validation.pem"
```

### Provisioners documented here

| Provisioner | Configures with |
| ---- | ---- |
| [Chef Infra](/docs/provisioners/chef) | Chef Infra Client, via kitchen-omnibus-chef |
| [Cinc Client](/docs/provisioners/cinc) | Cinc Client, the community distribution of Chef Infra |
| [Habitat](/docs/provisioners/habitat) | Habitat packages and a supervisor |
| [PowerShell DSC](/docs/provisioners/dsc) | PowerShell Desired State Configuration |
| [Shell](/docs/provisioners/shell) | A shell script. Built into the `test-kitchen` gem. |

### Other provisioner plugins

Maintained outside the Test Kitchen organization:

- [kitchen-ansible](https://github.com/neillturner/kitchen-ansible)
- [kitchen-puppet](https://github.com/neillturner/kitchen-puppet)
- [kitchen-salt](https://github.com/saltstack/kitchen-salt)
