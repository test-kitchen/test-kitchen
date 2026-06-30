---
title: Verifiers
menu:
  docs:
    parent: verifiers
    weight: 1
---

A Test Kitchen *verifier* tests the configuration applied by the *provisioner*. The `test-kitchen` gem includes the legacy `busser` verifier and the built-in `shell` verifier. InSpec, Cinc Auditor, ServerSpec, Pester, and BATS support is supplied by plugin gems installed in the Ruby environment that runs `kitchen`.

Common verifier plugins:

* [kitchen-inspec](https://github.com/inspec/kitchen-inspec)
* [kitchen-cinc-auditor](https://github.com/test-kitchen/kitchen-cinc-auditor)
* [busser-bats](https://github.com/test-kitchen/busser-bats/)
* [busser-serverspec](https://github.com/test-kitchen/busser-serverspec/)
* [kitchen-pester](https://github.com/test-kitchen/kitchen-pester/)
