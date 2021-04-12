---
title: DigitalOcean
menu:
  docs:
    parent: drivers
    weight: 15
---

kitchen-digitalocean is a Test Kitchen *driver* for DigitalOcean.

### Example **kitchen.yml**

```
---
driver:
  name: digitaloean

provisioner:
  name: chef_zero

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

### Setting Driver Configuration

The kitchen-digitalocean driver includes many configuration options that can be set globally in the driver section of your kitchen.yml config file or in each platform. Global settings apply to all platforms in the `kitchen.yml`, while platform level driver configuration is applied to only those platforms and override globally set configuration options.

**Example Global Driver Option**

```
driver:
  name: digitaloean
  some_config: true
```

**Example Platform Driver Option**

```
platforms:
  - name: ubuntu-20
    driver:
      some_config: true
```

### Driver Configuration Options

#### digitalocean_access_token

The `digitalocean_access_token` configuration option is used to communicate with the DigitalOcean API to provision the droplets for testing. You can also set this with the `DIGITALOCEAN_ACCESS_TOKEN` environmental variable before running Test Kitchen to avoid storing secres in your `kitchen.yml` config.

#### image

DigitalOcean features a number of images for creating Droplets that can be used by specifying the following image names:

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
---
driver:
  name: digitalocean

platforms:
  - name: ubuntu-20
```

#### Regions

By default your droplets will be built in the `nyc1` region, but you can change the default by updating the environment variable or setting the region configuration option. Using the env var is useful to allow teams with developers across different regions to test within their own geographic region without hard coding configs.

```bash
export DIGITALOCEAN_REGION="tor1"
```

This allows futher customization by allowing overrides at the `driver` level and the `platform` level.

```yaml
# DIGITALOCEAN_REGION="tor1" # set as an env var

# cookbook1/.kitchen.yml
---
driver:
  name: digitalocean
  region: sgp1

platforms:
  - name: ubuntu-16
  - name: ubuntu-18
    region: sfo1

# cookbook2/.kitchen.yml
---
driver:
  name: digitalocean

platforms:
  - name: ubuntu-16
  - name: ubuntu-18
    region: sfo1
```

The above configuration when full tested would create the following images in their respective regions.

##### Available Region Values

- `nyc1`: New York 1
- `sfo1`: San Francisco 1
- `ams2`: Amsterdam 2
- `sgp1`: Singapore 1
- `lon1`: London 1
- `nyc3`: New York 3
- `ams3`: Amsterdam 3
- `fra1`: Frankfurt 1
- `tor1`: Toronto 1
- `sfo2`: San Francisco 2
- `blr1`: Bangalore 1

#### Tags

To add tags to the droplet, provide the tags attribute.

```yaml
driver:
  tags:
    - test-kitchen
    - this-is-a-tag
```

#### Private Networking

Private networking is enabled by default, but will only work in certain regions. You can disable private networking by changing private_networking to
false. Example below.

```yaml
---
driver:
  - private_networking: false
```

#### IPv6

IPv6 is disabled by default, you can enable this if needed. IPv6 is only available in limited regions.

```yaml
---
driver:
  - ipv6: true
```

#### Monitoring

DigitalOcean provides a monitoring agent that you can optionally install to your
droplet.  To enable this feature, set the monitoring attribute to true.

```yaml
---
driver:
  - monitoring: true
```

#### Firewall

To create the droplet with firewalls, provide a pre-existing firewall ID as a
string or list of strings.

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

Note that your `firewalls` must be the numeric ids of your firewall. To get the
numeric ID, use something like to following command to get them from the digital
ocean API:

```bash
curl -X GET https://api.digitalocean.com/v2/firewalls -H "Authorization: Bearer $DIGITALOCEAN_ACCESS_TOKEN"
```

#### VPCS

To create the droplet with a VPC (Virtual Private Cloud), provide a pre-existing VPC ID as a
string.

```yaml
driver:
  vpcs:
    - 3a92ae2d-f1b7-4589-81b8-8ef144374453
```

Note that your `vpc_uuid` must be the numeric ids of your vpc. To get the
numeric ID, use something like the following command to get them from the digital
ocean API:

```bash
curl -X GET https://api.digitalocean.com/v2/vpcs -H "Authorization: Bearer $DIGITALOCEAN_ACCESS_TOKEN"
```
