---
title: Cinc Client
menu:
  docs:
    identifier: provisioner-cinc
    parent: provisioners
    weight: 5
---

kitchen-cinc is a Test Kitchen *provisioner* for [Cinc Client](https://cinc.sh/), the community distribution of Chef Infra Client. It downloads and installs omnibus packages via the [Cinc omnitruck API](https://omnitruck.cinc.sh/), so you can test your cookbooks against different Cinc versions without pre-installing anything on your images.

Cinc Client is built from the same upstream source as Chef Infra Client — it is a different build, not different software.

### Installation

This gem ships as part of Cinc Workstation. For standalone installation, add it to your `Gemfile`:

```ruby
gem "kitchen-cinc"
```

Or install it directly:

```bash
gem install kitchen-cinc
```

### The five provisioners

| Name | Description |
| ---- | ---- |
| `cinc_infra` | Modern Cinc Client provisioner using local mode. **Recommended for new projects.** |
| `cinc_zero` | Deprecated alias for `cinc_infra`, kept for backward compatibility. |
| `cinc_solo` | Cinc Solo provisioner. Does not support parallel converge. |
| `cinc_apply` | Runs individual recipes through `cinc-apply`. |
| `cinc_target` | Cinc Target Mode. Requires Cinc Client 19.0.0 or newer and a Train-based transport. |

### Compatibility with chef_* provisioner names

To ease migration from `kitchen-omnibus-chef`, every provisioner is also registered under its `chef_*` name: `chef_infra`, `chef_solo`, `chef_apply`, `chef_target`, and `chef_zero`. An existing `kitchen.yml` using `provisioner: name: chef_infra` works without modification — it transparently runs the Cinc Client equivalent.

The `chef_*` names follow this priority order across gems:

```text
kitchen-chef-enterprise > kitchen-cinc > kitchen-omnibus-chef
```

When a higher-priority gem is installed, kitchen-cinc yields to it. So with `chef_infra` in your `kitchen.yml`:

| Installed gems | What runs |
| ---- | ---- |
| kitchen-cinc only | Cinc Client |
| kitchen-cinc + kitchen-omnibus-chef (>= 1.1.0) | Cinc Client |
| kitchen-cinc + kitchen-chef-enterprise | Chef Enterprise |
| all three | Chef Enterprise |

{{% tip %}}
If you explicitly want the Cinc Client implementation regardless of what else is installed, use the `cinc_*` names in `kitchen.yml`.

The deprecated `chef_*`-prefixed configuration keys (`chef_client_path`, `chef_omnibus_root`, `chef_zero_host`, and so on) are still accepted and forwarded to their `cinc_*` equivalents. Run [`kitchen doctor`](/docs/commands/doctor) to see which deprecated keys your configuration is using.
{{% /tip %}}

### Quick start

```yaml
---
driver:
  name: vagrant

provisioner:
  name: cinc_infra
  product_name: cinc
  install_strategy: always
  channel: stable

platforms:
  - name: ubuntu-24.04
  - name: almalinux-9

suites:
  - name: default
    run_list:
      - recipe[my_cookbook::default]
```

### Setting Provisioner Configuration

#### Installation options

These control how Cinc Client is downloaded and installed on the instance before the converge runs. `product_name` defaults to `cinc`, so installation is active by default — set `install_strategy: skip` to disable it entirely.

| Option | Type | Default | Description |
| ---- | ---- | ---- | ---- |
| `product_name` | String | `cinc` | Product to install: `cinc` for Cinc Client, `cinc-workstation` for Cinc Workstation. |
| `product_version` | String or Symbol | `:latest` | Specific version (e.g. `19.2.12`) or `:latest`. |
| `channel` | Symbol | `:stable` | Release channel: `:stable` or `:current`. |
| `install_strategy` | String | `once` | `once` (install only if absent), `always` (reinstall each converge), or `skip`. |
| `download_url` | String | *(none)* | Direct package URL. Useful for air-gapped environments and internal mirrors. |
| `checksum` | String | *(none)* | SHA256 checksum used to verify the file fetched from `download_url`. |
| `platform`, `platform_version`, `architecture` | String | auto-detected | Override platform detection when the omnitruck installer needs help. |
| `cinc_omnibus_root` | String | set at runtime, e.g. `/opt/cinc` | Root install directory. The defaults for the binary paths derive from this. |

Proxy settings are forwarded to the install script and to Cinc itself:

| Option | Notes |
| ---- | ---- |
| `http_proxy` | Forwarded to omnitruck and Cinc. |
| `https_proxy` | Forwarded to omnitruck and Cinc. |
| `ftp_proxy` | Forwarded to omnitruck. Unix only. |
| `no_proxy` | Forwarded to omnitruck. Unix only. |

Only `http_proxy` is honored by the PowerShell installer. If `chef-config` is available on the workstation, proxy settings from `~/.chef/config.rb` are read at startup and exported automatically.

#### Run list and attributes

| Option | Type | Default | Description |
| ---- | ---- | ---- | ---- |
| `run_list` | Array | `[]` | The Cinc run list. Recipe names (`recipe[my_cookbook::default]`) or role names. |
| `attributes` | Hash | `{}` | Node attributes to set during the converge. |
| `named_run_list` | Hash | `{}` | Selects a named run list defined in a Policyfile. `cinc_infra`, `cinc_zero`, `cinc_target`. |
| `policy_group` | String | *(none)* | Policy group used when resolving a Policyfile. |
| `json_attributes` | Boolean | `true` | Write a `dna.json` to the sandbox and pass `--json-attributes`. |

#### Logging

| Option | Type | Default | Description |
| ---- | ---- | ---- | ---- |
| `log_level` | String | `auto` | Cinc log level: `auto`, `info`, `warn`, `debug`, `trace`. Becomes `debug` when Test Kitchen debug is on. |
| `log_file` | String | *(none)* | Path to write the Cinc log on the instance; passes `--logfile`. |
| `profile_ruby` | Boolean | `false` | Passes `--profile-ruby`. |
| `slow_resource_report` | Boolean or Integer | *(none)* | Passes `--slow-report`, with `N` if an integer is given. |

#### Multiple converges and idempotency

| Option | Type | Default | Description |
| ---- | ---- | ---- | ---- |
| `multiple_converge` | Integer | `1` | Number of times to invoke Cinc per converge. |
| `enforce_idempotency` | Boolean | `false` | The final converge uses an alternate `client.rb` that fails the run if any resource reports `:updated`. |
| `retry_on_exit_code` | Array | `[35, 213]` | Exit codes treated as a retry signal, used by Cinc reboot handling. |
| `deprecations_as_errors` | Boolean | `false` | Sets `treat_deprecation_warnings_as_errors true` so any deprecation warning fails the run. |

Proving idempotency is one of the most valuable things this provisioner can do for you:

```yaml
provisioner:
  name: cinc_infra
  multiple_converge: 2
  enforce_idempotency: true
```

The first converge does the work; the second must change nothing, or the run fails.

#### Custom config injection

| Option | Type | Default | Description |
| ---- | ---- | ---- | ---- |
| `client_rb` | Hash | `{}` | Extra entries merged into the rendered `client.rb`. `cinc_infra`, `cinc_zero`, `cinc_target`. |
| `solo_rb` | Hash | `{}` | Extra entries merged into the rendered `solo.rb`. `cinc_solo` only. |
| `config_path` | String | *(none)* | Path to a `config.rb` loaded by `ChefConfig::WorkstationConfigLoader` at startup. |

```yaml
provisioner:
  name: cinc_infra
  client_rb:
    chef_server_url: https://my-chef-server.example.com/organizations/test
    ssl_verify_mode: :verify_peer
```

Values are formatted with Ruby `inspect` semantics, which is why `:verify_peer` is written as a symbol.

#### Chef Zero networking

| Option | Type | Default | Description |
| ---- | ---- | ---- | ---- |
| `cinc_zero_host` | String | `nil` | Value passed to `--chef-zero-host`. |
| `cinc_zero_port` | Integer | `8889` | Value passed to `--chef-zero-port`. |

### Cookbook resolution

kitchen-cinc resolves cookbook dependencies before staging the sandbox, in this order:

1. **Policyfile** — used automatically when a `Policyfile.rb` is present in `kitchen_root`, or at `policyfile_path`.
2. **Berkshelf** — used when no Policyfile is found and a `Berksfile` is present.
3. **None** — cookbooks are copied from standard layout directories without resolution.

{{% warning %}}
Policyfiles are **not** supported by `cinc_solo`. It falls back to Berkshelf or no resolution.
{{% /warning %}}

| Option | Type | Default | Description |
| ---- | ---- | ---- | ---- |
| `policyfile_path` | String | auto-detected | Path to the `Policyfile.rb`. Relative paths resolve from `kitchen_root`. Raises a `UserError` if set but missing. |
| `policyfile` | String | *(none)* | Legacy alias for `policyfile_path`. |
| `policy_group` | String | *(none)* | Policy group passed to `chef export`. Required if your Policyfile defines multiple groups. |
| `berksfile_path` | String | auto-detected | Path to the `Berksfile`. Raises a `UserError` if set but missing. |
| `berksfile` | String | *(none)* | Alternate spelling. `berksfile_path` wins when both are set. |
| `always_update_cookbooks` | Boolean | `true` | Re-resolve cookbook dependencies on every converge. |
| `cookbook_files_glob` | String | *(see below)* | File patterns staged into the sandbox. Files outside this glob are not transferred. |

The default `cookbook_files_glob` is:

```text
README.*,VERSION,metadata.{json,rb},attributes.rb,recipe.rb,
attributes/**/*,definitions/**/*,files/**/*,libraries/**/*,
providers/**/*,recipes/**/*,resources/**/*,templates/**/*,
ohai/**/*,compliance/**/*
```

If a file your cookbook needs is not reaching the instance, this glob is the first thing to check.

### Paths

Sandbox paths on the workstation auto-resolve to subdirectories under `kitchen_root` when unset:

| Option | Default subpath |
| ---- | ---- |
| `data_path` | `data/` |
| `data_bags_path` | `data_bags/` |
| `environments_path` | `environments/` |
| `nodes_path` | `nodes/` |
| `roles_path` | `roles/` |
| `clients_path` | `clients/` |
| `encrypted_data_bag_secret_key_path` | `encrypted_data_bag_secret_key` |
| `apply_path` (`cinc_apply` only) | `apply/` |

`root_path` is the directory on the instance the sandbox is copied into, and the root every other on-instance path is joined against. It defaults to the driver's sandbox location. Under `cinc_target` it is redirected to the local sandbox path, because the converge runs from the workstation rather than on the instance.

On-instance binary paths — `cinc_client_path`, `cinc_solo_path`, `cinc_apply_path`, and `ruby_bindir` — default to values derived from `cinc_omnibus_root`, with `.bat` extensions on Windows.

### Provisioner-specific notes

#### cinc_solo

Does not run in parallel with other provisioner instances, because Berkshelf is not thread-safe. Adds `legacy_mode` (Boolean, default `false`), which passes `--legacy-mode` to run a true Cinc Solo run rather than the local-mode shim.

#### cinc_apply

Runs each recipe in the suite's `run_list` through `cinc-apply` against files staged under an `apply/` directory in the sandbox.

#### cinc_target

Runs Cinc Client in target mode against a remote node using a Train-based transport. The provisioner runs `cinc-client` **on the workstation**, not on the test instance, so it does not install Cinc on the target. Inherits everything from `cinc_infra`.

### Examples

#### With the Dokken driver

```yaml
---
driver:
  name: dokken
  privileged: true
  chef_image: cincproject/cinc
  chef_version: latest

provisioner:
  name: cinc_infra
  product_name: cinc

transport:
  name: dokken

platforms:
  - name: ubuntu-24.04
    driver:
      image: dokken/ubuntu-24.04
      pid_one_command: /bin/systemd

  - name: almalinux-9
    driver:
      image: dokken/almalinux-9
      pid_one_command: /usr/lib/systemd/systemd
```

#### Air-gapped installation

```yaml
provisioner:
  name: cinc_infra
  download_url: https://mirror.internal.example.com/cinc/cinc_19.2.12-1_amd64.deb
  checksum: 4f53cda18c2baa0c0354bb5f9a3ecbe5ed12ab4d8e11ba873c2f11161202b945
```

#### Pinning a version

```yaml
provisioner:
  name: cinc_infra
  product_version: 19.2.12
  install_strategy: always
```
