# 4. Record current transport contract

Date: 2026-06-18

## Status

Accepted

## Context

Test Kitchen supports external transports through Ruby plugins. Transports are
the current boundary for command execution, file upload and download, login
commands, and connection reuse. Provisioners, verifiers, remote lifecycle hooks,
and login commands all depend on this surface.

The current transport contract is not a language-neutral protocol. It is the
Ruby object surface implemented by `Kitchen::Transport::Base`, its nested
connection class, the built-in transports, and the call sites that consume them.

## Decision

We will document the current transport contract as it exists today.

Transports are Ruby plugins loaded by name. `Kitchen::Transport.for_plugin`
delegates to the shared plugin loader, which requires `kitchen/transport/<name>`,
resolves a class under `Kitchen::Transport`, and initializes it with a config
hash.

Kitchen finalizes each transport with `finalize_config!(instance)` before use.
Finalization gives the transport access to the `Kitchen::Instance`, lazy
configuration, diagnostics, logging helpers, dependency checks, validations, and
path expansion.

The required transport method is:

- `connection(state)`

The `connection` method should return or yield a connection object. Current core
call sites use block form, but Kitchen does not automatically close the
connection after the block. Transports own connection caching, reuse, closing,
and cleanup.

The connection object is expected to support:

- `execute(command)`
- `execute_with_retry(command, retryable_exit_codes, max_retries, wait_time)`
- `upload(locals, remote)`
- `download(remotes, local)`
- `login_command`
- `close`
- `wait_until_ready`

In practice, `execute(nil)` is expected to be a silent no-op. Non-zero command
exits should be represented as `Kitchen::Transport::TransportFailed` or a
subclass with an `exit_code` when possible. Provisioners and verifiers translate
transport failures into `Kitchen::ActionFailed`.

Built-in SSH and WinRM transports merge configuration and state so state values
override config values for connection details such as host, port, username, and
password. This state-over-config behavior is part of the practical current
contract.

We will add the user-facing documentation note at
`docs/content/docs/reference/current-transport-contract.md`.

## Consequences

This records the command, file, login, state, and failure behavior that external
transport authors must understand today.

Future work can use this record to decide whether Kitchen should keep transport
ownership for external providers, expose a smaller serialized command/file API,
or define a clearer connection lifecycle and error model.
