---
title: Habitat
menu:
  docs:
    identifier: provisioner-habitat
    parent: provisioners
    weight: 5
---

kitchen-habitat is a Test Kitchen *provisioner* for [Habitat](https://habitat.sh).

Test Kitchen builds a throwaway machine, applies your configuration to it, runs your tests, and destroys it. This provisioner makes the "apply your configuration" step install a Habitat supervisor on that machine and load a Habitat service into it — so you can test the package you just built, on a real operating system, before you promote it.

### Requirements

- Ruby 3.1 or newer
- A Test Kitchen [driver](/docs/drivers) to supply the machine — this gem only provisions. [kitchen-vagrant](/docs/drivers/vagrant), [kitchen-dokken](/docs/drivers/dokken), or any cloud driver will do.
- A Habitat package to test: either a package already in [Builder](https://bldr.habitat.sh/), or a local `.hart` artifact you built with `hab studio`.

You do **not** need the `hab` CLI on the instance beforehand. The provisioner installs it, then installs and starts a supervisor, as part of `converge`.

### Installation

This provisioner ships with [Cinc Workstation](https://cinc.sh/start/workstation/) and [Chef Workstation](https://www.chef.io/downloads/tools/workstation).

To install it yourself, add it to your `Gemfile`:

```ruby
gem "kitchen-habitat"
```

Or install the gem directly:

```bash
gem install kitchen-habitat
```

### Quick start

The smallest useful `kitchen.yml` names a driver for the machine, this provisioner, and the package you want to run:

```yaml
---
driver:
  name: vagrant

provisioner:
  name: habitat
  hab_license: accept
  package_origin: core
  package_name: redis

verifier:
  name: inspec

platforms:
  - name: ubuntu-22.04

suites:
  - name: default
```

```bash
kitchen test
```

Or step through it:

```bash
kitchen create    # build the machine
kitchen converge  # install hab, start the supervisor, load the service
kitchen verify    # run your tests
kitchen destroy   # tear the machine down
```

{{% warning %}}
`hab_license: accept` is required for the supervisor to start on Linux. Without it the converge fails with `Habitat license not accepted`. See the [Chef license documentation](https://docs.chef.io/chef_license_accept.html#habitat).
{{% /warning %}}

### How it works

A converge runs four steps in order:

1. **Install the `hab` CLI.** If `hab` is already on the machine, this is skipped. Otherwise the official install script is downloaded and run — `install.sh` on Linux, `install.ps1` on Windows.
2. **Install and start a supervisor.** On Linux a `hab-sup` systemd unit is written and enabled. On Windows the `core/windows-service` package is installed and the Habitat service is started. Supervisor flags come from the `hab_sup_*` and `event_stream_*` options.
3. **Copy your local files into the sandbox.** A `.hart` artifact from your results directory, and a `user.toml` plus any config files from `config_directory`, are staged onto the machine.
4. **Install and load the service.** The package is installed with `hab pkg install`, then loaded with `hab svc load` if it has a `run` hook. The provisioner waits for the service to appear in `hab svc status`, giving up after `service_load_timeout` seconds.

Because step 4 only loads packages that ship a `run` hook, a package that is a library or a build-time dependency converges successfully without a service being started.

### Setting Provisioner Configuration

All options are set under the `provisioner:` key in `kitchen.yml`, and can be overridden per-platform or per-suite.

#### Habitat CLI

| Option | Default | Description |
| ---- | ---- | ---- |
| `hab_license` | `nil` | Set to `accept` to accept the Habitat license. The supervisor will not start on Linux without it. |
| `hab_version` | `latest` | Version of the `hab` CLI to install. On Linux, any value other than `latest` is passed to the install script as `-v <version>`. |
| `hab_channel` | `stable` | Release channel the `hab` CLI is installed from. **Windows only** — the Linux install script does not take a channel. |
| `depot_url` | `nil` | Habitat Builder (depot) URL to install packages from, exported to the supervisor as `HAB_BLDR_URL`. **Linux only.** When unset, the `hab` CLI's own default from `~/.hab/etc/cli.toml` applies. |

#### Supervisor

These map to `hab sup run` flags on the supervisor the provisioner starts.

| Option | Default | Description |
| ---- | ---- | ---- |
| `hab_sup_peer` | `[]` | Supervisors to peer with to join a ring, as `host` or `host:port`. Each becomes a `--peer`. |
| `hab_sup_bind` | `[]` | Service bindings, as `name:service.group`, e.g. `database:postgresql.default`. Each becomes a `--bind`. |
| `hab_sup_group` | `nil` | Service group the supervisor belongs to (`--group`). When unset, Habitat's own default, `default`, applies. |
| `hab_sup_ring` | `nil` | Ring key name (`--ring`). |
| `hab_sup_listen_gossip` | `nil` | Address and port for gossip traffic (`--listen-gossip`), e.g. `0.0.0.0:9638`. |
| `hab_sup_listen_ctl` | `nil` | Address and port for the control gateway (`--listen-ctl`), e.g. `0.0.0.0:9632`. |
| `hab_sup_listen_http` | `nil` | Address and port for the HTTP gateway (`--listen-http`), e.g. `0.0.0.0:9631`. |

#### Service

| Option | Default | Description |
| ---- | ---- | ---- |
| `package_origin` | `core` | Origin of the package to run. Overridden if `artifact_name` or a fully-qualified `package_name` is given. |
| `package_name` | `nil` | Name of the package to run. **Required** unless supplied via `artifact_name` or `install_latest_artifact`. May be a full identifier — `core/redis/4.0.14` is split into origin, name, and version for you. |
| `package_version` | `nil` | Version of the package to run. |
| `package_release` | `nil` | Release of the package to run. |
| `channel` | `stable` | Channel the *package* is installed from and updated against. Distinct from `hab_channel`, which is about the CLI. |
| `service_topology` | `nil` | Service topology (`--topology`): `standalone` or `leader`. Unset means `standalone`. |
| `service_update_strategy` | `nil` | Update strategy (`--strategy`): `at-once` or `rolling`. Unset means updates are not checked for. |
| `service_load_timeout` | `300` | Seconds to wait for the service to show up in `hab svc status` before failing the converge. |

#### Local artifacts and config

| Option | Default | Description |
| ---- | ---- | ---- |
| `artifact_name` | `nil` | Filename of a local `.hart` to upload and run. Origin, name, version, and release are parsed from the filename. The file must be in the results directory. |
| `install_latest_artifact` | `false` | Upload and run the newest `.hart` in the results directory matching `package_origin` and `package_name`. Both must be set. `package_version` and `package_release` are ignored. |
| `results_directory` | *auto-detected* | Directory holding built `.hart` artifacts, relative to `kitchen.yml`. When unset, `results`, `../results`, and `../../results` are tried in that order. |
| `config_directory` | `nil` | Directory holding a `user.toml`, and optionally `default.toml`, hooks, and config files, to ship to the service under test. Relative to `kitchen.yml`. |
| `user_toml_name` | `user.toml` | Name of the file in `config_directory` to install as the service's `user.toml`. Lets one directory hold several, e.g. `user-ha.toml`. |
| `override_package_config` | `false` | Load configuration and hooks from `config_directory` instead of the ones baked into the package, via the supervisor's `--config-from`. |

#### Event stream (Chef Automate)

Reports supervisor and service events to a Chef Automate Application Dashboard.

| Option | Default | Description |
| ---- | ---- | ---- |
| `event_stream_application` | `nil` | Application name to report under. |
| `event_stream_environment` | `nil` | Application environment for this supervisor. |
| `event_stream_site` | `nil` | Where the services are deployed — a datacenter, or a cloud region. |
| `event_stream_url` | `nil` | Chef Automate URL including port 4222, e.g. `automate.example.com:4222`. |
| `event_stream_token` | `nil` | Chef Automate API token. |

{{% warning %}}
All five event stream options must be set for the supervisor to report to Automate. Setting only some of them passes incomplete flags and the supervisor will fail to start.
{{% /warning %}}

#### Choosing the supervisor

By default the stock supervisor that ships with the `hab` CLI is used, and nothing extra is installed. Setting any of these makes the provisioner install the supervisor you asked for before starting it.

| Option | Default | Description |
| ---- | ---- | ---- |
| `hab_sup_origin` | `core` | Origin of the supervisor package. |
| `hab_sup_name` | `hab-sup` | Name of the supervisor package. |
| `hab_sup_version` | `nil` | Version of the supervisor package to pin. |
| `hab_sup_release` | `nil` | Release of the supervisor package to pin. |
| `hab_sup_artifact_name` | `nil` | Filename of a local supervisor `.hart` to upload and run. Must be in the results directory. |

These four identity options combine into a package identifier — `core/hab-sup`, `core/hab-sup/1.6.652`, and so on — installed with `hab pkg install`. When `hab_sup_artifact_name` is given instead, that artifact is uploaded alongside your service artifact and installed from the path it lands at.

Leave all five unset and the converge is unchanged: no supervisor package is installed and the one bundled with the `hab` CLI is used.

### Examples

#### Run a package from Builder

```yaml
---
driver:
  name: vagrant

provisioner:
  name: habitat
  hab_license: accept
  package_origin: core
  package_name: redis

verifier:
  name: inspec

platforms:
  - name: ubuntu-22.04

suites:
  - name: default
```

#### Test the artifact you just built

Assumes you have already run a build in `hab studio`, so a `.hart` is sitting in `results/`.

```yaml
---
driver:
  name: vagrant
  customize:
    memory: 2048

provisioner:
  name: habitat
  hab_license: accept
  package_origin: mycompany
  package_name: wildfly
  results_directory: results
  install_latest_artifact: true

verifier:
  name: inspec

platforms:
  - name: ubuntu-22.04

suites:
  - name: default
    verifier:
      inspec_tests:
        - tests
```

To pin an exact artifact instead of taking the newest, swap `install_latest_artifact` for `artifact_name`:

```yaml
provisioner:
  name: habitat
  hab_license: accept
  results_directory: results
  artifact_name: mycompany-wildfly-26.1.1-20240115194501-x86_64-linux.hart
```

#### Supply a user.toml

Assumes a `configs/user.toml` next to your `kitchen.yml`.

```yaml
provisioner:
  name: habitat
  hab_license: accept
  package_origin: mycompany
  package_name: wildfly
  channel: unstable
  config_directory: configs
```

To have the supervisor use the hooks and config files from that directory rather than the ones inside the package, add `override_package_config: true`.

#### Two services bound together

One suite per service, with the second peering to and binding against the first. This example uses a Docker-based driver so the containers can be linked.

```yaml
---
driver:
  name: docker

provisioner:
  name: habitat
  hab_license: accept

verifier:
  name: inspec

platforms:
  - name: ubuntu-22.04

suites:
  - name: elasticsearch
    provisioner:
      package_origin: core
      package_name: elasticsearch
    driver:
      instance_name: elastic

  - name: kibana
    provisioner:
      package_origin: core
      package_name: kibana
      hab_sup_peer:
        - elastic
      hab_sup_bind:
        - elasticsearch:elasticsearch.default
    driver:
      instance_name: kibana
      links: elastic:elastic
```

#### Report to a Chef Automate dashboard

```yaml
provisioner:
  name: habitat
  hab_license: accept
  hab_version: latest
  event_stream_application: Effortless
  event_stream_environment: stable
  event_stream_site: <%= ENV["region"] %>
  event_stream_url: automate.example.com:4222
  event_stream_token: <%= ENV["automate_token"] %>
```

### Troubleshooting

**The converge hangs, then fails after five minutes.** The service never appeared in `hab svc status`. Usually the package has no `run` hook, or it crashed on startup. Run [`kitchen login`](/docs/commands/login) and check `hab svc status` and `journalctl -u hab-sup` (Linux) or the Habitat service's log (Windows). Raise `service_load_timeout` only if the service is genuinely slow to start.

**`Habitat license not accepted`, and the supervisor never starts.** Set `hab_license: accept` in your provisioner config.

**`You must specify a 'package_origin' and 'package_name' to use the 'install_latest_artifact' option`.** `install_latest_artifact` finds the newest `.hart` by matching `<package_origin>-<package_name>-*.hart`, so it needs both to know what to look for.

**The `.hart` is not found, or the wrong one is uploaded.** Check `results_directory`. Auto-detection only looks in `results`, `../results`, and `../../results` relative to `kitchen.yml`; anywhere else must be set explicitly.

**My custom supervisor is not being used.** Check that `hab_sup_artifact_name` names a file that is actually in the results directory. If you pinned a version or release instead, confirm that identifier exists in the depot; the converge fails at `hab pkg install` when it does not.

**A bind fails with an unsatisfied service group.** `hab_sup_bind` entries are `name:service.group`. The bound service must already be running and reachable — check that `hab_sup_peer` points at it and that the network between the two machines allows the gossip port.
