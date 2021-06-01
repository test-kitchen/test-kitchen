---
title: InSpec
slug: inspec
menu:
  docs:
    parent: verifiers
    weight: 5
---

[InSpec](https://www.inspec.io/) framework for testing and auditing your applications and infrastructure. It can be utilized for validating test-kitchen instance via the [kitchen-inspec plugin](https://github.com/inspec/kitchen-inspec).

To enable kitchen-inspec in your `kitchen.yml`:

```
verifier:
  name: inspec
```

Example test to check that the httpd package is installed:

```
describe package('httpd') do
  it { should be_installed }
end
```

The plugin requires no configuration by default and expects tests exist as per:

```
.
├── Berksfile
├── Gemfile
├── README.md
├── metadata.rb
├── recipes
│   ├── default.rb
│   └── nginx.rb
└── test
    └── integration
        └── default
            └── web_spec.rb
```

More configuration options can be found in the project's [README](https://github.com/inspec/kitchen-inspec/blob/master/README.md)
