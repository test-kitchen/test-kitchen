---
title: kitchen doctor
menu:
  docs:
    identifier: cmd-doctor
    parent: commands
    weight: 40
---

Checks an instance for common system and configuration problems and reports what it finds. Run it when something is not working and you want to know whether the problem is your environment rather than your code.

```bash
kitchen doctor [INSTANCE|REGEXP|all]
```

### Examples

```bash
kitchen doctor                       # check the first instance
kitchen doctor default-ubuntu-2204   # check a specific instance
kitchen doctor --all                 # check every instance
kitchen doctor -a -l debug           # check everything, verbosely
```

### Flags

| Flag | Alias | Description |
| ---- | ---- | ---- |
| `--all` | `-a` | Check every matching instance instead of only the first. |
| `--log-level LEVEL` | `-l` | `debug`, `info`, `warn`, `error`, or `fatal`. |
| `--log-overwrite` | | Set to `false` to keep old log files. |
| `--color` | | Toggle color output. |

{{% info %}}
By default `kitchen doctor` checks **only the first matching instance**, to avoid flooding your terminal with near-identical output. Pass `--all` when you want every instance checked.
{{% /info %}}

### What it checks

`kitchen doctor` asks each of the four plugins configured for the instance to inspect itself:

| Plugin | Typical checks |
| ---- | ---- |
| [Driver](/docs/drivers) | Is the hypervisor or daemon reachable? Are credentials present and valid? |
| [Provisioner](/docs/provisioners) | Is the required tooling installed and a supported version? |
| [Transport](/docs/transports) | Can the instance be reached over SSH or WinRM? |
| [Verifier](/docs/verifiers) | Is the test framework available? |

Each plugin decides what is worth checking, so the depth of the report depends on which plugins you use. [kitchen-hetzner](/docs/drivers/hetzner), for example, reports cloud servers it created that no local state file knows about — orphans that would otherwise keep costing money unnoticed. A container driver will typically check that the daemon is running and reachable at the configured socket, one of the most common reasons a converge fails with an error that mentions nothing about the daemon.

Plugins that do not implement a doctor check simply report nothing. A quiet run means no configured plugin found a problem it knows how to detect; it is not a guarantee that everything is correct.

### Exit codes

`kitchen doctor` exits non-zero if any plugin reports a problem, so it can be used as a preflight gate:

```bash
kitchen doctor --all && kitchen test
```

### When to reach for it

- A converge fails immediately with a connection or authentication error
- You have just set up a new workstation and want to confirm your driver works
- A driver worked yesterday and does not today, and you want to rule out the environment
- You are about to file a bug and want to include environment diagnostics

If `kitchen doctor` reports nothing useful, [`kitchen diagnose`](/docs/commands/diagnose) is the next step — it shows the fully merged configuration Test Kitchen is actually operating on.
