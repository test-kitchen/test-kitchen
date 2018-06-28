This file holds "in progress" release notes for the current release under development.

## Life Cycle Hooks

The life cycle hooks system allows running commands before or after any phase
of Test Kitchen (`create`, `converge`, `verify`, or `destroy`). Commands can be
run either locally on your workstation (the default) or remotely on the test instance.

These hooks are configured under a new `lifecycle:` section in `kitchen.yml`:

```yaml
lifecycle:
  pre_create: echo before
  post_create:
  - echo after
  - local: echo also after
  - remote: echo after but in the instance
```

You can also configure hooks on a single platform or suite:

```yaml
platforms:
- name: ubuntu-18.04
  lifecycle:
    pre_converge:
    - remote: apt update

suites:
- name: default
  lifecycle:
    post_verify:
    - my_coverage_formatter
```
