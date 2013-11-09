---
title: Bussers
---

Bussers
=======

Busser is a test setup and execution framework designed to work on remote nodes whose system dependencies cannot be relied upon, except for an Omnibus installation of Chef. It uses a plugin architecture to add support for different testing strategies such RSpec, MiniTest, Cucumber, BATS, etc.


Foo
---
By default, Test Kitchen will look in the test/integration directory for your test files. Inside there will be a folder, inside the folder a busser, and inside the busser, the tests:

```text
test/integration
  \_ [SUITE]
    \_ [BUSSER]
      \_ [TEST]
```

For example, using "default" suite, using the "serverspec" busser would have the following file organization:

```text
test/integration
  \_ default
    \_ serverspec
      \_ something_spec.rb
```


Authoring
---------
Test Kitchen bussers are distributed as Rubygems. As a semantic, they are prefixed with "busser" (like "busser-bats").
