---
title: kitchen create
menu:
  docs:
    identifier: cmd-create
    parent: commands
    weight: 10
---

Starts one or more instances. The driver builds the compute resource — a virtual machine, container, or cloud server — but nothing is configured on it yet.

```bash
kitchen create [INSTANCE|REGEXP|all]
```

### Examples

```bash
kitchen create                       # every instance
kitchen create default-ubuntu-2204   # one instance
kitchen create ubuntu                # every instance matching /ubuntu/
kitchen create all -c 4              # every instance, four at a time
```

### Flags

| Flag | Alias | Description |
| ---- | ---- | ---- |
| `--concurrency [N]` | `-c` | Create matching instances concurrently. Unlimited when no number is given. |
| `--fail-fast` | `-f` | Stop as soon as one instance fails. |
| `--parallel` | `-p` | Deprecated. Use `--concurrency`. |
| `--test-base-path PATH` | `-t` | Set the base path for tests. |
| `--log-level LEVEL` | `-l` | `debug`, `info`, `warn`, `error`, or `fatal`. |
| `--log-overwrite` | | Set to `false` to keep old log files. |
| `--color` | | Toggle color output. |

### When you need it

Most of the time you do not. `kitchen converge` creates the instance first if it does not exist, so running `create` by hand is only useful when you want to:

- confirm your driver credentials and networking work before spending time on a converge
- create an instance and then log into it with [`kitchen login`](/docs/commands/login) to poke at a clean machine
- warm a set of instances in CI before a fan-out of converges

### What gets written

After a successful create, Test Kitchen records the instance's state — its hostname, port, and username — in `.kitchen/<instance-name>.yml`. That file is how later commands know how to reach the machine. Deleting it will orphan the running instance: Test Kitchen will no longer know the instance exists, but your cloud provider will keep billing for it.

{{% warning %}}
If you delete the `.kitchen` directory while instances are running, use your provider's console to find and remove them. `kitchen destroy` can only clean up instances it still has state for.
{{% /warning %}}
