---
title: Configuration
---

Configuration
=============

The .kitchen.yml
----------------
Test Kitchen uses a special configuration file at the root of your project that tells Test Kitchen how and what to test. By default, Test Kitchen will assume this file is named `.kitchen.yml` (note the preceeding dot), but this is configurable via an environment variable.

The specific order of the Test Kitchen configuration options does not matter, but these docs will use the default ordering generated from the `kitchen init` command.

Each block of configuration in YAML is called a "stanza". For more information on YAML and the YAML syntax, please see [the official YAML documentation](http://yaml.org/).


#### Settings
The settings stanza defines any top-level configuration settings and options. These options are read by Test Kitchen core, various drivers, plugins, and bussers. The configuration stanza begins with the `settings` key. Each configuration option is then listed as a key-value pair indented below. For example:

```yaml
settings:
  parallel: true
  destroy: never
```

- `parallel` - [`true|false`]: Whether to run `kitchen` commands in parallel
- `destroy` - [`passing|always|never`]: Strategy for destroying instances after testing completes

#### Driver Configuration
The next stanza defines the driver configuration. For more information about how drivers work and the driver framework, please see the [Test Kitchen Drivers documentation](/docs/drivers).

```yaml
driver_plugin: vagrant
driver_config:
  option: value
```

- `driver_plugin` - [`String`]: The name of the driver to use
- `driver_config` - [`Hash`]: A key-value list of configuration options for the driver (varies depending on the driver)


#### Platforms
The platforms stanza defines the list of platforms to test. Each driver must have a unique name, but the additional configurations are driver-dependent. For example, the [`kitchen-vagrant`](https://github.com/opscode/kitchen-vagrant) driver permits specifying a `box_url` and `box_name` and the [`kitchen-ec2`](https://github.com/opscode/kitchen-ec2) permits specifying an `image_id` and `availability_zone`. Each platform must be nested under the `platforms` key in the `.kitchen.yml`.

```yaml
platforms:
  - name: ubuntu-12.04
    option: value
```

- `platforms` - [`Array`]: The list of platforms to test
- Driver-specific configuration options

Additional platforms may be listed in the YAML array format:

```yaml
platforms:
  - name: ubuntu-12.04
  - name: centos-6.4
```

#### Suites
The suites stanza defines the cookbooks to test. Each suite must have a unique `name` and `run_list`.

```yaml
# Execute the default recipe of the myface cookbook with
# node['myface']['option'] = 'value'
suites:
  - name: default
    run_list:
      - recipe[myface::default]
    attributes:
      myface:
        option: value
```

You can exclude a specific list of platforms using the `excludes` keyword inside a suites stanza. The name of the platform to include must correspond to the name of the platform in the `platforms` stanza.

```yaml
# Don't run the default suite on the ubuntu-12.04 platform
suites:
  - name: default
    excludes:
      - ubuntu-12.04
```

You can also include (exclusively) a specific list of platforms using the `includes` keyword inside a suites stanza. The name of the platform to include must correspond to the name of the platform in the `platforms` stanza. **Specifying the `includes` directive will _exclude_ any other platforms!**

```yaml
# Exclusively run the default suite on the ubuntu-12.04 platform
suites:
  - name: default
    includes:
      - centos-6.4
```


Multiple Configuration Files
----------------------------
Given the number of different configuration options, some of which contain sensitive information such as access keys and login information, Test Kitchen automatically merges its configuration with a `.kitchen.local.yml` file if one is present. You can add any sensitive information, such as passwords or personally-identifiable-information, to the `.kitchen.local.yml` and then add any common information to the `.kitchen.yml`. **The `.kitchen.local.yml` should _never_ be committed into source control!**

You can specify the path to an alternative `.kitchen.yml` by setting the `KITCHEN_YAML` environment variable at runtime:

```bash
$ KITCHEN_YAML=/custom/path.yml kitchen test
```

Please note, this file's configuration content is still merged with the `.kitchen.local.yml` if it exists.


Global Configuration
--------------------
Test Kitchen also reads a `.kitchen/config.yml` file at the root of your home directory if one is present. This is a great place to specify personal configuration settings that are common to all projects (similar to a global `.gitignore` or `chefignore`):

```yaml
# ~/.kitchen/config.yml

settings:
  parallel: true
```
