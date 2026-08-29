---
title: kitchen exec
menu:
  docs:
    identifier: cmd-exec
    parent: commands
    weight: 65
---

Runs a single command on one or more instances over their configured transport and prints the output. Where [`kitchen login`](/docs/commands/login) gives you an interactive session on one machine, `kitchen exec` runs one non-interactive command across many.

```bash
kitchen exec [INSTANCE|REGEXP|all] -c REMOTE_COMMAND
```

### Examples

```bash
kitchen exec default-ubuntu-2204 -c "uptime"
kitchen exec all -c "cat /etc/os-release"
kitchen exec ubuntu -c "systemctl is-active nginx"
kitchen exec all -c "df -h /"
```

### Flags

| Flag | Alias | Description |
| ---- | ---- | ---- |
| `--command COMMAND` | `-c` | The command to run on the instance. Required. |
| `--log-level LEVEL` | `-l` | `debug`, `info`, `warn`, `error`, or `fatal`. |
| `--log-overwrite` | | Set to `false` to keep old log files. |
| `--color` | | Toggle color output. |

### Quoting

The command is passed to the remote shell, so quote it as a single argument and remember that your local shell expands things first:

```bash
kitchen exec all -c "echo $HOME"    # expands locally, before sending
kitchen exec all -c 'echo $HOME'    # expands on the instance
```

Single quotes are usually what you want when the command references remote environment variables.

### Running across a matrix

`kitchen exec` accepts the same instance targeting as every other subcommand, which makes it a quick way to compare state across platforms:

```bash
# what kernel is each platform running?
kitchen exec all -c "uname -r"

# is the service up everywhere?
kitchen exec all -c "systemctl is-active nginx"

# confirm a package version across the matrix
kitchen exec all -c "nginx -v"
```

This is often faster than logging into each instance in turn, and the output is labelled per instance.

### When to use it instead of a test

`kitchen exec` is for exploration, not verification. It has no assertions and does not fail a build when the answer is wrong — it just prints what the command returned. Once you know what to check, move the check into your [verifier](/docs/verifiers) so it runs every time:

```ruby
# test/integration/default/nginx_test.rb
describe service('nginx') do
  it { should be_running }
end
```

{{% info %}}
Windows instances run the command through their configured WinRM shell, so use PowerShell or cmd syntax rather than POSIX shell syntax:

```bash
kitchen exec windows -c "Get-Service W3SVC"
```
{{% /info %}}
