---
title: kitchen test
menu:
  docs:
    identifier: cmd-test
    parent: commands
    weight: 35
---

Runs the complete lifecycle against one or more instances, starting from a clean slate. This is the command you run in CI and the one that proves your configuration actually works.

```bash
kitchen test [INSTANCE|REGEXP|all]
```

The sequence is:

```text
destroy → create → converge → setup → verify → destroy
```

The leading `destroy` is what makes `test` trustworthy: whatever was left on the instance from earlier runs is thrown away before anything else happens. At the first sign of failure the sequence stops and the instance is left in its last successful state, so you can log in and investigate.

### Examples

```bash
kitchen test                       # every instance
kitchen test default-ubuntu-2204   # one instance
kitchen test ubuntu                # every instance matching /ubuntu/
kitchen test -c 4                  # four at a time
kitchen test -d never              # keep instances afterwards for debugging
```

### Flags

| Flag | Alias | Default | Description |
| ---- | ---- | ---- | ---- |
| `--concurrency [N]` | `-c` | | Test matching instances concurrently. Unlimited when no number is given. |
| `--destroy STRATEGY` | `-d` | `passing` | When to destroy instances afterwards: `passing`, `always`, or `never`. |
| `--auto-init` | | `false` | Run `kitchen init` first if the config file is missing. |
| `--debug` | `-D` | `false` | Run the converge and verify with debugging enabled. |
| `--parallel` | `-p` | | Deprecated. Use `--concurrency`. |
| `--test-base-path PATH` | `-t` | | Set the base path for tests. |
| `--log-level LEVEL` | `-l` | | `debug`, `info`, `warn`, `error`, or `fatal`. |
| `--log-overwrite` | | | Set to `false` to keep old log files. |
| `--color` | | | Toggle color output. |

`kitchen test` does not accept `--fail-fast`.

### Destroy strategies

The `--destroy` flag decides what happens to instances when the run finishes.

| Strategy | Behavior | Use it when |
| ---- | ---- | ---- |
| `passing` *(default)* | Destroy instances that passed; leave failures running. | Everyday use. Failures stay up so you can debug them. |
| `always` | Destroy every instance regardless of outcome. | CI where you never debug on the instance and want no orphans. |
| `never` | Leave every instance running. | Debugging a failure you expect, or reusing an instance afterwards. |

```bash
kitchen test -d always   # nothing survives, even on failure
kitchen test -d never    # everything survives, even on success
```

{{% warning %}}
`-d never` on a cloud driver leaves billable instances running until you `kitchen destroy` them. It is a debugging tool, not a CI setting.
{{% /warning %}}

### Debugging a failure

When `kitchen test` fails, the instance is still running. Investigate it directly:

```bash
kitchen test default-ubuntu-2204   # fails during verify
kitchen login default-ubuntu-2204  # log in and look around
kitchen verify default-ubuntu-2204 # re-run just the tests
```

Because the instance survives, you can iterate with `converge` and `verify` until the problem is fixed, then run the full `kitchen test` again to confirm it works from scratch.

### In continuous integration

```yaml
- name: Test
  run: kitchen test -c 4 -d always
```

`-d always` prevents orphaned cloud instances when a job fails. Add a separate cleanup step for the case where the runner dies mid-run:

```yaml
- name: Clean up
  if: always()
  run: kitchen destroy
```

### Test versus converge and verify

| | `kitchen test` | `kitchen converge` + `kitchen verify` |
| ---- | ---- | ---- |
| Starts from | A destroyed instance | Whatever state the instance is in |
| Speed | Slow — full rebuild | Fast — reuses the instance |
| Proves it works from scratch | Yes | No |
| Good for | CI, final validation | The development loop |

Develop with `converge` and `verify`. Validate with `test`.
