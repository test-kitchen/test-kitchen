# 5. Record current provisioner contract

Date: 2026-06-18

## Status

Accepted

## Context

Test Kitchen supports external provisioners through Ruby plugins. Provisioners
are the main current integration point for configuring an instance after it has
been created and before verification runs.

The current provisioner contract is not a separate protocol. It is the Ruby
object surface implemented by `Kitchen::Provisioner::Base`, the shared
configuration and lifecycle helpers, the built-in provisioners, and the
transport connection API that provisioners consume.

## Decision

We will document the current provisioner contract as it exists today.

Provisioners are Ruby plugins loaded by name. `Kitchen::Provisioner.for_plugin`
delegates to the shared plugin loader, which requires
`kitchen/provisioner/<name>`, resolves a class under `Kitchen::Provisioner`, and
initializes it with a config hash.

Kitchen finalizes each provisioner with `finalize_config!(instance)` before use.
Finalization gives the provisioner access to the `Kitchen::Instance`, lazy
configuration, diagnostics, logging helpers, dependency checks, validations, and
path expansion.

The current provisioner methods Kitchen depends on are:

- `check_license`
- `call(state)`
- `doctor(state)`

The `state` argument is the mutable instance state hash read from the state
file. Provisioners may read and write that state. Kitchen records
`last_action` and `last_error` around the action.

Provisioners that subclass `Kitchen::Provisioner::Base` can use its default
sandbox and transport workflow. That workflow creates a local sandbox, uploads
configured files and sandbox contents, then runs optional command hooks:

- `install_command`
- `init_command`
- `prepare_command`
- `run_command`

The base workflow uses `instance.transport.connection(state)` and calls
`upload`, `execute`, `execute_with_retry`, and `download` on the transport
connection. Provisioners may also override `call(state)` entirely and avoid the
base workflow.

Provisioners should raise `Kitchen::ActionFailed` for expected converge
failures. `Kitchen::Transport::TransportFailed` raised by the base workflow is
converted into `Kitchen::ActionFailed`.

We will add the user-facing documentation note at
`docs/content/docs/reference/current-provisioner-contract.md`.

## Consequences

This records the current provisioner behavior without treating it as clean or
complete.

Future work can use this record to identify which parts of the provisioner
surface should become an external provider protocol, including serialized
configuration, state ownership, event output, failure behavior, secret handling,
and the boundary between provisioners and transports.
