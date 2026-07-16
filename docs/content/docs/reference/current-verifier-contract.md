---
title: Current Verifier Contract
menu:
  docs:
    parent: reference
    weight: 23
---

This page records the current Test Kitchen verifier contract. It describes how
Kitchen uses verifiers today, including behavior that exists because of the Ruby
base classes, local shell execution, and current transport integration.

This is not a redesign of the verifier API. It is a snapshot of the current
state so future work can make the contract clearer.

## How Kitchen loads verifiers

Verifiers are Ruby plugins. Kitchen loads a verifier by calling
`Kitchen::Verifier.for_plugin(name, config)`, which delegates to the shared
plugin loader.

For a verifier named `example`, Kitchen expects to be able to require:

```text
kitchen/verifier/example
```

and find a class under `Kitchen::Verifier`, such as:

```ruby
module Kitchen
  module Verifier
    class Example < Kitchen::Verifier::Base
    end
  end
end
```

Kitchen initializes the verifier with a config hash and then finalizes it with
the instance before verification.

## Methods Kitchen calls

The current verifier method Kitchen depends on is:

```ruby
call(state)
```

Verifiers may also implement:

```ruby
doctor(state)
```

`state` is the mutable instance state hash. Kitchen reads it before verification
and writes it after the action.

## Using the base workflow

A verifier can subclass `Kitchen::Verifier::Base` and use the default remote
execution workflow.

In that workflow, a verifier can implement these command hooks:

```ruby
install_command
init_command
prepare_command
run_command
```

The base workflow:

* creates a local sandbox
* opens `instance.transport.connection(state)`
* runs install and init commands
* uploads sandbox contents to `root_path`
* runs prepare
* runs the main command
* downloads configured `downloads`
* cleans up the local sandbox

Downloads are attempted in an ensure block, so configured downloads may run even
after the verifier command fails.

Downloads are best-effort. A file that cannot be downloaded logs a warning rather
than failing the action, and a download failure never replaces an error already
propagating from the verifier command. A transport that does not implement
`download` raises `Kitchen::ClientError`, which still surfaces.

Each command hook may return `nil`. Current transports are expected to no-op
for `execute(nil)`.

## Overriding the workflow

A verifier may override `call(state)` entirely. In that case it owns its
transport usage, local execution, logging, state updates, and failure behavior.

The shell verifier demonstrates this broader current contract. It runs locally
by default through shell-out and only returns a remote command when configured
with remote execution.

## What the base class provides

Verifiers normally get these shared helpers from the base class and
configuration mixin:

* `finalize_config!(instance)`
* access to `instance`, `instance.platform`, `instance.suite`, and
  `instance.transport`
* hash-like config lookup with `[]`
* path and shell helpers for Unix, Windows, Bourne shell, and PowerShell
* proxy and environment wrapping helpers
* sandbox helpers such as `create_sandbox`, `sandbox_path`, `sandbox_dirs`, and
  `cleanup_sandbox`
* diagnostics and plugin metadata
* logging helpers
* `no_parallel_for :verify`

## Failure behavior

Verifiers should raise `Kitchen::ActionFailed` for expected verification
failures.

The base workflow rescues `Kitchen::Transport::TransportFailed` and re-raises
`Kitchen::ActionFailed`. Kitchen then records the failure in state, logs details,
preserves the previous successful lifecycle state, and raises
`Kitchen::InstanceFailure`.

## Current rough edges

The current verifier contract includes several implicit behaviors:

* The base workflow depends on the transport command and file APIs.
* Local and remote execution are both valid verifier patterns.
* Downloads can run after a verifier command failure.
* Verifier state is shared mutable instance state with no namespace.
* A verifier can either use the base workflow or replace it completely, which
  makes the true minimum contract smaller than the base class suggests.

Future work should define a clearer verifier contract, including local versus
remote execution, serialized context, state ownership, event output, and failure
reporting.
