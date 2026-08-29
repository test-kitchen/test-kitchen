---
title: kitchen login
menu:
  docs:
    identifier: cmd-login
    parent: commands
    weight: 60
---

Opens an interactive shell session on a single instance, using whichever [transport](/docs/transports) that instance is configured with.

```bash
kitchen login INSTANCE|REGEXP
```

### Examples

```bash
kitchen login default-ubuntu-2204   # log in by full name
kitchen login ubuntu                # log in by regexp, if it matches exactly one
```

### Flags

| Flag | Alias | Description |
| ---- | ---- | ---- |
| `--log-level LEVEL` | `-l` | `debug`, `info`, `warn`, `error`, or `fatal`. |
| `--log-overwrite` | | Set to `false` to keep old log files. |
| `--color` | | Toggle color output. |

### One instance at a time

`kitchen login` requires a target that resolves to exactly one instance. There is no interactive shell that could sensibly span several machines, so a regexp matching more than one instance is an error rather than a prompt.

```bash
kitchen login                # error: matches every instance
kitchen login ubuntu         # fine, if exactly one instance matches
kitchen list --bare          # use this to find the exact name
```

### What you get

The session depends on the transport:

| Transport | Session |
| ---- | ---- |
| [SSH](/docs/transports/ssh) | An SSH session as the configured user. |
| [WinRM](/docs/transports/winrm) | A PowerShell or cmd session, depending on configuration. |
| [Docker](/docs/transports/docker) | A shell inside the running container. |

Because the login uses the same credentials and connection settings as the rest of the lifecycle, a successful `kitchen login` also confirms your transport configuration is correct.

### Typical debugging loop

`kitchen login` is most useful immediately after a failure, because [`kitchen test`](/docs/commands/test) leaves failing instances running by default:

```bash
kitchen test default-ubuntu-2204    # fails during verify
kitchen login default-ubuntu-2204   # look at the machine as the tests found it
```

Once you are on the instance, inspect the things your tests asserted:

```bash
systemctl status nginx
cat /etc/nginx/nginx.conf
journalctl -u nginx --no-pager | tail -50
```

{{% tip %}}
Changes you make by hand during a login session are wiped by the next `kitchen test`, since it destroys the instance first. Use the session to understand the problem, then fix it in your cookbook or configuration — not on the instance.
{{% /tip %}}
