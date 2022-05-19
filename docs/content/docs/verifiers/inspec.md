---
title: InSpec
slug: inspec
menu:
  docs:
    parent: verifiers
    weight: 5
---

[InSpec](https://community.chef.io/tools/chef-inspec) framework for testing and auditing your applications and infrastructure. It can be utilized for validating Test Kitchen instances via the [kitchen-inspec plugin](https://github.com/inspec/kitchen-inspec).

To enable kitchen-inspec in your `kitchen.yml`:

```yaml
verifier:
  name: inspec
```

Example test to check that the httpd package is installed:

```ruby
describe package('httpd') do
  it { should be_installed }
end
```

The plugin requires no configuration by default and expects tests exist as per:

```yaml
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
