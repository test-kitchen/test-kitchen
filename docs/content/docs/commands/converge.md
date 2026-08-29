---
title: kitchen converge
menu:
  docs:
    identifier: cmd-converge
    parent: commands
    weight: 15
---

Applies your configuration to one or more instances using the configured [provisioner](/docs/provisioners). This is the command you run most often while developing.

```bash
kitchen converge [INSTANCE|REGEXP|all]
```

If an instance does not exist yet, `converge` creates it first.

### Examples

```bash
kitchen converge                      # every instance
kitchen converge default-ubuntu-2204  # one instance
kitchen converge default              # every instance matching /default/
kitchen converge -c 4                 # four at a time
kitchen converge -l debug             # verbose Test Kitchen logging
kitchen converge -D                   # verbose provisioner logging
```

### Flags

| Flag | Alias | Description |
| ---- | ---- | ---- |
| `--concurrency [N]` | `-c` | Converge matching instances concurrently. Unlimited when no number is given. |
| `--debug` | `-D` | Run the provisioner itself with debugging enabled. |
| `--fail-fast` | `-f` | Stop as soon as one instance fails. |
| `--parallel` | `-p` | Deprecated. Use `--concurrency`. |
| `--test-base-path PATH` | `-t` | Set the base path for tests. |
| `--log-level LEVEL` | `-l` | `debug`, `info`, `warn`, `error`, or `fatal`. |
| `--log-overwrite` | | Set to `false` to keep old log files. |
| `--color` | | Toggle color output. |

{{% tip %}}
`-l debug` and `-D` do different things. `-l debug` makes *Test Kitchen* verbose — how it resolved config, what it uploaded, which commands it ran. `-D` makes the *provisioner* verbose, so for the Chef provisioner it is the difference between seeing Test Kitchen's plumbing and seeing Chef's own debug output. When you are stuck, use both.
{{% /tip %}}

### Converging repeatedly

Converge is designed to be run over and over. A typical development loop is:

```bash
kitchen converge default-ubuntu-2204   # apply changes
# edit your cookbook or configuration
kitchen converge default-ubuntu-2204   # apply again, same instance
```

The instance is not rebuilt between runs, so this is much faster than `kitchen test`. It also means state left behind by an earlier converge is still present — which is exactly what you want while iterating, and exactly what you do not want when validating. Before you trust a result, run [`kitchen test`](/docs/commands/test) to prove the configuration works from a clean machine.

{{% warning %}}
A converge that passes on a dirty instance can still fail on a fresh one. Repeated converges do not prove your code is idempotent or that it works from scratch.
{{% /warning %}}
