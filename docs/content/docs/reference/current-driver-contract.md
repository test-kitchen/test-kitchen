---
title: Current Driver Contract
menu:
  docs:
    parent: reference
    weight: 20
---

This page records the current Test Kitchen driver contract. It describes how
Kitchen uses drivers today, including behavior that exists because of the Ruby
base classes and current implementation details.

This is not a redesign of the driver API. It is a snapshot of the current state
so future work can make the contract clearer.

## How Kitchen loads drivers

Drivers are Ruby plugins. Kitchen loads a driver by calling
`Kitchen::Driver.for_plugin(name, config)`, which delegates to the shared plugin
loader.

For a driver named `example`, Kitchen expects to be able to require:

```text
kitchen/driver/example
```

and find a class under `Kitchen::Driver`, such as:

```ruby
module Kitchen
  module Driver
    class Example < Kitchen::Driver::Base
    end
  end
end
```

Kitchen initializes the driver with a config hash:

```ruby
driver = Kitchen::Driver::Example.new(config)
```

Kitchen then finalizes it with the instance before actions run:

```ruby
driver.finalize_config!(instance)
```

## Methods Kitchen calls

The current core lifecycle calls these driver methods:

```ruby
create(state)
destroy(state)
```

Kitchen also calls these methods from explicit commands:

```ruby
package(state)
doctor(state)
```

`Kitchen::Driver::Base` provides no-op defaults for `destroy`, `package`, and
`doctor`. Its default `create` only supports the legacy `pre_create_command`
behavior.

Although some older code and examples mention driver `setup` and driver
`verify`, Kitchen does not currently call driver `setup` or driver `verify`.
The instance `setup` action is empty, and verification is handled by the
verifier.

## State

Every driver action receives a mutable `state` hash:

```ruby
def create(state)
  state[:hostname] = "192.0.2.10"
end
```

Kitchen reads this hash from the instance state file before the action and
writes it back after the action. Drivers commonly use it to persist resource
identifiers and connection details that transports later consume.

Kitchen also writes `last_action` and `last_error` around lifecycle actions.

## What the base class provides

Drivers normally subclass `Kitchen::Driver::Base`. The base class provides:

* configuration defaults and validation helpers
* `finalize_config!(instance)`
* access to `instance`
* hash-like config lookup with `[]`
* diagnostics through `diagnose` and `diagnose_plugin`
* logging helpers such as `debug`, `info`, `warn`, and `error`
* shell-out support through `run_command`
* plugin metadata helpers such as `plugin_version` and
  `kitchen_driver_api_version`
* `no_parallel_for` support for serialized actions

The shared configuration helper expands paths, runs deprecation checks,
validates required config, and loads dependencies during finalization.

## Failure behavior

Drivers should raise `Kitchen::ActionFailed` for expected action failures.

When an action raises `Kitchen::ActionFailed`, Kitchen records the failure in
state, logs the detailed error, preserves the previous successful lifecycle
state, and raises `Kitchen::InstanceFailure` for the user-facing command.

Unexpected exceptions are wrapped by Kitchen as action failures.

## Current rough edges

The current driver contract is broader and less precise than the live lifecycle
requires. In particular:

* `setup` and `verify` appear in some older driver-oriented behavior but are not
  called as driver actions today.
* Drivers may interact with `instance.transport` directly, as built-in proxy and
  exec-style drivers do.
* Drivers write arbitrary keys into shared instance state, and those keys may be
  interpreted later by transports or other plugins.

Future work should make the driver contract explicit, reduce reliance on
shared mutable state, and clarify which responsibilities belong to drivers
versus transports and other plugin types.
