---
title: DigitalOcean
menu:
  docs:
    parent: drivers
    weight: 15
---

kitchen-digitalocean is a Test Kitchen *driver* for DigitalOcean that runs against the DigitalOcean V2 API.

### Setting Driver Configuration

The DigitalOcean driver for Test Kitchen includes many configuration options that can be set globally in the driver section of your kitchen.yml config file or within each platform configuration. Global settings apply to all platforms in the `kitchen.yml`, while platform level driver configuration is applied to only those platforms and override globally set configuration options. Even if you use platform level configuration options, it's a good idea to specify the driver you use to use globally.

#### Example Global Driver Option

This configuration sets the driver to `digitalocean` and then sets the `some_config` configuration to true.

```yaml
driver:
  name: digitaloean
  some_config: true
```

#### Example Platform Driver Option

This configuration sets the driver to `digitalocean` globally and then sets the `some_config` configuration to true for just `ubuntu-20`.

```yaml
driver:
  name: digitaloean

platforms:
  - name: ubuntu-20
    driver:
      some_config: true
```

### Driver Configuration Options

#### digitalocean_access_token

The `digitalocean_access_token` configuration option is used to communicate with the DigitalOcean API to provision the droplets for testing. You can also set this with the `DIGITALOCEAN_ACCESS_TOKEN` environmental variable before running Test Kitchen to avoid storing secrets in your `kitchen.yml` config.

#### ssh_key_ids

The `ssh_key_ids` configuration option is used to control the ssh key pair to assign to the Droplets when they are created. You can also set this with the `DIGITALOCEAN_SSH_KEY_IDS` environmental variable before running Test Kitchen to avoid storing secrets in your `kitchen.yml` config.

Note that your `SSH_KEY_ID` must be the numeric id of your ssh key, not the symbolic name. To get the numeric ID of your keys, use something like the following command to get them from the digital ocean API:

```bash
curl -X GET https://api.digitalocean.com/v2/account/keys -H "Authorization: Bearer $DIGITALOCEAN_ACCESS_TOKEN"
```

#### server_name

The `server_name` configuration option allows you to specify the hostname of the Droplet. By default, the hostname is set to the combination of base name, username, hostname, random string as well as separators.

For example to set the hostname provide the server_name attribute

```yaml
driver:
  server_name: my_server
```

#### image

The `image` configuration option allows you to control the operating system of the Droplet. DigitalOcean features many different images for creating Droplets that can be used by specifying the following image names:

- centos-7
- centos-8
- debian-9
- debian-10
- fedora-32
- fedora-33
- freebsd-11
- freebsd-12
- rancheros
- ubuntu-16
- ubuntu-18
- ubuntu-20

For example to build a system using Ubuntu 20.04:

```yaml
platforms:
  - name: my_system
    image: ubuntu-20
```

If the `image` configuration option is not specified Test Kitchen will attempt to use the platform name value for the image instead:

```yaml
platforms:
  - name: ubuntu-20
```

#### size

The `size` configuration option allows you to specify the Droplet size. By default all instances are created as `s-1vcpu-1gb` which is a single CPU with 1GB RAM and 25GB of disk. For a current list of Droplet sizes and their API name see [slugs.do-api.dev](https://slugs.do-api.dev/).

#### region

The `size` configuration option allows you to control the region where the Droplet is configured. By default your droplets will be built in the `nyc1` region. This configuration option can be set with the configuration option or by setting the `DIGITALOCEAN_REGION` env var. The env var is useful to allow teams with developers across different regions to test within their own geographic region without hard coding configs.

```bash
export DIGITALOCEAN_REGION="tor1"
```

This allows further customization by allowing overrides at the `driver` level and the `platform` level.

```yaml
# DIGITALOCEAN_REGION="tor1" # set as an env var

# cookbook1/.kitchen.yml
---
driver:
  name: digitalocean
  region: sgp1

platforms:
  - name: ubuntu-18
  - name: ubuntu-20
    region: sfo1

# cookbook2/.kitchen.yml
---
driver:
  name: digitalocean

platforms:
  - name: ubuntu-18
  - name: ubuntu-20
    region: sfo1
```

The above configuration when fully tested would create the following images in their respective regions.

##### Available Region Values

- `ams2`: Amsterdam 2
- `ams3`: Amsterdam 3
- `blr1`: Bangalore 1
- `fra1`: Frankfurt 1
- `lon1`: London 1
- `nyc1`: New York 1
- `nyc3`: New York 3
- `sfo1`: San Francisco 1
- `sfo2`: San Francisco 2
- `sfo3`: San Francisco 2
- `sgp1`: Singapore 1
- `tor1`: Toronto 1

For the most up-to-date list of regions supported by DigitalOcean see Regions at [slugs.do-api.dev](https://slugs.do-api.dev/)

#### tags

To add tags to the droplet, provide the tags attribute.

```yaml
driver:
  tags:
    - test-kitchen
    - this-is-a-tag
```

#### private_networking

Private networking is enabled by default, but will only work in certain regions. You can disable private networking by changing private_networking to false. Example below.

```yaml
driver:
  - private_networking: false
```

#### ipv6

IPv6 is disabled by default, you can enable this if needed. IPv6 is only available in limited regions.

```yaml
driver:
  - ipv6: true
```

#### monitoring

DigitalOcean provides a monitoring agent that you can optionally install on your droplet.  To enable this feature, set the monitoring attribute to true.

```yaml
driver:
  - monitoring: true
```

#### firewalls

To create the droplet with firewalls, provide a pre-existing firewall ID as a string or list of strings.

```yaml
driver:
  firewalls:
    - 7a489167-a3d5-4d93-9f4a-371bd02ea8a3
    - 624c1408-f101-4b59-af64-99c7f7560f7a
```

or

```yaml
driver:
  firewalls: 624c1408-f101-4b59-af64-99c7f7560f7a
```

Note that your `firewalls` must be the numeric ids of your firewall. To get the numeric ID, use something like to the following command to get them from the DigitalOcean API:

```bash
curl -X GET https://api.digitalocean.com/v2/firewalls -H "Authorization: Bearer $DIGITALOCEAN_ACCESS_TOKEN"
```

#### vpcs

To create the droplet with a VPC (Virtual Private Cloud), provide a pre-existing VPC ID as a string.

```yaml
driver:
  vpcs:
    - 3a92ae2d-f1b7-4589-81b8-8ef144374453
```

Note that your `vpc_uuid` must be the numeric ids of your vpc. To get the numeric ID, use something like the following command to get them from the DigitalOcean API:

```bash
curl -X GET https://api.digitalocean.com/v2/vpcs -H "Authorization: Bearer $DIGITALOCEAN_ACCESS_TOKEN"
```

### Example **kitchen.yml**

```yaml
---
driver:
  name: digitalocean

provisioner:
  name: chef_infra

verifier:
  name: inspec

platforms:
  - name: ubuntu-20
  - name: ubuntu-18
    region: sfo1
    driver:
      tags:
        - test-kitchen-instance
      monitoring: true # disabled by default
      vpcs:
        - 3a92ae2d-f1b7-4589-81b8-8ef144374453
      ipv6: true # disabled by default
      private_networking: false # enabled by default

suites:
  - name: default
    run_list:
      - recipe[my_cookbook::default]
    attributes:
```
