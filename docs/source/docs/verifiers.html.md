---
title: "Verifiers"
---

Kitchen allows a user to choose from a variety of testing frameworks which it calls `verifiers`.


##### [busser](https://github.com/test-kitchen/busser)

Busser is the default verifier which uses "runner" plugins based on the file/folder structure `test/integration/SUITE/RUNNER` (relative to the .kitchen.yml).

###### [busser-serverspec](https://github.com/test-kitchen/busser-serverspec)

The Busser runner for ServerSpec, installs serverspec and specinfra gems locally
on the instance under test. A `Gemfile` can be used to control versions of gems
installed. Test files musts end in `*_spec.rb`

~~~
`-- test
    `-- integration
        `-- default
            `-- serverspec
                |-- Gemfile
                |-- localhost
                |   `-- httpd_spec.rb
                `-- spec_helper.rb

~~~

###### [busser-bats](https://github.com/test-kitchen/busser-bats)

The Busser runner for BATS, the bash automation

##### [kitchen-inspec](https://github.com/chef/kitchen-inspec)

The `kitchen-inspec` verifier is a sharp departure from busser in that InSpec code is (exclusively) executed on the host system against a node via SSH or WinRM.

##### [kitchen-verifer-serverspec](https://github.com/neillturner/kitchen-verifier-serverspec)

This community verifier forgoes busser, allowing both host execution like `kitchen-inspec` and node execution like `busser-serverspec`

~~~yaml
---
~~~
