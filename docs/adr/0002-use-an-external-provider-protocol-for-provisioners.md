# 2. Use an external provider protocol for provisioners

Date: 2026-06-18

## Status

Proposed

## Context

Test Kitchen providers are currently implemented as Ruby plugins. That keeps
providers close to Kitchen internals, but it makes it hard to implement a
provider in another language while preserving the normal Kitchen user
experience: YAML configuration, lifecycle commands, instance state, logging,
and predictable failure reporting.

The first concrete use case is a Go-based Cinc provisioner. The design should
not require v1 to solve every provider type, but it should leave room for
drivers, transports, and verifiers later.

This ADR records the direction proposed in
[issue 2056](https://github.com/test-kitchen/test-kitchen/issues/2056).

## Decision

We will define a versioned external provider protocol for Test Kitchen, starting
with provisioners only.

Kitchen configuration will use an explicit built-in external adapter:

```yaml
provisioner:
  name: external
  command: kitchen-provider-cinc
```

Provider-specific configuration can remain under the provisioner configuration
and be passed to the external provider as normalized JSON.

For v1, Kitchen will invoke short-lived provider subcommands:

```text
kitchen-provider-cinc capabilities
kitchen-provider-cinc validate --config config.json
kitchen-provider-cinc run --context context.json
```

Runtime events emitted by `run` will use newline-delimited JSON. `capabilities`,
`validate`, and any schema-related commands can use normal JSON output unless a
single parser for every command becomes preferable.

Kitchen should retain transport ownership for v1 unless the first provider
requires lower-level control. The external provisioner should receive enough
context to generate commands, upload files through Kitchen-owned mechanisms,
and report events, while Kitchen continues to execute SSH and WinRM operations.

Provider state will be namespaced under a provider-owned key to avoid
collisions with Kitchen state:

```json
{
  "providers": {
    "cinc": {
      "client_version": "18.6.2"
    }
  }
}
```

Protocol failures and provisioner failures will be reported differently:

- Provider protocol errors, such as invalid JSON, unsupported protocol versions,
  missing commands, or malformed event streams, exit non-zero.
- Normal provisioner failures, such as a failed Cinc run or policy failure,
  should be emitted as structured result events so Kitchen can report them as
  user-facing converge failures.

The protocol specification will define how Kitchen converts Ruby and YAML data
into provider JSON. ERB-rendered YAML is evaluated before provider invocation,
Ruby symbols and hash keys become JSON strings, unsupported Ruby objects are
rejected during validation, and mutable Kitchen state is serialized through a
stable versioned shape.

Secrets must have explicit handling rules before implementation. v1 should
prefer passing secret references, file paths, or environment variable names over
raw secret values. If raw secrets must be passed, providers must identify
sensitive fields and Kitchen must redact those values from logs and emitted
events.

The initial documentation and schemas should live in predictable project paths,
for example:

```text
docs/external-provider-protocol.md
schemas/provider-request.v1.json
schemas/provider-event.v1.json
schemas/provider-result.v1.json
```

## Consequences

External provisioners can be implemented outside Ruby without changing the
Kitchen workflow users already understand.

The explicit `name: external` configuration makes it clear that Kitchen is
loading a built-in adapter and invoking an executable provider, rather than
loading a Ruby plugin named after the provider.

Starting with provisioners keeps the first protocol small enough to implement
and test against a real provider. Driver, transport, and verifier support can be
added after the process, state, event, failure, and redaction contracts have
been proven.

Keeping transport in Kitchen reduces the v1 security surface and avoids asking
each provider to reimplement SSH and WinRM behavior. It may constrain providers
that need direct transport control, so the transport boundary must be validated
against the Go Cinc provisioner before the protocol is considered stable.

The protocol adds new compatibility responsibilities. Kitchen and providers need
clear version negotiation, schema enforcement rules, stdout and stderr
contracts, event presentation in Kitchen logs, and acceptance tests using a fake
external provisioner.

Before implementation, maintainers still need to settle these details:

- Whether providers may update only their own state namespace or request changes
  to shared instance state.
- Whether state writes happen only through the final result event.
- Whether `validate` and `run` receive input through file paths, stdin, or both.
- Whether schemas are documentation only or enforced by Kitchen.
- Whether the first audience for the specification is Test Kitchen maintainers,
  external provider authors, or the initial Go Cinc provider implementation.
