---
title: OpenStack
menu:
  docs:
    parent: drivers
    weight: 15
---

kitchen-openstack is a Test Kitchen *driver* for OpenStack.

## Minimum Configuration

```yaml
driver:
  name: openstack
  openstack_username: [YOUR OPENSTACK USERNAME]
  openstack_api_key: [YOUR OPENSTACK API KEY] # AKA your OpenStack Password
  openstack_auth_url: [YOUR OPENSTACK AUTH URL] # if you are using v3, API_URL/v3/auth/tokens
  openstack_domain_id: [default is 'default'; otherwise YOUR OPENSTACK DOMAIN ID]
  image_ref: [SERVER IMAGE ID]
  flavor_ref: [SERVER FLAVOR ID]
transport:
  username: ubuntu # For a Ubuntu Box
```

The `image_ref` and `flavor_ref` options can be specified as an exact id,
an exact name, or as a regular expression matching the name of the image or flavor.

All of Fog's `openstack` options (`openstack_domain_name`, `openstack_project_name`,
...) are supported. This includes support for the OpenStack Identity v3 API.

## General Configuration

### name

**Required** Tell test-kitchen what driver to use. ;)

### openstack_username

**Required** Your OpenStack username.

### openstack_api_key

**Required** Your OpenStack API Key, aka your OpenStack password.

### openstack_auth_url

**Required** Your OpenStack auth url. If you are using ID v3, you'll need to use `API_URL/v3/auth/tokens`.

### require_chef_omnibus

**Required** Set to `true` otherwise the specific version of Chef omnibus you want installed.

### image_ref

**image_ref or image_id required** Server Image Name or ID.

### image_id

**image_ref or image_id required** Server Image ID.  Specifying the ID instead of reference results in a faster create time.

**Note** If the image UUID changes this value will need to be updated.

### flavor_ref

**flavor_ref or flavor_id required** Server Flavor Name or ID.

### flavor_id

**flavor_ref or flavor_id required** Specifying the ID instead of reference results in a faster create time.

**Note** If the flavor UUID changes this value will need to be updated.

### server_name

If a `server_name_prefix` is specified then this prefix will be used when
generating random names of the form `<NAME PREFIX>-<RANDOM STRING>` e.g.
`myproject-asdfghjk`. If both `server_name_prefix` and `server_name` are
specified then the `server_name` takes precedence.

### server_name_prefix

If you want to have a static prefix for a random server name.

### port

Set the SSH port for the remote access.

### openstack_tenant

Your OpenStack tenant id.

### openstack_region

Your OpenStack region id.

### availability_zone

Your OpenStack availability zone.

### openstack_service_name

Your OpenStack compute service name.

### openstack_network_name

Your OpenStack network name used to connect to, if you have only private network
connections you want declare this.

### glance_cache_wait_timeout

When OpenStack downloads the image into cache, it takes extra time to provision.  Timeout controls maximum amount of time to wait for machine to move from the Build/Spawn phase to Active.

### connect_timeout

Connect timeout controls maximum amount of time to wait for machine to respond to ssh login request.

### read_timeout

### write_timeout

Expose read/write timeout parameters passed down to HTTP connection created via [excon](https://github.com/excon/excon). Default timeouts (from excon) are 60 seconds.

### server_wait

`server_wait` is a workaround to deal with how some VMs with `cloud-init`.
Some clouds need this some, most OpenStack instances don't. This is a stop gap
wait makes sure that the machine is in a good state to work with. Ideally the
transport layer in Test-Kitchen will have a more intelligent way to deal with this.
There will be a dot that appears every 10 seconds as the timer counts down.
You may want to add this for **WinRM** instances due to the multiple restarts that
happen on creation and boot. A good default is `300` seconds to make sure it's
in a good state.

The default is `0`.

### security_groups

A list of `security_groups` to join:

```yaml
security_groups:
   - [A LIST OF...]
   - [...SECURITY GROUPS TO JOIN]
   ```

### user_data

If your VMs have `cloud-init` enabled you can use the `user_data` in your
kitchen.yml to inject commands at boot time.

```yaml
    driver_config:
      user_data: userdata.txt
```

Then create a `userdata.txt` in the same directory as your .kitchen.yml,
for example:

```shell
#!/bin/sh
echo "do whatever you want to pre-configure your machine"
```

### cloud_config

If your VMs have `cloud-init` enabled you can use `cloud_config` to generate userdata for use by cloud-init in the [cloud-config format](https://cloudinit.readthedocs.io/en/latest/topics/format.html#cloud-config-data). This provides a convenient way to specify cloud-init config inline. As the cloud-config format uses YAML the resulting userdata is essentially a copy+paste of `cloud_config` with the header line '#cloud-config'

```yaml
    driver_config:
      cloud_config:
        hostname: my-hostname
```

This will pass the following user data to OpenStack:

```text
#cloud-config
hostname: my-hostname
```

The `cloud_config` and `user_data` options are mutually exclusive.

### config_drive

If your VMs require config drive.

```yaml
    config_drive: true
```

### network_ref

**Deprecated** A list of network names to create instances with.

```yaml
network_ref:
   - [OPENSTACK NETWORK NAMES]
   - [CREATE INSTANCE WITH]
```

### network_id

A list of network ids to create instances with.  Specifying the id instead of reference results in a faster create time.

**Note** If the network UUID changes this value will need to be updated.

```yaml
network_ref:
   - [OPENSTACK NETWORK UUIDs]
   - [TO CREATE INSTANCE WITH]
```

### no_ssh_tcp_check

**Deprecated** You should be using transport now. This will skip the ssh check to automatically connect.

The default is `false`.

### no_ssh_tcp_check_sleep

**Deprecated** You should be using transport now. This will sleep for so many seconds. `no_ssh_tcp_check` needs
to be set to `true`.

### private_key_path

**Deprecated** You should be using transport now. The guest image should use `cloud-init` or some other method to fetch key from meta-data service.

### public_key_path

**Deprecated** You should be using transport now. The guest image should use `cloud-init` or some other method to fetch key from meta-data service.

## Disk Configuration

### block_device_mapping

#### make_volume

Makes a new volume when set to `true`.

The default is `false`.

#### snapshot_id

When set, will make a volume from that snapshot id.

#### volume_id

When set, will attach the volume id.

#### device_name

Set this to `vda` unless you really know what you are doing.

#### availability_zone

The block storage availability zone.

The default is `nova`.

#### volume_type

The volume type, this is optional.

#### delete_on_termination

This will delete the volume on the instance when `destroy` happens, if set to true.
Otherwise set this to `false`.

#### creation_timeout

Timeout to wait for volume to become available.  If a large volume is provisioned, it might take time to provision it on the backend.  Maximum amount of time to wait for volume to be created and be available.

#### attach_timeout

If using a customized version of Openstack such a VMWare Integrated OPenstack (VIO), it may mark a volume active even though it is still performing some actions which may cause test kitchen to attach the volume to early which results in errors. Specify in seconds the amount of time to delay attaching the volume after its been marked active. Default timeout is 0.

#### Example

```yaml
block_device_mapping:
  make_volume: true
  snapshot_id: 00000-111111-0000222-000
  device_name: vda
  availability_zone: nova
  delete_on_termination: false
  creation_timeout: 120
  attach_timeout: 240
```

## Network and Communication Configuration

### floating_ip

A specific `floating_ip` can be provided to bind a floating IP to the node.
Any floating IP will be the IP used for Test Kitchen's Remote calls to the node.

### floating_ip_pool

A `floating_ip_pool` can be provided to allocate a floating IP from
the pool to the instance. If `allocate_floating_ip` is true, the IP will be allocated,
otherwise the first free floating IP will be used.  It will be the IP used for
Test Kitchen's Remote calls to the node. If allocated, the floating IP will be
released once the instance is destroyed.

### allocate_floating_ip

If true, allocate a new IP from the specified `floating_ip_pool` and release is afterwards.
Otherwise, if false (the default), an existing allocated IP.

### \[public\|private\]_ip_order

In some complex network scenarios you can have several IP addresses designated
as public or private. Use `public_ip_order` or `private_ip_order` to control
which one to use for further SSH connection. Default is 0 (first one)

For example if you have openstack istance that has network with several IPs assigned like

```text
+--------------------------------------+------------+--------+------------+-------------+----------------------------------+
| ID                                   | Name       | Status | Task State | Power State | Networks                         |
+--------------------------------------+------------+--------+------------+-------------+----------------------------------+
| 31c98de4-026f-4d12-b03f-a8a35c6e730b | kitchen    | ACTIVE | None       | Running     | test=10.0.0.1, 10.0.1.1   |

```

to use second `10.0.1.1` IP address you need to specify

```yaml
  private_ip_order: 1
```

assuming that test network is configured as private.

### use_ipv6

If true use IPv6 addresses to for SSH connections. If false, the default, use
IPv4 addresses for SSH connections.

### network_ref

The `network_ref` option can be specified as an exact id, an exact name,
or as a regular expression matching the name of the network. You can pass one

```yaml
  network_ref: MYNET1
```

or many networks

```yaml
network_ref:
  - MYNET1
  - MYNET2
```

The `openstack_network_name` is used to select IP address for SSH connection.
It's recommended to specify this option in case of multiple networks used for
instance to provide more control over network connectivity.

Please note that `network_ref` relies on Network Services (`Fog::Network`) and
it can be unavailable in your OpenStack installation.

### disable_ssl_validation

```yaml
  disable_ssl_validation: true
```

Only disable SSL cert validation if you absolutely know what you are doing,
but are stuck with an OpenStack deployment without valid SSL certs.

## Example **kitchen.yml**

```yaml
---
driver:
  name: openstack
  openstack_username: [YOUR OPENSTACK USERNAME]
  openstack_api_key: [YOUR OPENSTACK API KEY] # AKA your OPENSTACK PASSWORD
  openstack_auth_url: [YOUR OPENSTACK AUTH URL]
  openstack_domain_id: [default is 'default'; otherwise YOUR OPENSTACK DOMAIN ID]
  require_chef_omnibus: [e.g. 'true' or a version number if you need Chef]
  image_ref: [SERVER IMAGE ID]
  flavor_ref: [SERVER FLAVOR ID]
  key_name: [KEY NAME]
  read_timeout: 180
  write_timeout: 180
  connect_timeout: 180

provisioner:
  name: chef_infra

verifier:
  name: inspec

transport:
  ssh_key: /path/to/id_rsa #Path to private key that matches the above openstack key_name
  connection_timeout: 10
  connection_retries: 5
  username: ubuntu
  password: mysecreatpassword

platforms:
  - name: ubuntu-24.04
  - name: almalinux-10
    transport:
      username: almauser
  - name: windows-2022
    transport:
      password: myadministratorpassword

suites:
  - name: default
    run_list:
      - recipe[my_cookbook::default]
    attributes:
```
