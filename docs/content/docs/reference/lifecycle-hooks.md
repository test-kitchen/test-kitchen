---
title: Lifecycle Hooks
menu:
  docs:
    parent: reference
    weight: 30
---

The life cycle hooks system allows running commands before, after, or always after any phase of Test Kitchen (`create`, `converge`, `verify`, or `destroy`). Commands can be run either locally on your workstation (the default) or remotely on the test instance.

These hooks are configured under a new `lifecycle:` section in `kitchen.yml`:

```yaml
lifecycle:
  pre_create: echo before
  post_create:
  - echo after
  - local: echo also after
  - remote: echo after but in the instance
  finally_create:
  - echo run regardless of failure in create
```

You can also configure hooks on a single platform or suite:

```yaml
platforms:
- name: ubuntu-24.04
  lifecycle:
    pre_converge:
    - remote: apt update

suites:
- name: default
  lifecycle:
    post_verify:
    - my_coverage_formatter
```

Local commands automatically get some environment variables with information about which instance the hook is evaluating against:

* `KITCHEN_INSTANCE_NAME` - The full name of the instance
* `KITCHEN_SUITE_NAME` - The name of the suite of the instance
* `KITCHEN_PLATFORM_NAME` - The name of the platform of the instance
* `KITCHEN_INSTANCE_HOSTNAME` - The hostname of the instance as reported by the driver plugin

For local commands, you can also pass additional configuration of `cwd:` to run in a folder relative to the test kitchen root and `environment:` to pass in additional variables:

```yaml
lifecycle:
  pre_converge:
  - local: ./setup.sh
    environment:
      API_KEY: asdf1234
    cwd: /my-test-folder
```

Remote commands are normally not allowed during `pre_create` or `post_destroy` hooks as there is generally no instance running at that point, but with `pre_destroy` hooks you may want to use the `skippable` flag so as to not fail during `kitchen test`:

```yaml
lifecycle:
  pre_destroy:
  - remote: myapp --unregister-license
    skippable: true
```

This is a complete example of using a post_create hook to wait for cloud-init to complete for an AWS EC2 instance:

```yaml
lifecycle:
  post_create:
  - local: echo 'Awaiting cloud-init completion'
  - remote: |
      declare i=0;
      declare wait=5;
      declare timeout=300;
      while true; do
        [ -f /var/lib/cloud/instance/boot-finished ] && break;
        if [ ${i} -ge ${timeout} ]; then
          echo "Timed out after ${i}s waiting for cloud-init to complete";
          exit 1;
        fi;
        echo "Waited ${i}/${timeout}s for cloud-init to complete, retrying in ${wait} seconds"
        sleep ${wait};
        let i+=${wait};
      done;
```

You can include or exclude platforms from specific lifecycle hooks with the `includes` or `excludes`
keys, e.g.

```yaml
lifecycle:
  post_create:
  - local: echo 'Awaiting cloud-init completion'
  - remote: |
      echo "This is my *nix"
    excludes:
      - windows-2012r2
      - windows-2016
  - remote: |
      Write-Host "This is my windows"
    excludes:
      - redhat-7
```
