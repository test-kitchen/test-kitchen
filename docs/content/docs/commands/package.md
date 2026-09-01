---
title: kitchen package
menu:
  docs:
    identifier: cmd-package
    parent: commands
    weight: 70
---

Turns a single instance into a redistributable artifact, as implemented by that instance's [driver](/docs/drivers). What the artifact *is* depends entirely on the driver: a Vagrant box, a Docker image, a cloud image.

```bash
kitchen package INSTANCE|REGEXP
```

### Flags

| Flag | Alias | Description |
| ---- | ---- | ---- |
| `--log-level LEVEL` | `-l` | `debug`, `info`, `warn`, `error`, or `fatal`. |
| `--log-overwrite` | | Set to `false` to keep old log files. |
| `--color` | | Toggle color output. |

### One instance at a time

Like [`kitchen login`](/docs/commands/login), `package` operates on exactly one instance. A target matching several instances is an error.

### Driver support

`kitchen package` is optional for drivers. A driver that does not implement it will tell you so rather than producing an artifact.

| Driver | Produces |
| ---- | ---- |
| [kitchen-vagrant](/docs/drivers/vagrant) | A `.box` file from the converged VM. |
| [kitchen-docker](https://github.com/test-kitchen/kitchen-docker) | A Docker image committed from the container. |

Check the driver's own documentation for what it emits, where it writes it, and which configuration options control naming.

### Typical use

The point of packaging is to skip work later. A converge that installs a large set of dependencies can be run once and captured:

```bash
kitchen converge base-ubuntu-2204   # do the expensive setup
kitchen package base-ubuntu-2204    # capture the result
```

The resulting artifact can then be used as the starting image for other instances, so subsequent runs begin from a machine that already has the dependencies installed.

{{% warning %}}
Anything present on the instance ends up in the artifact — including credentials your provisioner uploaded, SSH keys, shell history, and log files. Treat a packaged image as sensitive unless you have deliberately cleaned it, and never publish one built from a converge that used real secrets.
{{% /warning %}}
