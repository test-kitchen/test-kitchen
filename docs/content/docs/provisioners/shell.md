---
title: Shell
slug: shell
menu:
  docs:
    parent: provisioners
    weight: 5
---

The Shell Provisioner can be used instead of managing with one of the supported configuration tools.

If the only value provided to the `provisioner:` configuration is `name: shell`, then Test Kitchen looks for a file named `bootstrap.sh` or `bootstrap.ps1` in the root of the project.

### Provisioner Default Usage

```yaml
---
provisioner:
  name: shell
```

### Provisioner Options

```yaml
---
provisioner:
  name: shell
  script:    'test/scripts/setup.sh' # Optional - default: bootstrap.sh/bootstrap.ps1
  arguments: ['--debug']             # Optional - Add extra arguments to the converge script.
  root_path: '/home/vagrant/'        # Optional - default: kitchen_root ('/tmp')
  command:   'hostname'              # Optional - Run a single command instead of managing and running a script.
```
