---
title: Dynamic Configuration
prev:
  text: "Adding a Platform"
  url: "adding-platform"
next:
  text: "Fixing Converge"
  url: "fixing-converge"
---

There are a few basic ways of dynamically configuring Test Kitchen:

* A local configuration will be looked for in `.kitchen.local.yml` which could be used for development purposes.  This is a file that is not typically checked into version control.
* A global configuration file will also be looked for in `$HOME/.kitchen/config.yml` to set preferred defaults for all your projects.
* Finally, each YAML file can contain ERB fragments, which you could use for selecting drivers, etc. based on which platform you're currently running, or based off environment variables.

For example, you could modify `.kitchen.yml` (or `.kitchen.local.yml`, or `$HOME/.kitchen/config.yml`) to look like:

~~~yaml
---
driver:
  name: openstack
  openstack_username: <%= ENV['YOUR_OPENSTACK_USERNAME'] %>
  openstack_api_key: <%= ENV['YOUR_OPENSTACK_API_KEY'] %>
  openstack_auth_url: <%= ENV['YOUR_OPENSTACK_AUTH_URL'] %>
  image_ref: <%= ENV['SERVER_IMAGE_ID'] %>
  flavor_ref: <%= ENV['SERVER_FLAVOR_ID'] %>
~~~

Keep in mind, this assumes you have an OpenStack deployment setup and ready to use. If this doesn't apply, let us continue.
