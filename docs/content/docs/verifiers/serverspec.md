---
title: ServerSpec
slug: serverspec
menu:
  docs:
    parent: verifiers
    weight: 5
---

[ServerSpec](https://serverspec.org/) is a framework that gives you RSpec tests for your infrastructure. Test Kitchen's busser plugin utilizes [busser-serverspec](https://github.com/test-kitchen/busser-serverspec) for executing ServerSpec tests.

Files can be placed in `test/integration/$SUITE/serverspec/` and no configuration is required in the user's `.kitchen.yml`.

Example test to check that the httpd package is installed:

```
describe package('httpd') do
  it { should be_installed }
end
```
