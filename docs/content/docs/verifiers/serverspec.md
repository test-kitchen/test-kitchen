---
title: ServerSpec
slug: serverspec
menu:
  docs:
    parent: verifiers
    weight: 5
---

[ServerSpec](https://serverspec.org/) is a framework that gives you RSpec tests for your infrastructure. Test Kitchen's legacy busser verifier can use [busser-serverspec](https://github.com/test-kitchen/busser-serverspec) for executing ServerSpec tests.

Install `busser-serverspec` into the same Ruby environment that runs `kitchen`. When using the busser verifier, files can be placed in `test/integration/$SUITE/serverspec/`.

Example test to check that the httpd package is installed:

```ruby
describe package('httpd') do
  it { should be_installed }
end
```
