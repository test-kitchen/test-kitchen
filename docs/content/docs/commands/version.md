---
title: kitchen version
menu:
  docs:
    identifier: cmd-version
    parent: commands
    weight: 85
---

Prints the version of Test Kitchen that is running.

```bash
kitchen version
```

`-v` and `--version` are aliases:

```bash
kitchen -v
kitchen --version
```

### Example output

```text
Test Kitchen version 4.1.3
```

### Which Test Kitchen is this?

The version reported is whichever `kitchen` is first on your `PATH`, and on a machine with several Ruby environments that is not always the one you meant. Chef Workstation, Cinc Workstation, a system Ruby, and a project Bundler environment can each provide their own.

```bash
which kitchen        # which executable is being used
kitchen version      # what version that executable is
bundle exec kitchen version   # what version the project's Gemfile resolves to
```

If those disagree, the project's `Gemfile.lock` is the authority for work inside that project — prefix commands with `bundle exec`.

To see the versions of the *plugins* rather than Test Kitchen itself, use [`kitchen diagnose`](/docs/commands/diagnose):

```bash
kitchen diagnose --plugins --no-instances
```

That distinction matters when reporting bugs: a driver problem is usually about the driver gem's version, not Test Kitchen's.
