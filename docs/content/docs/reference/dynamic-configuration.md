---
title: Dynamic Configuration
menu:
  docs:
    parent: reference
    weight: 5
---
##### Dynamic Configuration

There are a few basic ways of dynamically configuring Kitchen:

* A local configuration will be looked for in `.kitchen.local.yml` which could be used for development purposes.  This is a file that is not typically checked into version control.
* A global configuration file will also be looked for in `$HOME/.kitchen/config.yml` to set preferred defaults for all your projects.
* Each YAML file can contain ERB fragments, which you could use for selecting drivers, etc. based on which platform you're currently running, or based off environment variables.
* Finally, Kitchen also has several environment variables where you can set a path to a `.kitchen.yml` or `$HOME/.kitchen/config.yml` file. This can be useful if you wish to use Kitchen with a continuous integration (CI) system.

To specify a path to a global `config.yml`, project or local `.kitchen.yml` file, set the following environment variables:

~~~
export KITCHEN_GLOBAL_YAML=/path/to/your/global/config.yml
export KITCHEN_YAML=/path/to/your/project/.kitchen.yml
export KITCHEN_LOCAL_YAML=/path/to/your/local/.kitchen.local.yml
~~~

**Note:** If `$HOME/.kitchen/config.yml` is present, kitchen will merge this file with your project's `.kitchen.yml`, and/or `.kitchen.local.yml` file. Merge precedence is:

1. `.kitchen.local.yml`
2. `.kitchen.yml`
3. `$HOME/.kitchen/config.yml`

For example, one could modify `.kitchen.yml` (or `.kitchen.local.yml`, or `$HOME/.kitchen/config.yml`) to look like:

~~~
---
driver:
  name: openstack
  openstack_username: <%= ENV['YOUR_OPENSTACK_USERNAME'] %>
  openstack_api_key: <%= ENV['YOUR_OPENSTACK_API_KEY'] %>
  openstack_auth_url: <%= ENV['YOUR_OPENSTACK_AUTH_URL'] %>
  image_ref: <%= ENV['SERVER_IMAGE_ID'] %>
  flavor_ref: <%= ENV['SERVER_FLAVOR_ID'] %>
~~~

Keep in mind, this assumes you have an OpenStack deployment setup and ready to use. This is only an example so to illustrate using environment variables via ERB snippets in the configuration file.

Another handy use of the ERB fragments is to dynamically override the log_level of
the provisioner.  Since Kitchen 1.7.0 the log level for the provisioner is now independent of the Kitchen log level.  Using the following snippet, allows the environment to override the provisioner log level without modifying the config file.:

~~~
---
provisioner:
  name: chef_zero
  log_level: <%= ENV['CHEF_LOG_LEVEL'] || "auto" %>
~~~
