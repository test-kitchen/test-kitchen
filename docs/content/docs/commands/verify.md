---
title: kitchen verify
menu:
  docs:
    identifier: cmd-verify
    parent: commands
    weight: 25
---

Runs your tests against one or more instances using the configured [verifier](/docs/verifiers).

```bash
kitchen verify [INSTANCE|REGEXP|all]
```

If the instance does not exist, has not been converged, or has not been set up, `verify` performs those actions first.

### Examples

```bash
kitchen verify                       # every instance
kitchen verify default-ubuntu-2204   # one instance
kitchen verify -c 4                  # four at a time
kitchen verify -D                    # verbose verifier output
```

### Flags

| Flag | Alias | Description |
| ---- | ---- | ---- |
| `--concurrency [N]` | `-c` | Verify matching instances concurrently. Unlimited when no number is given. |
| `--debug` | `-D` | Run the verifier itself with debugging enabled. |
| `--fail-fast` | `-f` | Stop as soon as one instance fails. |
| `--parallel` | `-p` | Deprecated. Use `--concurrency`. |
| `--test-base-path PATH` | `-t` | Set the base path Test Kitchen searches for tests. |
| `--log-level LEVEL` | `-l` | `debug`, `info`, `warn`, `error`, or `fatal`. |
| `--log-overwrite` | | Set to `false` to keep old log files. |
| `--color` | | Toggle color output. |

### Exit codes

`kitchen verify` exits non-zero when any test fails, which is what makes it usable directly in CI. When several instances run concurrently, the command exits non-zero if any one of them failed.

### Where tests are found

The verifier looks for tests under `test/integration/<suite-name>/` by default. For a suite named `default`, InSpec controls live in:

```text
test/integration/default/
```

Override the root with `--test-base-path` on the command line, or `test_base_path` in `kitchen.yml`:

```yaml
verifier:
  name: inspec
suites:
  - name: default
    verifier:
      inspec_tests:
        - test/integration/default
```

### Iterating on tests

Because verify reuses the existing instance, you can edit a test and re-run it without paying for a rebuild:

```bash
kitchen converge default-ubuntu-2204   # once
kitchen verify default-ubuntu-2204     # repeat as you edit tests
```

{{% tip %}}
If `kitchen verify` passes but [`kitchen test`](/docs/commands/test) fails, the difference is almost always leftover state on the instance. Test starts from a destroyed instance; verify does not.
{{% /tip %}}
