---
title: About Commands
menu:
  docs:
    identifier: cmd-index
    parent: commands
    weight: 5
---

Test Kitchen is driven entirely from the `kitchen` command line tool. Every subcommand follows the same shape:

```bash
kitchen SUBCOMMAND [INSTANCE|REGEXP|all] [FLAGS]
```

Run `kitchen help` for the full list, or `kitchen help SUBCOMMAND` for the flags a single subcommand accepts.

### Choosing which instances to act on

An *instance* is one suite paired with one platform. If your `kitchen.yml` defines two suites and three platforms, you have six instances. Every subcommand that operates on instances accepts the same target argument:

| Target | Meaning |
| ---- | ---- |
| *(omitted)* | Every instance. Equivalent to `all` for most subcommands. |
| `all` | Every instance. |
| `default-ubuntu-2204` | One instance, matched by its full name. |
| `default` | A Ruby regular expression. Matches every instance whose name contains `default`. |
| `^default.*2204$` | Anchored regular expression, for when a loose match is too broad. |

The argument is a regular expression, not a glob. `kitchen converge ubuntu` converges every instance with `ubuntu` anywhere in its name, and `kitchen converge '.*'` is the same as `kitchen converge all`.

{{% tip %}}
Quote your regular expressions. Characters like `*`, `?`, and `|` are meaningful to your shell and will be expanded before `kitchen` ever sees them.
{{% /tip %}}

### The instance lifecycle

Instances move through a fixed sequence of states. Each state has a subcommand, and running any subcommand also runs every earlier action the instance has not completed yet.

```text
destroy → create → converge → setup → verify → destroy
```

| State | Subcommand | What happens |
| ---- | ---- | ---- |
| create | [`kitchen create`](/docs/commands/create) | The driver builds the compute instance. |
| converge | [`kitchen converge`](/docs/commands/converge) | The provisioner configures the instance. |
| setup | [`kitchen setup`](/docs/commands/setup) | The verifier installs whatever it needs to run tests. |
| verify | [`kitchen verify`](/docs/commands/verify) | The verifier runs the tests. |
| destroy | [`kitchen destroy`](/docs/commands/destroy) | The driver tears the instance down. |

Because the actions are cumulative, `kitchen verify` on a fresh checkout will create the instance, converge it, and set it up before running a single test. You rarely need to call `create` or `setup` yourself.

[`kitchen test`](/docs/commands/test) runs the whole cycle from a clean slate and is the command you want in CI.

### Flags shared by most subcommands

Every instance-oriented subcommand accepts these logging flags:

| Flag | Alias | Description |
| ---- | ---- | ---- |
| `--log-level LEVEL` | `-l` | Set the log level: `debug`, `info`, `warn`, `error`, or `fatal`. |
| `--log-overwrite` | | Set to `false` to keep previous log files instead of overwriting them on each run. |
| `--color` | | Toggle color output on STDOUT. Defaults to on when STDOUT is a TTY. |
| `--test-base-path PATH` | `-t` | Set the base path Test Kitchen searches for tests. |

The five lifecycle subcommands and `kitchen test` additionally accept:

| Flag | Alias | Description |
| ---- | ---- | ---- |
| `--concurrency [N]` | `-c` | Act on matching instances concurrently. With no number, all matching instances run at once. |
| `--parallel` | `-p` | Deprecated. Use `--concurrency`. |

The five lifecycle subcommands — but not `kitchen test` — also accept `--fail-fast` (`-f`), which stops as soon as any instance fails instead of letting the rest finish. `kitchen converge` and `kitchen verify` accept `--debug` (`-D`) to run the provisioner or verifier in debug mode.

`--concurrency` with no argument means unlimited, which on a large matrix will happily start dozens of cloud instances at once. Pass a number you actually want: `kitchen test -c 4`.

### Command reference

**Lifecycle**

- [`kitchen create`](/docs/commands/create) — start instances
- [`kitchen converge`](/docs/commands/converge) — apply your configuration
- [`kitchen setup`](/docs/commands/setup) — prepare instances for testing
- [`kitchen verify`](/docs/commands/verify) — run tests
- [`kitchen destroy`](/docs/commands/destroy) — tear instances down
- [`kitchen test`](/docs/commands/test) — run the full cycle

**Inspecting and debugging**

- [`kitchen list`](/docs/commands/list) — show instances and their state
- [`kitchen doctor`](/docs/commands/doctor) — check for common problems
- [`kitchen diagnose`](/docs/commands/diagnose) — dump the fully computed configuration
- [`kitchen logs`](/docs/commands/logs) — read structured logs
- [`kitchen login`](/docs/commands/login) — open a shell on an instance
- [`kitchen exec`](/docs/commands/exec) — run one command on instances

**Project and environment**

- [`kitchen init`](/docs/commands/init) — add Test Kitchen to a project
- [`kitchen package`](/docs/commands/package) — turn an instance into an artifact
- [`kitchen console`](/docs/commands/console) — interactive Ruby console
- [`kitchen version`](/docs/commands/version) — print the version

### Configuration file locations

`kitchen` reads up to three YAML files and merges them, in increasing order of precedence:

| File | Environment variable | Purpose |
| ---- | ---- | ---- |
| `~/.kitchen/config.yml` | `KITCHEN_GLOBAL_YAML` | Personal defaults across every project. |
| `kitchen.yml` | `KITCHEN_YAML` | The project's committed configuration. |
| `kitchen.local.yml` | `KITCHEN_LOCAL_YAML` | Uncommitted local overrides. |

Use `KITCHEN_YAML` to keep several configurations side by side:

```bash
KITCHEN_YAML=kitchen.dokken.yml kitchen test
```

{{% info %}}
The older `.kitchen.yml` filename, with a leading dot, still works. `kitchen.yml` is preferred for new projects.
{{% /info %}}
