---
title: kitchen init
menu:
  docs:
    identifier: cmd-init
    parent: commands
    weight: 75
---

Adds Test Kitchen support to an existing project. It writes a starter `kitchen.yml` in the project root and, optionally, adds the driver gems to a `Gemfile`.

```bash
kitchen init [FLAGS]
```

### Examples

```bash
kitchen init                                    # defaults: kitchen-vagrant, shell provisioner
kitchen init -D kitchen-dokken                  # use the Dokken driver instead
kitchen init -D kitchen-dokken -P chef_infra    # Dokken driver, Chef Infra provisioner
kitchen init -D kitchen-ec2 kitchen-vagrant     # add more than one driver gem
kitchen init --create-gemfile                   # create a Gemfile if none exists
```

### Flags

| Flag | Alias | Default | Description |
| ---- | ---- | ---- | ---- |
| `--driver GEM [GEM...]` | `-D` | `kitchen-vagrant` | One or more driver gems to install or add to the Gemfile. |
| `--provisioner NAME` | `-P` | `shell` | The default provisioner to write into `kitchen.yml`. |
| `--create-gemfile` | | `false` | Create a `Gemfile` if the project does not have one. |

`--driver` takes a list, so several drivers can be added at once. `--provisioner` takes a single name.

### What it creates

`kitchen init` writes a `kitchen.yml` in the project root, intended as a starting point rather than a finished configuration:

```yaml
---
driver:
  name: vagrant

provisioner:
  name: shell

platforms:
  - name: ubuntu-24.04
  - name: almalinux-10

suites:
  - name: default
    run_list:
    attributes:
```

The driver name is derived from the gem name with the `kitchen-` prefix removed, so `-D kitchen-dokken` produces `name: dokken`.

If the project has a `metadata.rb`, the cookbook name is read from it and the default suite's run list is pre-populated with `recipe[<cookbook>::default]`.

Alongside `kitchen.yml`, init also:

| Action | Condition |
| ---- | ---- |
| Creates `test/integration/default/` | No test directory exists yet. |
| Creates `chefignore` | Always. |
| Adds driver gems to `Gemfile` | A `Gemfile` exists, or `--create-gemfile` was passed. |
| Appends `.kitchen/` entries to `.gitignore` | The project is a git repository. |
| Adds Kitchen Rake tasks to `Rakefile` | A `Rakefile` exists and does not already have them. |
| Adds Kitchen Thor tasks to `Thorfile` | A `Thorfile` exists and does not already have them. |

{{% info %}}
`--create-gemfile` defaults to `false`, so `kitchen init` will not create a `Gemfile` in a project that does not already have one. Pass the flag if you want dependency management via Bundler.
{{% /info %}}

### Automatic initialization

[`kitchen test`](/docs/commands/test) accepts `--auto-init`, which runs `kitchen init` when no configuration file is found:

```bash
kitchen test --auto-init
```

This is convenient for scripted setup, but for a real project it is better to run `kitchen init` deliberately and then edit the generated `kitchen.yml` to match your platforms and suites.

### After init

The generated file rarely survives contact with a real project unchanged. The usual next steps are to pick the [platforms](/docs/getting-started/12-adding-platform) you actually target, configure your [driver](/docs/drivers), and write a first test. The [Getting Started guide](/docs/getting-started/00-introduction) walks through this end to end.
