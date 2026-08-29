---
title: Apache CloudStack
menu:
  docs:
    identifier: driver-cloudstack
    parent: drivers
    weight: 15
---

kitchen-cloudstack is a Test Kitchen *driver* for [Apache CloudStack](https://cloudstack.apache.org/) and Citrix CloudPlatform. It deploys and destroys CloudStack virtual machines so you can test your cookbooks and infrastructure code against them.

### Requirements

- An Apache CloudStack or Citrix CloudPlatform deployment
- API credentials: an API key, a secret key, and the API URL
- Test Kitchen 3.0 or newer
- `cloudstack_client`, installed automatically as a dependency

### Installation

```bash
gem install kitchen-cloudstack
```

Or, for a project-local bundle:

```ruby
# Gemfile
source "https://rubygems.org"

gem "test-kitchen"
gem "kitchen-cloudstack"
```

### Authentication

The driver needs three values, which you can find in the CloudStack UI under your account's API keys:

```yaml
driver:
  name: cloudstack
  cloudstack_api_key: <%= ENV['CLOUDSTACK_API_KEY'] %>
  cloudstack_secret_key: <%= ENV['CLOUDSTACK_SECRET_KEY'] %>
  cloudstack_api_url: https://cloudstack.example.com/client/api
```

{{% warning %}}
Keep the keys out of `kitchen.yml` by reading them from the environment as shown above.
{{% /warning %}}

### Quick start

```yaml
---
driver:
  name: cloudstack
  cloudstack_api_key: <%= ENV['CLOUDSTACK_API_KEY'] %>
  cloudstack_secret_key: <%= ENV['CLOUDSTACK_SECRET_KEY'] %>
  cloudstack_api_url: https://cloudstack.example.com/client/api

provisioner:
  name: chef_infra

platforms:
  - name: ubuntu-22.04
    driver:
      cloudstack_template_id: 8a4e1c1f-1234-4b8b-9c2f-77b6c9f0e111
      cloudstack_serviceoffering_id: b1d2f3a4-5678-4c9d-8e1f-99a7b6c5d4e3
      cloudstack_zone_id: c2e3f4b5-9012-4d0e-9f2a-11b3c5d7e9f1

suites:
  - name: default
    run_list:
      - recipe[my_cookbook::default]
```

Template, service offering, and zone are usually set per platform, since they are what differs between operating systems. Everything else usually belongs in the top-level `driver:` block.

### Setting Driver Configuration

Options can be set under the top-level `driver:` key, or per platform under `platforms[].driver:`.

#### Credentials

| Option | Default | Description |
| ---- | ---- | ---- |
| `cloudstack_api_key` | *(none)* | CloudStack API key. **Required.** |
| `cloudstack_secret_key` | *(none)* | CloudStack secret key. **Required.** |
| `cloudstack_api_url` | *(none)* | Full URL of the CloudStack API endpoint. **Required.** |
| `disable_ssl_validation` | `false` | Skip TLS certificate validation. Only use this against a deployment with an invalid certificate, and only if you understand the risk. |

#### Instance

| Option | Default | Description |
| ---- | ---- | ---- |
| `cloudstack_template_id` | *(none)* | ID of the template (OS image) to deploy. **Required**, normally set per platform. |
| `cloudstack_serviceoffering_id` | *(none)* | ID of the service offering, which determines CPU and memory. **Required**, normally set per platform. |
| `cloudstack_zone_id` | *(none)* | ID of the zone to deploy into. **Required**, normally set per platform. |
| `cloudstack_project_id` | *(unset)* | ID of a project to deploy the VM into. |
| `cloudstack_affinity_group_id` | *(unset)* | ID of an affinity group, for pinning to a dedicated cluster. |
| `cloudstack_expunge` | `false` | Expunge the VM on destroy rather than leaving it in the Destroyed state. |

#### Custom service offering sizing

These apply only when the service offering itself does not specify CPU or memory.

| Option | Default | Description |
| ---- | ---- | ---- |
| `cloudstack_serviceoffering_cpu` | *from offering* | Number of CPUs. |
| `cloudstack_serviceoffering_cpuspeed` | *from offering* | Speed of each CPU, in MHz. |
| `cloudstack_serviceoffering_memory` | *from offering* | Memory, in MB. |

#### Disk

| Option | Default | Description |
| ---- | ---- | ---- |
| `cloudstack_diskoffering_id` | *(unset)* | ID of a disk offering to attach a data disk from. |
| `cloudstack_diskoffering_size` | *from offering* | Size of the data disk in GB, for a custom disk offering. |

#### Networking

| Option | Default | Description |
| ---- | ---- | ---- |
| `cloudstack_network_id` | *(unset)* | Network ID, for isolated or VPC networks. |
| `cloudstack_security_group_id` | *(unset)* | Security group ID, for shared networks. |
| `associate_public_ip` | `false` | Acquire a public IP and set up static NAT automatically. |
| `cloudstack_vm_public_ip` | *(unset)* | Public IP to connect to, when you configure advanced networking and static NAT yourself. |
| `cloudstack_create_firewall_rule` | `false` | Create a firewall rule opening the transport's port to the public IP. |
| `cloudstack_firewall_cidr` | `0.0.0.0/0` | Source range the firewall rule allows. |

{{% warning %}}
`cloudstack_firewall_cidr` defaults to `0.0.0.0/0`, which opens the port to the entire internet. Narrow it to your own network.
{{% /warning %}}

#### SSH and access

| Option | Default | Description |
| ---- | ---- | ---- |
| `username` | *transport default* | User to connect as. |
| `port` | *transport default* | Port to connect on. |
| `password` | *generated by CloudStack* | Password to connect with. |
| `cloudstack_ssh_keypair_name` | *(unset)* | Name of a CloudStack SSH keypair to deploy with. |
| `keypair_search_directory` | *(see below)* | Extra directory to search for the keypair's `.pem` file. |
| `cloudstack_sync_time` | `0` | Seconds to wait before connecting, to let `cloud-set-guest-password` or `cloud-set-guest-sshkey` finish. |

#### Naming

| Option | Default | Description |
| ---- | ---- | ---- |
| `server_name` | *generated* | Display name of the VM in CloudStack. |
| `host_name` | *generated* | Hostname set on the VM itself. Useful when long generated hostnames cause `ENAMETOOLONG` errors during a converge. |

#### Other

| Option | Default | Description |
| ---- | ---- | ---- |
| `cloudstack_userdata` | *(unset)* | User data passed to the VM. Must be a double-quoted string, so escapes such as `\n` are interpreted. |
| `cloudstack_job_poll_interval` | `10` | Seconds between checks on a running CloudStack job. |
| `cloudstack_job_timeout` | `600` | Seconds to wait for a CloudStack job before giving up. |

### SSH keypairs

To use a CloudStack SSH keypair, set `cloudstack_ssh_keypair_name` and make the matching **private** key available as a `.pem` file. The driver looks for a file named after the keypair with a `.pem` suffix — a keypair called `TestKey` needs `TestKey.pem` — in these locations:

1. the directory given by `keypair_search_directory`, specified without a trailing slash
2. the directory containing your `kitchen.yml`
3. your home directory (`~`)
4. your `~/.ssh` directory

```yaml
driver:
  name: cloudstack
  cloudstack_ssh_keypair_name: TestKey
  keypair_search_directory: /home/me/cloudstack-keys
```

{{% info %}}
This file must be the **private** key, not the public key.
{{% /info %}}

### Windows instances

Set the transport to WinRM and the driver follows it. Port forwarding and firewall rules use the transport's port (5985, or 5986 for SSL) instead of SSH's 22, and the password CloudStack generates for a password-enabled Windows template is handed to WinRM automatically:

```yaml
driver:
  name: cloudstack
  cloudstack_api_key: <%= ENV['CLOUDSTACK_API_KEY'] %>
  cloudstack_secret_key: <%= ENV['CLOUDSTACK_SECRET_KEY'] %>
  cloudstack_api_url: https://cloudstack.example.com/client/api
  associate_public_ip: true
  cloudstack_create_firewall_rule: true

transport:
  name: winrm

platforms:
  - name: windows-2022
    driver:
      cloudstack_template_id: <windows template id>
      cloudstack_serviceoffering_id: <offering id>
      cloudstack_zone_id: <zone id>
```

The template must have password management enabled so CloudStack can set and report the administrator password, and WinRM must be listening in the image.

### Checking instance state

[`kitchen list`](/docs/commands/list) asks the driver whether each instance is still alive, and this driver answers from CloudStack rather than guessing, so an instance destroyed out from under Test Kitchen is reported accurately.

### Examples

#### User data

The value must be double-quoted so the escape sequences are interpreted:

```yaml
driver:
  name: cloudstack
  cloudstack_userdata: "#cloud-config\npackages:\n - htop\n"
```

#### Advanced networking with an automatic public IP

```yaml
driver:
  name: cloudstack
  cloudstack_network_id: d3f4a5b6-3456-4e1f-8a2b-33c5d7e9f1a2
  associate_public_ip: true
  cloudstack_create_firewall_rule: true
```

#### Static NAT configured by hand

```yaml
driver:
  name: cloudstack
  cloudstack_network_id: d3f4a5b6-3456-4e1f-8a2b-33c5d7e9f1a2
  cloudstack_vm_public_ip: 203.0.113.25
```

#### Shared network with a security group

```yaml
driver:
  name: cloudstack
  cloudstack_security_group_id: e4a5b6c7-7890-4f2a-9b3c-44d6e8f0a2b3
```

#### A custom-sized service offering

```yaml
driver:
  name: cloudstack
  cloudstack_serviceoffering_id: f5b6c7d8-1234-4a3b-8c4d-55e7f9a1b3c4
  cloudstack_serviceoffering_cpu: 4
  cloudstack_serviceoffering_cpuspeed: 2000
  cloudstack_serviceoffering_memory: 8192
  cloudstack_diskoffering_id: a6c7d8e9-5678-4b4c-9d5e-66f8a0b2c4d5
  cloudstack_diskoffering_size: 100
```

#### Cleaning up fully

```yaml
driver:
  name: cloudstack
  cloudstack_expunge: true
```

### Troubleshooting

**`NameError: uninitialized constant Kitchen::Driver::SSHBase`.** You are running kitchen-cloudstack 0.24.0 or older, which was built on a class Test Kitchen removed in 4.0. Upgrade to 1.0.0 or newer.

**A CloudStack job times out.** Deploys on a busy or large template can exceed the ten minute default. Raise `cloudstack_job_timeout`.

**WinRM never becomes ready.** Check that the template has password management enabled, that WinRM is listening in the image, and — if you are forwarding a public IP — that `cloudstack_create_firewall_rule` is set so the WinRM port is actually open.

**Login fails immediately after the VM boots.** CloudStack's `cloud-set-guest-password` and `cloud-set-guest-sshkey` scripts may not have run yet. Increase `cloudstack_sync_time`.

**Converge fails with `ENAMETOOLONG`.** The generated hostname is too long for the run. Set `host_name` to something short.
