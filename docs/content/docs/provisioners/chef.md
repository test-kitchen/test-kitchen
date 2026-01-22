---
title: Chef Infra
slug: chef
menu:
  docs:
    parent: provisioners
    weight: 5
---

kitchen-omnibus-chef is a Test Kitchen *provisioner* for chef-client.

## Overview

[kitchen-omnibus-chef](https://github.com/test-kitchen/kitchen-omnibus-chef) plugin includes three provisioners for Chef Infra: `chef_solo`, `chef_infra` and `chef_target`, that support similar options. `chef_zero` was renamed `chef_infra`.

`chef_target` is for using Chef 19 Target Mode without remotely installing any agents and is based on `kitchen-transport-train` and the Train framework, which are not installed from Test Kitchen by default. For links to these two tools, look at the end of this page.

## Configuration Options

### Basic Configuration

```yaml
provisioner:
  name: chef_infra # chef_solo, chef_infra, or chef_target

  # Chef Paths
  data_path: test/data # Path to directory of files to copy to instance
  data_bags_path: test/data_bags # Path to directory containing data_bags
  environments_path: test/envs # Path to directory containing environments
  encrypted_data_bag_secret_key_path: test/secret_key # Path to secret file
  nodes_path: test/nodes # Path to directory containing nodes
  roles_path: test/roles # Path to directory containing roles
  clients_path: test/clients # Path to directory containing clients

  # Chef Execution
  run_list: [] # Chef run list
  attributes: {} # Node attributes
  log_level: auto # debug, info, warn, error, fatal (auto uses info, or debug if --debug flag is set)
  log_file: nil # Path to Chef log file
  profile_ruby: false # Enable Chef Infra's Ruby profiling
  deprecations_as_errors: false # Treat deprecation warnings as errors

  # Chef Configuration
  client_rb: # use solo_rb when chef_solo is used
    environment: kitchen # requires a corresponding file in environments_path
    silence_deprecation_warnings: # true for all or an array of deprecations to silence
      - deploy_resource # deprecation key name
      - chef-23 # deprecation numeric ID
      - recipes/install.rb:22 # specific line in a file
```

### Chef Installation Configuration

```yaml
provisioner:
  # Product Selection
  product_name: chef # chef, chef-workstation, or other Chef products
  product_version: latest # 'latest', partial version (e.g., '18'), or full version (e.g., '18.4.12')
  channel: stable # stable, current, or unstable
  install_strategy: once # once (install only if needed), always (reinstall every run), skip (don't install)

  # License Configuration
  chef_license: accept # Accept Chef license: 'accept', 'accept-no-persist', or 'accept-silent'
  license_key: nil # License key for commercial/trial downloads (RECOMMENDED: use CHEF_LICENSE_KEY env var instead for security)

  # Custom Installation
  download_url: nil # Direct download URL for specific package
  checksum: nil # SHA256 checksum (used with download_url)
  root_path: /tmp/kitchen # Directory to create and execute the Chef installer from

  # Platform Overrides (for cross-platform testing)
  platform: nil # Override detected platform (e.g., 'ubuntu', 'centos')
  platform_version: nil # Override detected platform version (e.g., '22.04', '8')
  architecture: nil # Override detected architecture (e.g., 'x86_64', 'aarch64')
```

### Policyfile and Berkshelf Configuration

```yaml
provisioner:
  # Policyfile Support
  policyfile_path: Policyfile.rb # Path to Policyfile (auto-detected if not set)
  policy_group: nil # Policy group for Policyfile-based workflows

  # Berkshelf Support
  berksfile_path: Berksfile # Path to Berksfile (auto-detected if not set)

  # Cookbook Management
  always_update_cookbooks: true # Update cookbook dependencies on every run
  cookbook_files_glob: README.*,VERSION,metadata.{json,rb}... # Glob pattern for cookbook files to copy
```

### Advanced Testing Options

```yaml
provisioner:
  # Multiple Converge Testing
  multiple_converge: 1 # Run Chef this many times (useful for testing idempotency)
  enforce_idempotency: false # Fail if resources are updated on subsequent runs

  # Retry Handling
  retry_on_exit_code: [35, 213] # Exit codes that trigger retry (35=reboot on Unix, 213=reboot on Windows)
```

### Proxy Configuration

```yaml
provisioner:
  # Proxy Settings (also read from HTTP_PROXY, HTTPS_PROXY environment variables)
  http_proxy: http://proxy.example.com:8080
  https_proxy: https://proxy.example.com:8080
  ftp_proxy: ftp://proxy.example.com:8080
  no_proxy: localhost,127.0.0.1,.example.com
```

## Complete Example

```yaml
provisioner:
  name: chef_infra

  # Basic paths
  data_path: test/data
  data_bags_path: test/data_bags
  environments_path: test/envs
  encrypted_data_bag_secret_key_path: test/secret_key
  nodes_path: test/nodes
  roles_path: test/roles

  # Chef execution
  profile_ruby: false
  deprecations_as_errors: false

  # Chef configuration
  client_rb:
    environment: kitchen
    silence_deprecation_warnings:
      - deploy_resource
      - chef-23

  # Installation
  product_name: chef
  chef_license: accept
  product_version: latest
  channel: stable
  install_strategy: once

  # License key for commercial/trial downloads
  # RECOMMENDED: Set via CHEF_LICENSE_KEY environment variable instead of plain text config
  # license_key: your-license-key-here

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
      - role[role_a]
      - recipe[cookbook_a]
      - recipe[cookbook_b::recipe_c]
```

## Environment Variables

The following environment variables are supported:

- **`CHEF_LICENSE_KEY`**: License key for commercial/trial API downloads. **RECOMMENDED** over setting `license_key` in kitchen.yml to avoid exposing sensitive license keys in plain text configuration files that may be committed to version control.

  ```bash
  export CHEF_LICENSE_KEY=your-license-key-here
  kitchen test
  ```

- **`HTTP_PROXY`**, **`HTTPS_PROXY`**, **`FTP_PROXY`**, **`NO_PROXY`**: Standard proxy environment variables (can also be set in config)

## Path Resolution

## Path Resolution

If not explicitly set, the following keys:

- data_path
- data_bags_path
- encrypted_data_bag_secret_key_path
- environments_path
- nodes_path
- roles_path
- clients_path

Will be set to the first match, in the following order:

1. `test/integration/$SUITE/$KEY`
1. `test/integration/$KEY`
1. `$KEY`

Where `$KEY` corresponds to a folder named `data`, `data_bags`, `environments`, `nodes`, `roles`, or `clients`. The exception is `encrypted_data_bag_secret_key_path` which looks for a file named `encrypted_data_bag_secret_key`.

## Deprecated Configuration Options

The following options are deprecated but still supported for backwards compatibility:

- **`require_chef_omnibus`**: Use `product_name` with `install_strategy` instead
  - `require_chef_omnibus: false` → `product_name: chef` + `install_strategy: skip`
  - `require_chef_omnibus: "18.4.12"` → `product_name: chef` + `product_version: "18.4.12"`
  - `require_chef_omnibus: latest` → `product_name: chef` + `install_strategy: always`

- **`chef_omnibus_url`**: Changing this breaks existing functionality and will be removed

- **`chef_omnibus_install_options`**: Use `product_name` with `channel` instead
  - Example: `-P chef-workstation -c current` → `product_name: chef-workstation` + `channel: current`

- **`policyfile`**: Use `policyfile_path` instead (kept for compatibility with older policyfile_zero provisioner)

## Additional Components for chef_target

To use `chef_target` provisioner, you need:

* Locally installed `chef-client` of version >= 19.0
* [kitchen-transport-train >= 0.2](https://github.com/tecracer-chef/kitchen-transport-train)
* [train >= 3.9](https://github.com/inspec/train)
