---
title: kitchen setup
menu:
  docs:
    identifier: cmd-setup
    parent: commands
    weight: 20
---

Prepares one or more instances for verification by installing whatever the configured [verifier](/docs/verifiers) needs on the instance.

```bash
kitchen setup [INSTANCE|REGEXP|all]
```

If the instance does not exist or has not been converged, `setup` performs those actions first.

### Flags

| Flag | Alias | Description |
| ---- | ---- | ---- |
| `--concurrency [N]` | `-c` | Set up matching instances concurrently. Unlimited when no number is given. |
| `--fail-fast` | `-f` | Stop as soon as one instance fails. |
| `--parallel` | `-p` | Deprecated. Use `--concurrency`. |
| `--test-base-path PATH` | `-t` | Set the base path for tests. |
| `--log-level LEVEL` | `-l` | `debug`, `info`, `warn`, `error`, or `fatal`. |
| `--log-overwrite` | | Set to `false` to keep old log files. |
| `--color` | | Toggle color output. |

### When you need it

Rarely. `kitchen verify` runs setup automatically, and the modern InSpec verifier does most of its work from the workstation rather than by installing software on the instance, so setup is often a no-op.

It remains a distinct lifecycle state because verifiers such as [Busser-based serverspec](/docs/verifiers/serverspec) do need to install a test harness and its dependencies onto the instance. Running `setup` on its own is useful when you want to pay that installation cost once — for example, priming an instance before running `kitchen verify` repeatedly against it.
