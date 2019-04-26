# Test Kitchen 2.2 Release Notes

This release adds the ability to accept the license for Chef Client 15 and later within Test Kitchen. This works in the following ways:
  - Set the CHEF_LICENSE environment variable
  - Set the 'chef_license' attribute in the kitchen.yml under the provisioner
  - If these are not set and the license has not been previously accepted an interactive prompt will occur asking the user to accept.

# Test Kitchen 2.1 Release Notes

This support adds the gem ed25519 gem for native ed25519 SSH key support.

# Test Kitchen 2.0 Release Notes

Test Kitchen 2.0 is primarily a code cleanup release, but as it does remove functionality that a limited number of users may have depended upon, we have chosen to release this as a new major version. We believe that nearly all users will experience no change with this new version, but this release allows us to remove a good amount of legacy logic that will make Test Kitchen a bit faster and certainly easier to maintain going forward.

### Breaking Changes

- Support for the Chef Librarian depsolver has been removed. Users should utilize either Berkshelf or Policyfiles instead.
- The Chef Solo provisioner no longer supports Chef 10.
- The Chef-Zero provisioner no longer supports Chef versions prior to 11.8.

### Updated SSH Support

Test Kitchen has been updated to support net-ssh 5, which allows for new SSH key formats. Thanks [@Val](https://github.com/Val) for this fix.

### Other Improvements

- Improvements to log messages better convey what Test Kitchen is actually doing and how to resolve problems
- The `kitchen init` command now generates a `kitchen.yml` with an Ubuntu 18.04 system

# Test Kitchen 1.24.0 Release Notes

## Improved error messages

Test Kitchen now provides improved error messages when it cannot find a driver, provisioner, transport, or verifier. It will now output a message listing the plugins that it does know about, which may help users who have simply typed a name in a `kitchen.yml` file

# Test Kitchen 1.23.0 Release Notes

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

Local commands automatically get some environment variables with information
about which instance the hook is evaluating against:

* `KITCHEN_INSTANCE_NAME` - The full name of the instance
* `KITCHEN_SUITE_NAME` - The name of the suite of the instance
* `KITCHEN_PLATFORM_NAME` - The name of the platform of the instance
* `KITCHEN_INSTANCE_HOSTNAME` - The hostname of the instance as reported by the driver plugin

You can also pass additional configuration for local commands:

```yaml
lifecycle:
  pre_converge:
  - local: ./setup.sh
    environment:
      API_KEY: asdf1234
    timeout: 60
```

Remote commands are normally not allowed during `pre_create` or `post_destroy`
hooks as there is generally no instance running at that point, but with `pre_destroy`
hooks you may want to use the `skippable` flag so as to not fail during `kitchen test`:

```yaml
lifecycle:
  pre_destroy:
  - remote: myapp --unregister-license
    skippable: true
```

# Test Kitchen 1.21.0 Release Notes

## Configuration UX improvements

Having the kitchen configuration file be hidden has always been a bit odd and so we're moving to using `kitchen.yml` over `.kitchen.yml`.
This also applies to `kitchen.local.yml` and we've made the change backwards compatible so you're not forced to move over right away. Additionally, we've added support for the environment variables `KITCHEN_YML` and `KITCHEN_LOCAL_YML` again preserving compatibility if you're using the `*_YAML` forms.

# Test Kitchen 1.20.0 Release Notes

## Multiple paths for data_bags

Allows a user to use data_bags from an array of directories

```
data_bags_path:
  - 'data_bags'
  - 'test/integrations/data_bags'
```

## Deprecation Warnings for Configuration Keys

```
$ kitchen list default-centos-7
$$$$$$ Deprecated configuration detected:
require_chef_omnibus
Run 'kitchen doctor' for details.
```

```
$ kitchen doctor
$$$$$$ Deprecated configuration detected:
require_chef_omnibus
Run 'kitchen doctor' for details.

-----> The doctor is in
       **** require_chef_omnibus deprecated
The 'require_chef_omnibus' attribute with version values will change
to use the new 'product_version' attribute.

Note: 'product_name' must be set in order to use 'product_version'
until 'product_name' replaces 'require_chef_omnibus' as the default.

# New Usage #
provisioner:
  product_name: <chef or chefdk>
  product_version: 12.0.3
```

## SSH via an HTTP Proxy

This allows configuring the SSH transport to utilize an HTTP Proxy. The following configuration keys have been added to `transport`:

```
ssh_http_proxy_user
ssh_http_proxy_password
ssh_http_proxy_port
ssh_http_proxy
```

# Test Kitchen 1.20.0 Release Notes

## Driver Commands Removed

The `kitchen driver` family of commands have been removed. It was not recommended
to use them and it was judged to be more harm than good to leave them in. If you
regularly create new drivers and relied on the skeleton generator, check out
other code skeleton projects like [`chef generate`](https://blog.chef.io/2014/12/09/guest-post-creating-your-own-chef-cookbook-generator/),
and [Cookiecutter](https://github.com/audreyr/cookiecutter).

## `kitchen converge -D`

When you want to get debug logging for your provisioner or verifier, you can now
use the new `-D` (or `--debug`) command line option for `kitchen converge`,
`kitchen verify`, and `kitchen test`. Support has been added to the Chef provisioners,
avoiding the need to use the `log_level: debug` configuration option every time.

## `exec` Driver

A new driver named `exec` is included with Test Kitchen which runs all the
provisioning and verification commands locally, rather than on a VM. This can
be used for testing on systems where you've already created the VM yourself and
installed Test Kitchen on it. Note that this is related but different from the
included `proxy` driver, which also connects to an existing server, but over
SSH/WinRM rather than running commands locally.

## `shell` Provisioner `command`

Previously the included `shell` provisioner allowed running a user-specified bootstrap
script. This has been extended to allow specifying a `command` option with a
string to run, rather than managing a script file.

## Faster Busser

The `busser` verifier has been improved to be faster on the second (or beyond)
verification, or in other cases where the required gems are already present.

## `kitchen doctor`

A `kitchen doctor` command has been added, modeled on Homebrew's `brew doctor`.
This currently doesn't do much, but if you are a Kitchen plugin author, consider
adding more detailed debugging checks and troubleshooting help to your plugin
via this system.
