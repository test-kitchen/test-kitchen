---
title: kitchen diagnose
menu:
  docs:
    identifier: cmd-diagnose
    parent: commands
    weight: 50
---

Prints the fully computed configuration for one or more instances as YAML — every default applied, every ERB expression evaluated, every layer of configuration merged. When `kitchen.yml` does not behave the way you expect, this is the command that shows you why.

```bash
kitchen diagnose [INSTANCE|REGEXP|all]
```

### Examples

```bash
kitchen diagnose                          # instance config for every instance
kitchen diagnose default-ubuntu-2204      # one instance
kitchen diagnose --all                    # everything, including loader and plugins
kitchen diagnose --loader                 # how the config files were merged
kitchen diagnose --plugins                # which plugin versions are loaded
kitchen diagnose --no-instances --plugins # plugins only, no instance dump
```

### Flags

| Flag | Default | Description |
| ---- | ---- | ---- |
| `--loader` | off | Include diagnostics about how the YAML files were found and merged. |
| `--plugins` | off | Include diagnostics about the loaded driver, provisioner, transport, and verifier plugins. |
| `--instances` | on | Include the computed configuration for each instance. Disable with `--no-instances`. |
| `--all` | off | Include all of the above. |
| `--test-base-path PATH` | | Set the base path for tests. |
| `--log-level LEVEL` | | `debug`, `info`, `warn`, `error`, or `fatal`. |
| `--color` | | Toggle color output. |

### Debugging configuration precedence

Test Kitchen merges up to three YAML files, and configuration can be set at the top level, per suite, and per platform. Working out what actually won by reading the files is error-prone. `--loader` shows the merge itself:

```bash
kitchen diagnose --loader --no-instances
```

The output reports each config file, whether it was found, and the raw data it contributed:

```yaml
loader:
  global_config:
    filename: "/home/user/.kitchen/config.yml"
    raw_data:
      ...
  project_config:
    filename: "/path/to/project/kitchen.yml"
    raw_data:
      ...
  local_config:
    filename: "/path/to/project/kitchen.local.yml"
    raw_data:
      ...
```

If a setting you expected is missing, compare `raw_data` against the merged instance output to see which layer overrode it.

### Checking plugin versions

```bash
kitchen diagnose --plugins --no-instances
```

This reports the driver, provisioner, transport, and verifier plugins Test Kitchen resolved, along with their versions. It answers "which kitchen-ec2 am I actually running?" — which matters when several Ruby environments are installed and a `gem install` landed somewhere unexpected.

### Verifying ERB and dynamic configuration

`kitchen.yml` supports ERB, so a config file can contain logic:

```yaml
driver:
  name: ec2
  region: <%= ENV['AWS_REGION'] || 'us-west-2' %>
```

`kitchen diagnose` shows the result *after* evaluation, so you can confirm what the expression produced instead of guessing:

```bash
kitchen diagnose default-ubuntu-2204 | grep region
```

{{% tip %}}
`kitchen diagnose` output is plain YAML, which makes it easy to diff. Capturing it before and after a configuration change is a quick way to see exactly what you altered:

```bash
kitchen diagnose --all > before.yml
# edit kitchen.yml
kitchen diagnose --all > after.yml
diff before.yml after.yml
```
{{% /tip %}}

### Reporting bugs

When filing an issue against Test Kitchen or a plugin, `kitchen diagnose --all` output is the single most useful thing you can include. It captures your configuration, plugin versions, and Ruby environment in one place.

{{% warning %}}
Review the output before sharing it. Computed configuration can contain credentials, private key paths, account identifiers, and other secrets pulled in from environment variables.
{{% /warning %}}
