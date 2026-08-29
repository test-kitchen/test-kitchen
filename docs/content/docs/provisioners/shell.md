---
title: Shell
slug: shell
menu:
  docs:
    identifier: provisioner-shell
    parent: provisioners
    weight: 5
---

The Shell provisioner runs a script on the instance instead of using a configuration management tool. It is built into the `test-kitchen` gem, so there is nothing to install.

It is the right choice when you are testing something that is not a cookbook — a package, an installer, a container image — or when you want a small amount of setup without pulling in Chef, Ansible, or Puppet.

### Default usage

```yaml
---
provisioner:
  name: shell
```

With no other configuration, Test Kitchen looks for a script in the root of your project:

| Instance shell | Script it looks for |
| ---- | ---- |
| PowerShell (Windows) | `bootstrap.ps1` |
| Everything else | `bootstrap.sh` |

### Setting Provisioner Configuration

| Option | Default | Description |
| ---- | ---- | ---- |
| `script` | `bootstrap.sh`, or `bootstrap.ps1` on PowerShell instances | Path to the script to upload and run. Relative paths resolve from the project root. |
| `command` | `nil` | Run a single command instead of uploading and running a script. Takes precedence over `script`. |
| `arguments` | `[]` | Extra arguments appended to the script invocation. |
| `data_path` | `data/` if it exists | Local directory uploaded to `<root_path>/data` on the instance before the script runs. |
| `root_path` | driver default, e.g. `/tmp/kitchen` | Directory on the instance the script and data are copied into. |

The Shell provisioner also accepts every [common provisioner option](/docs/provisioners) — `sudo`, `sudo_command`, `command_prefix`, `http_proxy`, `retry_on_exit_code`, `max_retries`, `uploads`, `downloads`, and so on.

```yaml
---
provisioner:
  name: shell
  script:    test/scripts/setup.sh   # default: bootstrap.sh / bootstrap.ps1
  arguments: ['--debug']
  root_path: /home/vagrant
  data_path: test/fixtures
```

### Running a single command

When all you need is one command, skip the script entirely:

```yaml
provisioner:
  name: shell
  command: apt-get update && apt-get install -y nginx
```

{{% info %}}
`command` and `script` are mutually exclusive in practice — when `command` is set, the script is not uploaded or run.
{{% /info %}}

### Shipping files alongside the script

Anything in `data_path` is uploaded to `<root_path>/data` on the instance before the script runs, so your script can rely on it being there:

```yaml
provisioner:
  name: shell
  script: test/scripts/setup.sh
  data_path: test/fixtures
```

```bash
#!/bin/sh
# inside setup.sh
cp /tmp/kitchen/data/nginx.conf /etc/nginx/nginx.conf
```

{{% warning %}}
The `data` directory is **deleted and recreated** on every converge, before the upload. Do not write anything to `<root_path>/data` that you expect to survive between runs.
{{% /warning %}}

### Windows instances

On a PowerShell instance the default script is `bootstrap.ps1`, and arguments are appended directly:

```yaml
provisioner:
  name: shell
  script: test/scripts/setup.ps1
  arguments: ['-Verbose']
```

Because Windows has no executable bit, no `chmod` step is needed. On Unix instances Test Kitchen marks the uploaded script executable for you before running it.

### Exit codes

The converge fails if the script exits non-zero, which is how you signal a failed setup. To retry on specific exit codes — a reboot, say — use the common options:

```yaml
provisioner:
  name: shell
  script: test/scripts/setup.sh
  retry_on_exit_code:
    - 35
  max_retries: 3
  wait_for_retry: 30
```

See [Reboots](/docs/reference/reboots) for handling instances that restart mid-converge.
