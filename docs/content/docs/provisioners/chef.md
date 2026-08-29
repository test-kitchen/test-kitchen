---
title: Chef Infra
slug: chef
menu:
  docs:
    parent: provisioners
    weight: 5
---

kitchen-omnibus-chef is a Test Kitchen *provisioner* for chef-client.

{{% warning %}}
**Omnitruck downloads are being shut down** for specific Chef Infra Client versions and will stop working entirely in the future. This gem is also **not compatible with Chef Infra Client 19+**, which uses a new Habitat-based installation method.

Recommended migration paths:

- **Chef customers** — switch to [kitchen-chef-enterprise](https://github.com/chef/kitchen-chef-enterprise), bundled in Chef Workstation 26.x and newer, for licensed download support.
- **Community users** — switch to [kitchen-cinc](/docs/provisioners/cinc) and use the Cinc provisioners such as `cinc_infra`.

See the [Chef blog](https://www.chef.io/blog/decoding-the-change-progress-chef-is-moving-to-licensed-downloads) for the schedule of affected versions.
{{% /warning %}}

## Overview

The [kitchen-omnibus-chef](https://github.com/test-kitchen/kitchen-omnibus-chef) plugin downloads and installs omnibus packages of Chef Infra Client on your test instances, so you can test cookbooks against different Chef versions without pre-installing Chef on your images.

It provides five provisioners, all sharing a common option set:

| Name | Description |
| ---- | ---- |
| `chef_infra` | Modern Chef Infra Client provisioner. **Recommended.** |
| `chef_zero` | Deprecated alias for `chef_infra`, kept for backward compatibility. |
| `chef_solo` | Chef Solo provisioner. Does not support parallel converge. |
| `chef_apply` | Runs individual recipes through `chef-apply`. |
| `chef_target` | Chef Target Mode. Requires Chef Infra Client 19.0.0+ and a Train-based transport. |

This plugin is not bundled by the `test-kitchen` gem itself; use the version provided by your Workstation package or install it into the Ruby environment that runs `kitchen`.

`chef_target` runs Chef 19 Target Mode without remotely installing any agents, and is based on `kitchen-transport-train` and the Train framework, which are not installed by Test Kitchen by default. See [Additional Components for chef_target](#additional-components-for-chef_target).

### Which gem provides chef_* names?

Several gems register the same `chef_*` provisioner names. They resolve in this priority order:

```text
kitchen-chef-enterprise > kitchen-cinc > kitchen-omnibus-chef
```

When a higher-priority gem is installed, kitchen-omnibus-chef yields to it. If you have kitchen-cinc installed alongside this gem, `chef_infra` in your `kitchen.yml` will run Cinc Client. Use [`kitchen diagnose --plugins`](/docs/commands/diagnose) to see which implementation actually loaded.

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
  chef_license_key: nil # License key for commercial/trial downloads (RECOMMENDED: use CHEF_LICENSE_KEY env var instead for security)

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

### Converge Behavior

```yaml
provisioner:
  # Run list and attributes
  run_list: []           # Run list applied to the instance, usually set per suite
  attributes: {}         # Node attributes merged into the run
  json_attributes: true  # Write attributes to a JSON file and pass it to the client
  named_run_list: nil    # Named run list to use from a Policyfile

  # Chef Zero networking (chef_infra / chef_zero / chef_target)
  chef_zero_host: nil    # Host the in-memory Chef Zero server binds to
  chef_zero_port: 8889   # Port the in-memory Chef Zero server binds to

  # Execution
  sudo: true             # Run the client under sudo
  slow_resource_report: nil  # Emit the slow resource report at the end of the run
  legacy_mode: false     # Pass --legacy-mode to chef-solo (chef_solo only)
  config_path: nil       # Use an existing config file instead of a generated one
```

### On-instance Binary Paths

These default to values derived from `chef_omnibus_root` and rarely need setting.

| Option | Applies to |
| ---- | ---- |
| `chef_client_path` | `chef_infra`, `chef_zero`, `chef_target` |
| `chef_solo_path` | `chef_solo` |
| `chef_apply_path` | `chef_apply` |
| `apply_path` | `chef_apply` — the recipe that gets applied |
| `ruby_bindir` | all |

### Target Mode File Transfer

`chef_target` runs the converge from your workstation, so it can move files around the run.

| Option | Default | Description |
| ---- | ---- | ---- |
| `uploads` | `{}` | Files copied to the instance before the converge. Keys are local paths, values remote destinations. |
| `downloads` | `{}` | Files copied back after the converge. Keys are remote paths, values local destinations. |

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

  # Chef license key for commercial/trial downloads
  # RECOMMENDED: Set via CHEF_LICENSE_KEY environment variable instead of plain text config
  # chef_license_key: your-license-key-here

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

- **`CHEF_LICENSE_KEY`**: License key for commercial/trial API downloads. **RECOMMENDED** over setting `chef_license_key` in kitchen.yml to avoid exposing sensitive license keys in plain text configuration files that may be committed to version control.

  ```bash
  export CHEF_LICENSE_KEY=your-license-key-here
  kitchen test
  ```

- **`HTTP_PROXY`**, **`HTTPS_PROXY`**, **`FTP_PROXY`**, **`NO_PROXY`**: Standard proxy environment variables (can also be set in config)

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
