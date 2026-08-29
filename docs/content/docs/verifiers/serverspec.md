---
title: ServerSpec
slug: serverspec
menu:
  docs:
    identifier: verifier-serverspec
    parent: verifiers
    weight: 5
---

[ServerSpec](https://serverspec.org/) gives you RSpec tests for your infrastructure. Test Kitchen's legacy `busser` verifier runs them through the [busser-serverspec](https://github.com/test-kitchen/busser-serverspec) plugin.

Busser installs ServerSpec on the machine under test the first time a suite runs, then executes the suite's `serverspec` directory against it. Because the tests run on the machine itself, they use ServerSpec's `exec` backend rather than SSH.

{{% warning %}}
**busser-serverspec has been archived.** No active maintainers have come forward in the past five years. For new work, use [InSpec](/docs/verifiers/inspec) or [Cinc Auditor](/docs/verifiers/cinc-auditor), which are configured directly in `kitchen.yml` and need no Busser layer. [kitchen-verifier-shell](https://github.com/higanworks/kitchen-verifier-shell) with ServerSpec covers similar ground if you specifically need ServerSpec.
{{% /warning %}}

### Requirements

Ruby 3.2 or newer, and busser 0.9.0 or newer.

### Installation

Select the Busser verifier in your `kitchen.yml`:

```yaml
verifier:
  name: busser
```

Busser installs the plugin for you when the suite runs. To install it by hand:

```bash
busser plugin install busser-serverspec
```

### Directory layout

Put your specs in a subdirectory of the suite's `serverspec` directory:

```text
test
`-- integration
    `-- default              # suite name
        `-- serverspec
            |-- Gemfile          # optional
            |-- spec_helper.rb
            `-- localhost
                `-- httpd_spec.rb
```

Specs are collected recursively as `**/*_spec.rb`, so any depth works; the `localhost/` directory is convention, not a requirement. The suite directory is added to the load path and set as RSpec's default path, so `require "spec_helper"` works without a relative path.

{{% info %}}
The directory name `serverspec` is what selects this plugin. There is nothing else to configure.
{{% /info %}}

### Writing a test

```ruby
require "spec_helper"

describe package('httpd') do
  it { should be_installed }
end

describe command("echo hello") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should eq "hello\n" }
end
```

### Backend

The tests run on the machine under test, after Test Kitchen has logged in, so the `exec` backend is the right one:

```ruby
require "serverspec"
set :backend, :exec
```

{{% warning %}}
Do not use `set :backend, :ssh`. That would have ServerSpec connect back out over the network from a machine that is already the target.
{{% /warning %}}

### Pinning the ServerSpec version

A `Gemfile` in the suite directory is `bundle install`ed before the run:

```ruby
source "https://rubygems.org"

gem "serverspec", "~> 2.43"
```

Without one, the plugin installs ServerSpec 2.43 or newer.

### When nothing runs

If the suite files do not match what this plugin looks for, the run prints one line and **exits `0`** — no tests ran, and nothing said so:

```text
-----> Running serverspec test suite
```

This is the most common problem with this verifier, and because it exits zero, CI reports success. Work through these in order:

1. **Is the directory named `serverspec`?** That name alone selects this plugin. `serverspecs/`, `tests/`, or anything else is not picked up.
2. **Do the filenames match?** Only `*_spec.rb` is run, searched recursively. Note the underscore — `default-spec.rb` is **not** picked up.
3. **Is the plugin installed?** `busser plugin list` shows what is available.
4. **Is `BUSSER_ROOT` what you think?** `busser suite path` prints where suites are actually being looked for.

{{% tip %}}
A green `kitchen verify` that finishes suspiciously fast is the signal. Add a deliberately failing test once to confirm your suite is actually being executed.
{{% /tip %}}
