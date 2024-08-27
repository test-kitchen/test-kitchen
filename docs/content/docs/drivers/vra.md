---
title: VMware vRealize Automation
menu:
  docs:
    parent: drivers
    weight: 15
---

kitchen-vra is a Test Kitchen driver for vRealize Automation that runs against the VMware vRealize Automation  [V8.x] API.

### Setting Driver Configuration

The VMware vra driver for Test Kitchen includes many configuration options that can be set globally in the driver section of your kitchen.yml config file or within each platform configuration. Global settings apply to all platforms in the `kitchen.yml`, while platform level driver configuration is applied to only those platforms and override globally set configuration options. Even if you use platform level configuration options, it's a good idea to specify the driver you use to use globally.

#### Example Global Driver Option

This configuration sets the driver to `vra` and then sets the `some_config` configuration to true.

```yaml
driver:
  name: vra
  some_config: true
```

#### Example Platform Driver Option

This configuration sets the driver to `vra` globally and then sets the `some_config` configuration to true for just `ubuntu-20`.

```yaml
driver:
  name: vra

platforms:
  - name: ubuntu-20
    driver:
      some_config: true
```

### Driver Configuration Options

#### Specifying login credentials

Edit your .kitchen.yml file to set the driver to 'vra' and supply your login credentials:

```yaml
driver:
  name: vra
  username: myuser@corp.local
  password: mypassword
  domain: domain.corp.com
  base_url: https://vra.corp.local
  verify_ssl: true
```

If you want username and password to be prompted, remove usename and password in your .kitchen.yml as shown below:

```yaml
driver:
  name: vra
  domain: domain.corp.com
  base_url: https://vra.corp.local
  verify_ssl: true
```

If you don't want to explicitly specify username and password in the kitchen.yml, you have an option to set it in the environment variable as

```shell
  export VRA_USER_NAME='myuser@corp.local'
  export VRA_USER_PASSWORD='mypassword'
```

The `domain` attribute is required, which you can utilize to specify which domain should be used to authenticate the users.

#### project_id

id of the project

#### image_mapping

specifies the OS image for a VM

#### flavor_mapping

specifies the CPU count and RAM of the machine

#### version

You can specify or skip providing a version. If version is not provided the latest version will be fetched automatically and used.

#### catalog_id , catalog_name

Either a catalog_id or a catalog_name is required for each platform. If both catalog_id and catalog_name are mentioned in .kitchen.yml then catalog_name would be used to derive the catalog_id and this catalog_id would override the catalog_id being passed in .kitchen.yml. In the below example as can be seen we are using catalog_id for centos6 driver while catalog_name for the centos7 driver just to demonstrate that we can use either of the two.

```yaml
platforms:
  - name: centos6
    driver:
      catalog_id: e9db1084-d1c6-4c1f-8e3c-eb8f3dc574f9
      project_id: 6ba69375-79d5-42c3-a099-7d32739f71a9
      image_mapping: SQL 2016
      flavor_mapping: Small
      version: 1
  - name: centos7
    driver:
      catalog_name: my_catalog_name
      project_id: 6ba69375-79d5-42c3-a099-7d32739f71a9
      image_mapping: VRA-nc-lnx-ce8.4-Docker
      flavor_mapping: Small
```

#### request_timeout

amount of time, in seconds, to wait for a vRA request to complete. Default is 600 seconds.

#### server_ready_retries

Number of times to retry the "waiting for server to be ready" check. In some cases, this will error out immediately due to DNS propagation issues, etc. Setting this to a number greater than 0 will retry the `wait_until_ready` method with a growing sleep in between each attempt. Defaults to 1. Set to 0 to disable any retrying of the `wait_until_ready` method.

#### private_key_path

path to the SSH private key to use when logging in. Defaults to '~/.ssh/id_rsa' or '~/.ssh/id_dsa', preferring the RSA key. Only applies to instances where SSH transport is used; i.e., does not apply to Windows hosts with the WinRM transport configured.

#### use_dns

Defaults to `false`.  Set to `true` if vRA doesn't manage vm ip addresses.  This will cause kitchen to attempt to connect via hostname.

#### dns_suffix

Defaults to `nil`.  Set to your domain suffix, for example 'mydomain.com'.  This only takes effect when `use_dns` == true and is appended to the hostname returned by vRA.

#### extra_parameters

a hash of other data to set on a catalog request, most notably custom properties. Allows updates to existing properties on the blueprint as well as the addition of new properties. Each key in the hash is the property name, and the value is a another hash containing the value data type and the value itself. It is possible to use a `~` to add nested parameters.


Example **kitchen.yml**:

```yaml
driver:
  name: vra
  username: myuser@corp.local
  password: <%= ENV['VRA_USER_PASSWORD'] %>
  domain: domain.corp.com
  project_id: xxxxx-xxxxxxxx
  base_url: https://example.com
  verify_ssl: false
  image_mapping: VRA-nc-lnx-ce8.4-Docker
  flavor_mapping: Small
  version: 1

provisioner:
  name: chef_infra

platforms:
  - name: centos
    driver:
      catalog_id: 97aac381-327d-3b5c-ad93-e18fc855045e
      extra_parameters:
        mycustompropname:
          type: string
          value: largevalue
        Vrm.DataCenter.Location:
          type: string
          value: Prod

suites:
  - name: default
    run_list:
      - recipe[my_cookbook::default]
```
