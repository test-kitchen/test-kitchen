---
title: Current Provisioner Contract
menu:
  docs:
    parent: reference
    weight: 22
---

This page records the current Test Kitchen provisioner contract. It describes
how Kitchen uses provisioners today, including behavior that exists because of
the Ruby base classes and current transport integration.

This is not a redesign of the provisioner API. It is a snapshot of the current
state so future work can make the contract clearer.

## How Kitchen loads provisioners

Provisioners are Ruby plugins. Kitchen loads a provisioner by calling
`Kitchen::Provisioner.for_plugin(name, config)`, which delegates to the shared
plugin loader.

For a provisioner named `example`, Kitchen expects to be able to require:

```text
kitchen/provisioner/example
```

and find a class under `Kitchen::Provisioner`, such as:

```ruby
module Kitchen
  module Provisioner
    class Example < Kitchen::Provisioner::Base
    end
  end
end
```

Kitchen initializes the provisioner with a config hash and then finalizes it
with the instance before convergence.

## Methods Kitchen calls

The current provisioner methods Kitchen depends on are:

```ruby
check_license
call(state)
doctor(state)
```

Kitchen calls `check_license` immediately before `call(state)` during converge.
`doctor(state)` is called by `kitchen doctor`.

`state` is the mutable instance state hash. Kitchen reads it before converge and
writes it after the action.

## Using the base workflow

A provisioner can subclass `Kitchen::Provisioner::Base` and use the default
remote execution workflow.

In that workflow, a provisioner can implement these command hooks:

```ruby
install_command
init_command
prepare_command
run_command
```

The base workflow:

* creates a local sandbox
* uploads configured `uploads`
* opens `instance.transport.connection(state)`
* runs install and init commands
* uploads sandbox contents to `root_path`
* runs prepare
* runs the main command with `execute_with_retry`
* downloads configured `downloads`
* cleans up the local sandbox

Downloads are attempted in an ensure block, so configured downloads may run even
after the converge command fails. This is what makes it possible to retrieve logs
that explain a failed converge.

Downloads are best-effort. A file that cannot be downloaded logs a warning rather
than failing the action, and a download failure never replaces an error already
propagating from the converge command. A transport that does not implement
`download` raises `Kitchen::ClientError`, which still surfaces.

Each command hook may return `nil`. Current transports are expected to no-op
for `execute(nil)`.

## Overriding the workflow

A provisioner may override `call(state)` entirely. In that case it owns its
transport usage, local execution, logging, state updates, and failure behavior.

The built-in dummy provisioner demonstrates this minimal pattern: it does not
use the base transport workflow and raises `Kitchen::ActionFailed` when
configured to fail.

## What the base class provides

Provisioners normally get these shared helpers from the base class and
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
* `no_parallel_for :converge`

## Failure behavior

Provisioners should raise `Kitchen::ActionFailed` for expected converge
failures.

The base workflow rescues `Kitchen::Transport::TransportFailed` and re-raises
`Kitchen::ActionFailed`. Kitchen then records the failure in state, logs details,
preserves the previous successful lifecycle state, and raises
`Kitchen::InstanceFailure`.

## Current rough edges

The current provisioner contract includes several implicit behaviors:

* The base workflow depends heavily on the transport command and file APIs.
* Provisioner state is shared mutable instance state with no namespace.
* Windows over SSH has special behavior that inspects transport config details.
* Secret handling and redaction are not expressed as a formal provisioner
  contract.
* A provisioner can either use the base workflow or replace it completely, which
  makes the true minimum contract smaller than the base class suggests.

Future work should define a clearer provisioner contract, including serialized
configuration, state ownership, events, failure reporting, transport boundaries,
and secret handling.
