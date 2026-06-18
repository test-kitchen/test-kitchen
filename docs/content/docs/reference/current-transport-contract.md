---
title: Current Transport Contract
menu:
  docs:
    parent: reference
    weight: 21
---

This page records the current Test Kitchen transport contract. It describes how
Kitchen uses transports today, including behavior that exists because of the
Ruby base classes, built-in SSH and WinRM transports, and current call sites.

This is not a redesign of the transport API. It is a snapshot of the current
state so future work can make the contract clearer.

## How Kitchen loads transports

Transports are Ruby plugins. Kitchen loads a transport by calling
`Kitchen::Transport.for_plugin(name, config)`, which delegates to the shared
plugin loader.

For a transport named `example`, Kitchen expects to be able to require:

```text
kitchen/transport/example
```

and find a class under `Kitchen::Transport`, such as:

```ruby
module Kitchen
  module Transport
    class Example < Kitchen::Transport::Base
    end
  end
end
```

Kitchen initializes the transport with a config hash and then finalizes it with
the instance before use.

## Methods Kitchen calls

The required transport method is:

```ruby
connection(state)
```

Kitchen call sites normally use block form:

```ruby
transport.connection(state) do |connection|
  connection.execute(command)
end
```

Kitchen does not automatically close the connection after the block. Transports
own connection caching, reuse, closing, and cleanup.

Transports may also implement:

```ruby
doctor(state)
cleanup!
```

`cleanup!` is called when the instance cleans up per-instance resources.

## Connection object

A transport connection should provide these methods:

```ruby
execute(command)
execute_with_retry(command, retryable_exit_codes, max_retries, wait_time)
upload(locals, remote)
download(remotes, local)
login_command
close
wait_until_ready
```

`Kitchen::Transport::Base::Connection` provides a default
`execute_with_retry` implementation. It retries only transport failures whose
`exit_code` appears in the retryable exit code list.

In practice, built-in transports treat `execute(nil)` as a silent no-op. Base
provisioner and verifier implementations rely on that behavior because command
hooks may return `nil`.

## State and config

Every call to `connection` receives the mutable instance state hash. Built-in
SSH and WinRM transports merge transport config and state, with state values
overriding config values for connection details such as hostname, port,
username, password, and similar fields.

That state-over-config behavior is part of the current practical contract.
Drivers often write connection details into state during `create`, and
transports read them later.

## File and command behavior

Provisioners, verifiers, and remote lifecycle hooks use transports for command
execution and file movement.

`upload` should accept a single local path or an array-like collection of local
paths plus a remote destination.

`download` should accept a single remote path or an array-like collection of
remote paths plus a local destination.

Non-zero command exits should raise `Kitchen::Transport::TransportFailed` or a
subclass. When possible, the exception should expose an `exit_code` so retry
logic and callers can make decisions.

`login_command` should return a `Kitchen::LoginCommand` when interactive login
is supported. The base implementation raises `Kitchen::ActionFailed` when it is
not supported.

## Current rough edges

The current transport contract includes several implicit behaviors:

* Connection block support is expected by core consumers, but block completion
  does not imply connection close.
* State overrides config for built-in transports.
* `execute(nil)` is expected to be a no-op.
* Some remote lifecycle hook skippability is coupled to SSH-style error text.
* `wait_until_ready` exists on the connection API but is not broadly used by
  core call sites.

Future work should define an explicit command, file, connection, login, retry,
and error contract so transports and external providers do not have to infer
behavior from built-in implementations.
