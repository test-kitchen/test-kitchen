---
title: kitchen destroy
menu:
  docs:
    identifier: cmd-destroy
    parent: commands
    weight: 30
---

Deletes one or more instances and removes the state Test Kitchen kept for them.

```bash
kitchen destroy [INSTANCE|REGEXP|all]
```

### Examples

```bash
kitchen destroy                      # every instance
kitchen destroy default-ubuntu-2204  # one instance
kitchen destroy ubuntu               # every instance matching /ubuntu/
kitchen destroy -c                   # all of them, concurrently
```

### Flags

| Flag | Alias | Description |
| ---- | ---- | ---- |
| `--concurrency [N]` | `-c` | Destroy matching instances concurrently. Unlimited when no number is given. |
| `--fail-fast` | `-f` | Stop as soon as one instance fails. |
| `--parallel` | `-p` | Deprecated. Use `--concurrency`. |
| `--test-base-path PATH` | `-t` | Set the base path for tests. |
| `--log-level LEVEL` | `-l` | `debug`, `info`, `warn`, `error`, or `fatal`. |
| `--log-overwrite` | | Set to `false` to keep old log files. |
| `--color` | | Toggle color output. |

Destroy is safe to run against an instance that does not exist. It reports the instance as already destroyed and exits zero, so it is safe to put in a CI cleanup step that always runs.

### Cost control

When you use a cloud driver, every instance left running costs money. Two habits prevent surprise bills:

**Always destroy at the end of a session.**

```bash
kitchen destroy
```

**Make CI clean up even when tests fail.** In GitHub Actions:

```yaml
- name: Test
  run: kitchen test
- name: Clean up
  if: always()
  run: kitchen destroy
```

`kitchen test` already destroys passing instances by default, but a failing run leaves the instance up for debugging. The `if: always()` step catches that case.

{{% warning %}}
`kitchen destroy` can only remove instances it still has state for, in the `.kitchen` directory. If that directory is deleted, or CI discards it between jobs, the instances keep running and Test Kitchen can no longer see them. Check your provider's console periodically, and consider tagging instances so orphans are easy to find.
{{% /warning %}}

Use [`kitchen list`](/docs/commands/list) to see what Test Kitchen currently believes is running, and `kitchen list --live` to ask the driver what is *actually* running.
