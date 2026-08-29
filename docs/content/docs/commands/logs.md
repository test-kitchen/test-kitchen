---
title: kitchen logs
menu:
  docs:
    identifier: cmd-logs
    parent: commands
    weight: 55
---

Prints the structured log events Test Kitchen recorded for one or more instances. Where the console output of a run is designed for a human watching it happen, structured logs are designed to be read afterwards and queried by machine.

```bash
kitchen logs [INSTANCE|REGEXP|all]
```

### Examples

```bash
kitchen logs default-ubuntu-2204              # the current session for one instance
kitchen logs default-ubuntu-2204 --follow     # stream events as they happen
kitchen logs default-ubuntu-2204 --format ndjson
kitchen logs --all-sessions                   # every recorded session
kitchen logs default-ubuntu-2204 --level error
```

### Flags

| Flag | Alias | Default | Description |
| ---- | ---- | ---- | ---- |
| `--format FORMAT` | | `text` | Output format: `text` or `ndjson`. |
| `--follow` | `-f` | | Stream the log file as it grows, like `tail -f`. |
| `--level LEVEL` | | | Minimum level to print: `debug`, `info`, `warn`, `error`, `fatal`. |
| `--session-id ID` | | | Print only the events for one instance session. |
| `--all-sessions` | | | Print events from every recorded session. |
| `--log-level LEVEL` | `-l` | | Test Kitchen's own log level for this command. |
| `--color` | | | Toggle color output. |

### Where logs live

Structured logs are written as newline-delimited JSON to:

```text
.kitchen/logs/<instance-name>.ndjson
```

Each `kitchen` invocation against an instance is a *session* with its own id, and one file accumulates events across many sessions. By default `kitchen logs` prints only the current — or most recent — session, which is almost always what you want. `--all-sessions` prints the full history.

### Sessions

```bash
kitchen logs default-ubuntu-2204                     # most recent session
kitchen logs default-ubuntu-2204 --all-sessions      # every session in the file
kitchen logs default-ubuntu-2204 --session-id abc123 # one specific session
```

{{% info %}}
`--follow` streams a single log file, so it requires a target that resolves to exactly one instance. `kitchen logs --follow` across several instances is rejected rather than interleaving output you could not untangle.
{{% /info %}}

### Machine-readable output

`--format ndjson` emits one JSON object per line, which composes well with `jq`:

```bash
# every error event from the last run
kitchen logs default-ubuntu-2204 --format ndjson | jq 'select(.level == "error")'

# just the messages, in order
kitchen logs default-ubuntu-2204 --format ndjson | jq -r '.message'

# every session id recorded for this instance
kitchen logs default-ubuntu-2204 --all-sessions --format ndjson | jq -r '.session_id' | sort -u
```

This is what makes structured logs worth having in CI: a failed job can attach the ndjson file, and you can query it later instead of scrolling through captured terminal output.

### Watching a run in progress

Start a converge in one terminal:

```bash
kitchen converge default-ubuntu-2204
```

and follow its structured events in another:

```bash
kitchen logs default-ubuntu-2204 --follow
```

This is useful for long converges where the console output scrolls past faster than you can read it, and for filtering to just the events you care about:

```bash
kitchen logs default-ubuntu-2204 --follow --level warn
```
