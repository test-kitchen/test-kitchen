---
title: kitchen box
menu:
  docs:
    parent: commands
---

`kitchen box` can inspect a local or mounted manifest outside a Kitchen project.

```sh
kitchen box list --manifest /path/to/manifest.json
kitchen box doctor --manifest /path/to/manifest.json --provider parallels --architecture arm64 --checksum
```

Set `KITCHEN_BOX_MANIFEST` to use a default manifest. The manifest is a JSON
array with `name`, `version`, `provider`, `architecture`, `file`, `bytes` and
`sha256` for each archive. `file` is a filename in the manifest directory.
Doctor checks readability and size by default. `--checksum` also reads and
verifies the SHA-256 of each selected archive.

Drivers using the shared box library can resolve an exact box version from
the manifest and copy it to the local cache. The cache is keyed by SHA-256,
and the archive must match the manifest before the driver can import it. A
repeat import reuses the local copy. Cache location defaults to
`~/.cache/test-kitchen/boxes`. Set `KITCHEN_BOX_CACHE` or the supporting
driver's `box_cache` setting to override it.

```sh
kitchen box prune --dry-run
kitchen box prune --dry-run --cache /path/to/local/cache --json
```

Prune requires `--dry-run`. The preview reports unused archives and their
total archive size. It leaves the cache and source archives untouched.
Drivers hold a cache lease from
before import until successful destroy, so the report excludes active
instances and failed creates that still need cleanup. Run `kitchen destroy`
before discarding the instance state so the driver can release its lease.

All three commands support `--json` and can filter by `--name`, `--version`,
`--provider` or `--architecture`. Prune reads only the cache and never needs
the source manifest.
