# 3. Record current driver contract

Date: 2026-06-18

## Status

Accepted

## Context

Test Kitchen supports external drivers through Ruby plugins. The current driver
contract is not a separate protocol; it is the behavior exposed by the
`Kitchen::Driver::Base` class, the shared plugin loader, the instance lifecycle,
and the existing built-in drivers and specs.

We need to record that current state before improving or replacing it with a
clearer contract.

## Decision

We will document the current driver contract as it exists today.

Drivers are Ruby plugins loaded by name. `Kitchen::Driver.for_plugin` delegates
to the shared plugin loader, which requires `kitchen/driver/<name>`, resolves a
class under `Kitchen::Driver`, and initializes it with a config hash.

Kitchen finalizes each driver with `finalize_config!(instance)` before lifecycle
actions. Finalization gives the driver access to the `Kitchen::Instance`, lazy
configuration, diagnostics, logging helpers, dependency checks, validations, and
path expansion.

The current live lifecycle methods Kitchen calls on drivers are:

- `create(state)`
- `destroy(state)`

Kitchen also calls these driver methods from explicit commands:

- `package(state)`
- `doctor(state)`

The `state` argument is the mutable instance state hash read from the state
file. Drivers may write connection details or resource identifiers into it, and
Kitchen persists that state after the action.

Although older examples and some built-in classes mention `setup` and `verify`,
the current instance lifecycle does not call driver `setup` or driver `verify`.
`setup` is currently an empty instance action, and `verify` is handled by the
verifier.

Drivers should raise `Kitchen::ActionFailed` for expected action failures. The
instance action wrapper records `last_error`, preserves the previous
`last_action`, logs failure details, and raises `Kitchen::InstanceFailure` for
the user-facing command failure.

We will add the user-facing documentation note at
`docs/content/docs/reference/current-driver-contract.md`.

## Consequences

This records the current behavior without trying to clean it up.

Future work can use this record to decide what should become a stable public
contract, what should remain Ruby-only base-class behavior, and what should be
changed or removed from a future external provider protocol.
