---
title: Verifiers
menu:
  docs:
    parent: verifiers
    weight: 1
---

A Test Kitchen *verifier* tests the configuration applied by the *provisioner*. The `test-kitchen` gem includes the legacy `busser` verifier and the built-in `shell` verifier. InSpec, Cinc Auditor, ServerSpec, Pester, and BATS support is supplied by plugin gems installed in the Ruby environment that runs `kitchen`.

### Verifiers documented here

| Verifier | Test framework |
| ---- | ---- |
| [InSpec](/docs/verifiers/inspec) | Chef InSpec |
| [Cinc Auditor](/docs/verifiers/cinc-auditor) | Cinc Auditor, the community distribution of InSpec |
| [Pester](/docs/verifiers/pester) | Pester, for PowerShell |
| [ServerSpec](/docs/verifiers/serverspec) | ServerSpec, via Busser |

### Other verifier plugins

- [busser-bats](https://github.com/test-kitchen/busser-bats/) — BATS, via Busser
- [busser-rspec](https://github.com/test-kitchen/busser-rspec/) — RSpec, via Busser
- [busser-minitest](https://github.com/test-kitchen/busser-minitest/) — Minitest, via Busser
