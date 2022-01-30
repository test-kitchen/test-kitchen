---
title: Fixture Cookbooks
menu:
  docs:
    parent: reference
    weight: 20
---

Cookbooks, especially ones that provide resources exclusively, often utilize what are known as "fixture cookbooks". These are cookbooks and recipes included expressly for the purpose of testing.

Fixture cookbooks are most often made available via a Berksfile:

```
source 'https://supermarket.chef.io'

metadata

group :integration do
  cookbook 'test_cookbook', path: './test/cookbooks/test_cookbook'
end
```

This will make the cookbook available and it can be called via `run_list`:

```
suites:
- name: default
  run_list:
    - recipe[test_cookbook::default]
```

Working examples can be found in many of the chef-cookbooks, like the [openldap cookbook](https://github.com/sous-chefs/openldap/tree/main/test/cookbooks/openldap-test)
