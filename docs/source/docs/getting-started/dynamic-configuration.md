---
title: Dynamic Configuration
prev:
  text: "Adding a Platform"
  url: "adding-platform"
next:
  text: "Fixing Converge"
  url: "fixing-converge"
---

There are a few basic ways of dynamically configuring test-kitchen:

The YAML file can contain `<% erb %>`, which you could use for selecting drivers, etc. based on which platform your currently running, or based of environment variables.

Test-kitchen well also look for a `.kitchen.local.yml` which could be used for development purposes.  This is a file that's not typically checked into version control.

Test Kitchen allows a "global" configuration file that you can drop off to set preferred defaults in ~/.kitchen/config.yml. That, along with allowing ERB, should provide plenty of customizability.


We're going to add some erb to our config by opening `.kitchen.yml` in your editor of choice so that it looks similar to:

~~~yaml
---
<% if ENV['KITCHEN_ENV'] == 'development' %>
driver:
  name: vagrant

provisioner:
  name: chef_solo
<% elsif ENV['KITCHEN_ENV'] == 'test' %>
driver:
  name: openstack
  openstack_username: <%= ENV['YOUR_OPENSTACK_USERNAME'] %>
  openstack_api_key: <%= ENV['YOUR_OPENSTACK_API_KEY'] %>
  openstack_auth_url: <%= ENV['YOUR_OPENSTACK_AUTH_URL'] %>
  image_ref: <%= ENV['SERVER_IMAGE_ID'] %>
  flavor_ref: <%= ENV['SERVER_FLAVOR_ID'] %>
provisioner:
  name: chef_zero
<% end %>

platforms:
  - name: ubuntu-12.04
  - name: ubuntu-10.04
  - name: centos-6.4

suites:
  - name: default
    run_list:
      - recipe[git::default]
    attributes:
  - name: server
    run_list:
      - recipe[git::server]
    attributes:
~~~
