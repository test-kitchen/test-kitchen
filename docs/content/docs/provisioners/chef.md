---
title: Chef Infra
slug: chef
menu:
  docs:
    parent: provisioners
    weight: 5
---

Test Kitchen includes three provisioners for Chef Infra, `chef_solo`, `chef_infra` and `chef_target`, that support similar options. `chef_zero` was renamed `chef_infra` in Test Kitchen 3.0.

`chef_target` is for using Chef 19 Target Mode without remotely installing any agents and is based on `kitchen-transport-train` and the Train framework, which are not installed from Test Kitchen by default. For links to these two tools, look at the end of this page.

```ruby
---
provisioner:
  name: chef_infra # chef_solo, chef_infra, or chef_target
  data_path: test/data # Path to directory of files to copy to instance
  data_bags_path: test/data_bags # Path to directory containing data_bags
  environments_path: test/envs # Path to directory containing environments
  encrypted_data_bag_secret_key_path: test/secret_key # Path to secret file
  nodes_path: test/nodes # Path to directory containing nodes
  roles_path: test/roles # Path to directory containing roles
  profile_ruby: false # true enables Chef Infra's Ruby profiling
  deprecations_as_errors: false # true configures Chef Infra to raise exceptions on deprecation warnings
  client_rb: # use solo_rb when chef_solo is used
    environment: kitchen # requires a corresponding file in environments_path
    silence_deprecation_warnings: # true for all or an array of deprecations to silence
    - deploy_resource # deprecation key name
    - chef-23 # deprecation numeric ID
    - recipes/install.rb:22 # specific line in a file
  product_name: chef # which package to install chef || chef-workstation
  chef_license: nil # to accept the Chef Infra license automatically in Test Kitchen. Valid values: `accept`, `accept-no-persist`, or `accept-silent`
  product_version: latest # 'latest', partial, or full version number
  root_path: /tmp # Directory to create and execute the chef installer from
  channel: stable # stable, current or unstable
  install_strategy: once # once (install only if needed), always, skip (don't install)
  download_url: https://url.to/specific-package.ext
  checksum: <SHA256> # used in conjunction with download_url to validate

platforms:
  - name: ubuntu-24.04
    attributes:
      cookbook_a:
        attr_b: "value"

suites:
  - name: default
    attributes:
      cookbook_b:
        attr_c: "value"
    run_list:
      - role[role_a] # requires a corresponding file in roles_path
      - recipe[cookbook_a]
      - recipe[cookbook_b::recipe_c]
```

If not explicitly set, the following keys:

- data_path
- data_bags_path
- encrypted_data_bag_secret_key_path
- environments_path
- nodes_path
- roles_path

Will be set to the first match, in the following order:

1. test/integration/$SUITE/$KEY
2. test/integration/$KEY
3. $KEY

Where `$KEY` corresponds to a folder named `data, data_bags, environments, nodes, roles` - the exception being `encrypted_data_bag_secret_key_path` which looks for a file named `encrypted_data_bag_secret_key`.

Additional Components for `chef_target`:

* locally installed `chef-client` of version >= 19.0
* [kitchen-transport-train >= 0.2](https://github.com/tecracer-chef/kitchen-transport-train)
* [train >= 3.9](https://github.com/inspec/train)
