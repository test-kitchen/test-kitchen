---
title: kitchen list
menu:
  docs:
    identifier: cmd-list
    parent: commands
    weight: 45
---

Lists your instances and the last action performed on each one. Running `kitchen list` is usually the fastest way to answer "what do I have, and what state is it in?".

```bash
kitchen list [INSTANCE|REGEXP|all]
```

`kitchen status` is an alias for `kitchen list`.

### Example output

```text
Instance             Driver   Provisioner  Verifier  Transport  Last Action    Last Error
default-ubuntu-2204  Docker   ChefInfra    Inspec    Ssh        Converged      <None>
default-centos-9     Docker   ChefInfra    Inspec    Ssh        <Not Created>  <None>
```

The `Last Action` column reflects what Test Kitchen recorded in its own state files — not what your hypervisor or cloud provider currently has running. See `--live` below for the difference.

### Flags

| Flag | Alias | Description |
| ---- | ---- | ---- |
| `--bare` | `-b` | Print only instance names, one per line. |
| `--json` | `-j` | Print the instance data as JSON. |
| `--live` | | Ask the driver for each instance's real current status. |
| `--probe` | | Additionally test transport connectivity to each instance. |
| `--log-level LEVEL` | `-l` | `debug`, `info`, `warn`, `error`, or `fatal`. |
| `--log-overwrite` | | Set to `false` to keep old log files. |
| `--color` | | Toggle color output. |
| `--debug` | `-d` | Deprecated. Use [`kitchen diagnose`](/docs/commands/diagnose). |

### Scripting with `--bare`

`--bare` prints nothing but names, which makes it easy to drive other commands:

```bash
kitchen list --bare                          # every instance name
kitchen list --bare ubuntu                   # names matching /ubuntu/

# converge instances one at a time, in a loop
for i in $(kitchen list --bare); do
  kitchen converge "$i"
done
```

### Machine-readable output with `--json`

```bash
kitchen list --json | jq -r '.[] | select(.last_action == null) | .instance'
```

`--json` emits the same fields the table shows, which makes it a reliable input for CI scripts that need to decide what to act on.

### Checking what is really running with `--live`

Test Kitchen's state files can drift from reality: an instance may have been terminated in the cloud console, stopped by a provider policy, or destroyed by someone else.

```bash
kitchen list --live
```

`--live` asks the driver for each instance's actual status and adds it to the output. It is slower than a plain `list`, because it makes real API calls, but it is the honest answer.

Add `--probe` to go one step further and actually test whether the transport can connect:

```bash
kitchen list --live --probe
```

This distinguishes "the provider says the instance is running" from "I can actually reach it over SSH" — a useful distinction when an instance is up but its network or SSH daemon is not cooperating. Probe results are colored green when reachable and red when not.

{{% tip %}}
When `kitchen destroy` claims there is nothing to destroy but your bill says otherwise, `kitchen list --live` is the command that tells you the truth.
{{% /tip %}}
