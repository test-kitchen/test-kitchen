---
title: VMware vRealize Automation
menu:
  docs:
    parent: drivers
    weight: 15
---

kitchen-vra is a Test Kitchen driver for vRealize Automation that runs against the VMware vRealize Automation  [V8.x] API.

## Usage

After installing the gem as described above, edit your .kitchen.yml file to set the driver to 'vra' and supply your login credentials:

```yaml
driver:
  name: vra
  username: myuser@corp.local
  password: mypassword
  tenant: mytenant
  base_url: https://vra.corp.local
  verify_ssl: true
```

If you want username and password to be prompted, remove usename and password in your .kitchen.yml as shown below:

```yaml
driver:
  name: vra
  tenant: mytenant
  base_url: https://vra.corp.local
  verify_ssl: true
```
If you don't want to explicitly specify username and password in the kitchen.yml, you have an option to set it in the environment variable as

    $ export VRA_USER_NAME='myuser@corp.local'
    $ export VRA_USER_PASSWORD='mypassword'

Example **kitchen.yml**:

```yaml
driver:
  name: vra
  username: myuser@corp.local
  password: <%= ENV['VRA_USER_PASSWORD'] %>
  tenant: bedford.progress.com
  project_id: xxxxx-xxxxxxxx
  base_url: https://lxmarpvra8-01.bedford.progress.com
  verify_ssl: false
  image_mapping: VRA-nc-lnx-ce8.4-Docker
  flavor_mapping: Small
  version: 1

provisioner:
  name: chef_zero

platforms:
  - name: chef-progress
    driver:
      catalog_id: 97aac381-327d-3b5c-ad93-e18fc855045e
      extra_parameters:
        hardware-config:
          type: string
          value: Small

suites:
  - name: default
    run_list:
      - recipe[my_cookbook::default]
```

 * **image_mapping**:  specifies the OS image for a machine and the flavor_mapping specifies the CPU count and RAM of the machine.
 * **flavor_mapping**: flavor mapping groups a set of target deployment sizings for a specific cloud account/region.

Other options that you can set include:

 * **request_timeout**: amount of time, in seconds, to wait for a vRA request to complete. Default is 600 seconds.
 * **server_ready_retries**: Number of times to retry the "waiting for server to be ready" check. In some cases, this will error out immediately due to DNS propagation issues, etc. Setting this to a number greater than 0 will retry the `wait_until_ready` method with a growing sleep in between each attempt. Defaults to 1. Set to 0 to disable any retrying of the `wait_until_ready` method.
 * **private_key_path**: path to the SSH private key to use when logging in. Defaults to '~/.ssh/id_rsa' or '~/.ssh/id_dsa', preferring the RSA key. Only applies to instances where SSH transport is used; i.e., does not apply to Windows hosts with the WinRM transport configured.
 * **use_dns**: Defaults to `false`.  Set to `true` if vRA doesn't manage vm ip addresses.  This will cause kitchen to attempt to connect via hostname.
 * **dns_suffix**: Defaults to `nil`.  Set to your domain suffix, for example 'mydomain.com'.  This only takes effect when `use_dns` == true and is appended to the hostname returned by vRA.
 * **extra_parameters**: a hash of other data to set on a catalog request, most notably custom properties. Allows updates to existing properties on the blueprint as well as the addition of new properties. Each key in the hash is the property name, and the value is a another hash containing the value data type and the value itself. It is possible to use a `~` to add nested parameters.
