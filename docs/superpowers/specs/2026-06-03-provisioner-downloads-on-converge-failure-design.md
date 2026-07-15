# Provisioner `downloads` on converge failure — Design

- **Date:** 2026-06-03
- **Issue:** [test-kitchen#2036 — Add ability to retrieve files after each step](https://github.com/test-kitchen/test-kitchen/issues/2036)
- **Status:** Approved design, ready for implementation plan

## Problem statement

When a converge fails, Test Kitchen stops before the verify step. Users who rely
on retrieving log files from the system under test (SUT) — to diagnose *why*
converge failed — never get those files, because the only retrieval that runs is
attached to the verifier, which never executes.

The issue author's request: retrieve files/directories from the SUT after a step
completes, **especially on failure**.

## Root cause

This is a concrete asymmetry between two plugins that already share the same
`downloads:` feature, not a missing feature:

- The **provisioner** has a documented `downloads:` config
  (`lib/kitchen/provisioner/base.rb:55`, documented in
  `docs/content/docs/provisioners/_index.md:27` as "download post-converge").
- The **verifier** has the same `downloads:` feature, and thanks to
  [PR #1916](https://github.com/test-kitchen/test-kitchen/pull/1916) ("Always
  download files even if verifier fails") it wraps its run command in
  `begin/ensure`, so downloads happen even when the run fails
  (`lib/kitchen/verifier/base.rb:77-86`).
- The **provisioner does not.** Its download loop runs inline *after*
  `execute_with_retry`, so when converge fails the download is skipped entirely
  (`lib/kitchen/provisioner/base.rb:107-119`).

The test suites confirm the gap: the verifier spec has a
`"downloads files when run fails"` test (`spec/kitchen/verifier/base_spec.rb:252`);
the provisioner spec has only the success case.

## Design

Make the provisioner mirror the verifier. In `Kitchen::Provisioner::Base#call`,
wrap the converge run command in `begin/ensure`, moving the existing `downloads`
loop into the `ensure` block.

### Before (`lib/kitchen/provisioner/base.rb:107-119`)

```ruby
debug("Executing run command: #{run_command}")
conn.execute_with_retry(
  encode_for_powershell(run_command),
  config[:retry_on_exit_code],
  config[:max_retries],
  config[:wait_for_retry]
)
info("Downloading files from #{instance.to_str}")
config[:downloads].to_h.each do |remotes, local|
  debug("Downloading #{Array(remotes).join(", ")} to #{local}")
  conn.download(remotes, local)
end
debug("Download complete")
```

### After

```ruby
debug("Executing run command: #{run_command}")
begin
  conn.execute_with_retry(
    encode_for_powershell(run_command),
    config[:retry_on_exit_code],
    config[:max_retries],
    config[:wait_for_retry]
  )
ensure
  info("Downloading files from #{instance.to_str}")
  config[:downloads].to_h.each do |remotes, local|
    debug("Downloading #{Array(remotes).join(", ")} to #{local}")
    conn.download(remotes, local)
  end
  debug("Download complete")
end
```

When converge fails, the `ensure` still pulls the files, then the original
exception propagates to the existing `rescue Kitchen::Transport::TransportFailed
=> ex; raise ActionFailed` handler and the outer `ensure cleanup_sandbox`.

This reuses the existing `downloads:` config — no new config surface, no new
classes.

## Testing (TDD)

Add a `"downloads files when run fails"` test to
`spec/kitchen/provisioner/base_spec.rb`, mirroring the verifier's test at
`spec/kitchen/verifier/base_spec.rb:252`:

- Stub `connection.execute_with_retry` to raise (the provisioner runs the converge
  command via `execute_with_retry`, not `execute`).
- Expect both `connection.download` calls (the two entries in the existing
  `config[:downloads]` fixture set up in the spec's `before` block) still happen.
- Wrap `cmd` in `begin/rescue` so the raised error doesn't fail the test.

Write the test first. Against today's code it fails (downloads are skipped on
failure). The source change makes it pass. The existing `"downloads files"`
(success) test must continue to pass unchanged.

## Documentation

Update the provisioner `downloads` documentation
(`docs/content/docs/provisioners/_index.md:27`) to note that downloads now run
even when converge fails, so log retrieval works in the failure case. Small
wording tweak to an existing comment/section.

## Compatibility

- **Success path:** unchanged — downloads still happen after a successful converge.
- **Failure path:** downloads now happen (previously skipped). Purely additive.
- No new or changed configuration keys; existing `downloads:` config drives it.

## Known limitation (shared with the verifier)

If converge fails **and** a listed file cannot be downloaded (e.g. it was never
created because converge died early), the download's `TransportFailed` surfaces
instead of the original converge error. The verifier already behaves exactly this
way. We mirror it here for consistency. Fixing the error-masking for both plugins
is intentionally out of scope for this change.

## Out of scope

- Separate on-success vs on-failure download sets (the issue's "perhaps" — the
  "always download" behavior already covers retrieving-on-failure).
- A general `download:` lifecycle hook type for arbitrary phases.
- Changing the error-masking behavior described above.

## Acceptance criteria

1. With `downloads:` configured on the provisioner, a **failing** converge still
   downloads the configured files to the local destinations.
2. A **successful** converge continues to download exactly as before.
3. New provisioner spec `"downloads files when run fails"` passes; existing
   provisioner and verifier specs remain green.
4. Provisioner `downloads` docs mention the on-failure behavior.
