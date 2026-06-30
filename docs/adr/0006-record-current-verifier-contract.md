# 6. Record current verifier contract

Date: 2026-06-18

## Status

Accepted

## Context

Test Kitchen supports external verifiers through Ruby plugins. Verifiers are the
current integration point for running tests or checks after create, converge,
and setup have completed.

The current verifier contract is not a separate protocol. It is the Ruby object
surface implemented by `Kitchen::Verifier::Base`, the shared configuration and
lifecycle helpers, built-in verifier behavior, and the transport connection API
that remote verifiers consume.

## Decision

We will document the current verifier contract as it exists today.

Verifiers are Ruby plugins loaded by name. `Kitchen::Verifier.for_plugin`
delegates to the shared plugin loader, which requires `kitchen/verifier/<name>`,
resolves a class under `Kitchen::Verifier`, and initializes it with a config
hash.

Kitchen finalizes each verifier with `finalize_config!(instance)` before use.
Finalization gives the verifier access to the `Kitchen::Instance`, lazy
configuration, diagnostics, logging helpers, dependency checks, validations, and
path expansion.

The current verifier method Kitchen depends on is:

- `call(state)`

Verifiers may also implement:

- `doctor(state)`

The `state` argument is the mutable instance state hash read from the state
file. Verifiers may read and write that state. Kitchen records `last_action` and
`last_error` around the action.

Verifiers that subclass `Kitchen::Verifier::Base` can use its default sandbox
and transport workflow. That workflow creates a local sandbox, uploads sandbox
contents, then runs optional command hooks:

- `install_command`
- `init_command`
- `prepare_command`
- `run_command`

The base workflow uses `instance.transport.connection(state)` and calls
`execute`, `upload`, and `download` on the transport connection. Verifiers may
also override `call(state)` entirely. The shell verifier demonstrates that a
verifier can run locally by default and only use remote execution when
configured to do so.

Verifiers should raise `Kitchen::ActionFailed` for expected verification
failures. `Kitchen::Transport::TransportFailed` raised by the base workflow is
converted into `Kitchen::ActionFailed`.

We will add the user-facing documentation note at
`docs/content/docs/reference/current-verifier-contract.md`.

## Consequences

This records the current verifier behavior without treating it as clean or
complete.

Future work can use this record to decide what belongs in a stable verifier
contract, what should be shared with provisioners, and how Kitchen should make
local execution, remote execution, state, and failures easier for plugin authors
to reason about.
