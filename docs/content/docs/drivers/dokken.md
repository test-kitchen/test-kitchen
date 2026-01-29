---
title: Dokken (Docker)
menu:
  docs:
    parent: drivers
    weight: 15
---

kitchen-dokken is a Test Kitchen *plugin* for Docker that uses specially created Linux distribution Docker images and Chef Infra Docker images. Utilizing the Docker or Podman container engines instead of hypervisors or cloud providers allows for Chef Infra cookbook testing that can run on a local workstation or in CI pipelines without modification or extra costs.

Unlike all other Test Kitchen drivers, kitchen-dokken handles all the tasks of the driver, transport, and provisioner itself. This approach focuses purely on Chef Infra cookbook testing to provide ultra-fast testing times. Docker containers have a fast creation and start time, and kitchen-dokken uses the official Chef Infra Client containers instead of spending the time to download and install the Chef Infra Client packages. These design decisions result in tests that run in seconds instead of minutes and don't require high bandwidth Internet connections.

### Driver vs. Provisioner vs. Transport

Since kitchen-dokken combines driver, transport, and provisioner functionality into a single plugin, its configuration differs from other Test Kitchen drivers. kitchen-dokken includes specific configuration options that can be set in the driver, provisioner, or transport sections or in the individual platforms / suites. At a bare minimum to use kitchen-dokken you must specify dokken as the driver, provisioner, and transport sections of your `kitchen.yml` file:

```yaml
---
driver:
  name: dokken

provisioner:
  name: dokken

transport:
  name: dokken
```

### Driver Configuration Options

#### api_retries

The `api_retries` configuration option specifies the number of times Test Kitchen will retry communicating with the Docker daemon before exiting with a failure. This configuration option defaults to `20`.

```yaml
driver:
  name: dokken
  api_retries: 30
```

#### binds

The `binds` configuration option allows you bind mount a local path into your Test Kitchen containers.

```yaml
driver:
  name: dokken
  binds:
    - /some/local/path:/some/container/path
```

#### cap_add

The `cap_add` configuration option allows you to specify additional system capabilities to add to the container. See the [Docker Runtime Privilege and Linux Capabilities Documentation](https://docs.docker.com/engine/containers/run/#runtime-privilege-and-linux-capabilities) for a complete list of capabilities.

```yaml
driver:
  name: dokken
  cap_add:
    - NET_RAW
```

#### cap_drop

The `cap_drop` configuration option allows you to specify additional system capabilities to remove from the container. See the [Docker Runtime Privilege and Linux Capabilities Documentation](https://docs.docker.com/engine/reference/run/#runtime-privilege-and-linux-capabilities) for a complete list of capabilities.

```yaml
driver:
  name: dokken
  cap_drop:
    - AUDIT_WRITE
```

#### chef_image

The `chef_image` configuration option allows you to specify Docker image other than the official Chef Infra Client image. This can be used to specify the Cinc Docker image or internal customer builds of Chef Infra Client.

```yaml
driver:
  name: dokken
  chef_image: tas50/my_chef_fork
```

#### cgroupns_host

This configuration can be used to pass `--cgroupns=host` flag during the docker run, which can be beneficial in the following scenario.

Docker Desktop 4.3.0+ uses cgroupv2 which breaks containers that use `systemd`.
Containers that use `systemd` need to run with `--privileged --cgroupns=host -v /sys/fs/cgroup:/sys/fs/cgroup:rw`, which can be achieved with the following configuration.

```yaml
driver:
  name: dokken
  privileged: true
  cgroupns_host: true
  volumes:
    - /sys/fs/cgroup:/sys/fs/cgroup:rw
```

Reference: [4.3.0 Release notes](https://docs.docker.com/desktop/release-notes/#430)

#### chef_version

The `chef_version` configuration option allows you to specify which Docker image tag of the Chef Infra Client image to use. By default `latest` is used, which is equivalent to the latest version the Chef's `stable` channel. For a complete list of available tags see [chef/chef tags](https://hub.docker.com/r/chef/chef/tags) on Docker Hub.

```yaml
driver:
  name: dokken
  chef_image: 17 # the latest 17.x release
```

<!--
TODO: Investigate if this is something we need to even document

#### data_image

default: "dokken/kitchen-cache:latest"
-->

#### creds_file

The `creds_file` configuration options allows you to specify the location of a `json` file that contains the authentication credentials for the private docker registries.

```yaml
platforms:
  - name: almalinux-10
    driver:
      image: reg/almalinux-10
      creds_file: './creds.json'
```

The credentials file should contain all the necessary details that are required to authenticate the private registry. A sample credentials file is as follows.

```json
{
   "username": "org_username",
   "password": "password",
   "email": "email@org.com",
   "serveraddress": "https://registry.org.com/"
}
```

#### deprecations_as_errors

The `deprecations_as_errors` configuration option specifies that Test Kitchen should fail if any deprecations are encountered in Chef Infra cookbooks. This flag is useful when testing cookbooks in CI systems as it helps identify code that will later block upgrading Chef Infra Client.

```yaml
driver:
  name: dokken
  deprecations_as_errors: true
```

#### dns

The `dns` configuration option allows you to specify custom dns servers.

```yaml
driver:
  name: dokken
  dns:
    - 1.1.1.1
```

#### dns_search

The `dns_search` configuration option allows you to specify custom dns search domains.

```yaml
driver:
  name: dokken
  dns_search: example.com
```

#### docker_host_url

The `docker_host_url` configuration option allows you to specify a Docker daemon other than localhost.

```yaml
driver:
  name: dokken
  docker_host_url: tcp://10.0.1.49:2376
```

#### docker_registry

The `docker_registry` configuration option allows you to use Docker registries other than Docker Hub including Docker Hub mirrors or private registries. If using a private registry make sure that registry has the [Chef Infra image](https://hub.docker.com/r/chef/chef), any [dokken images](https://hub.docker.com/u/dokken) in your `kitchen.yml` file, as well as the [almalinux:10 image](https://hub.docker.com/_/almalinux) used during the converge process.

```yaml
driver:
  name: dokken
  docker_registry: docker.example.com
```

<!--#### entrypoint -->

#### env

Use the `env` configuration option to set environment variables in the Test Kitchen container.

```yaml
driver:
  name: dokken
  env:
    - SOME_VARIABLE=value
```

#### hostname

The `hostname` configuration allows you to set a custom hostname for the container. This configuration option can be used to set a hostname per suite to test clusters or client/server architectures. This is possible due to Docker's internal DNS resolution which allows each container on the internal `dokken` network to resolve the IP of one another. This configuration option defaults to `dokken`

```yaml
---
driver:
  name: dokken

provisioner:
  name: dokken

transport:
  name: dokken

platforms:
  - name: ubuntu-24.04
    driver:
      image: dokken/ubuntu-24.04

suites:
  - name: cluster-server-1
    driver:
      hostname: cluster-server-1
    run_list:
      - recipe[my_cookbook::default]
  - name: cluster-server-2
    driver:
      hostname: cluster-server-2
    run_list:
      - recipe[my_cookbook::default]
```

```shell
$ kitchen login cluster-server-1-ubuntu-2004

root@cluster-server-1:/# ping cluster-server-2
PING cluster-server-2 (172.18.0.3) 56(84) bytes of data.
64 bytes from de87305be1-cluster-server-2-ubuntu-2004.dokken (172.18.0.3): icmp_seq=1 ttl=64 time=0.138 ms
```

#### hostname_aliases

The `hostname_aliases` configuration option allows you to configure additional hostnames that will resolve to the container:

```yaml
  - name: cluster-server-1
    driver:
      hostname: cluster-server-1
      hostname_aliases:
        - also_this_hostname
```

#### image_prefix

The `image_prefix` configuration option allows you to add a prefix to the name of all containers generated by Test Kitchen. This can be helpful for avoiding conflicts when multiple Test Kitchen instances are running against the same Docker daemon.

```yaml
driver:
  name: dokken
  image_prefix: acme
```

#### intermediate_instructions

The `intermediate_instructions` configuration option allows you to define steps to run on the Test Kitchen container before you converge Chef Infra Client. This is very useful for updating package caches on operation systems like Debian/Ubuntu or other preparation tasks that you might need to run.

```yaml
platforms:
  - name: ubuntu
    driver:
      image: ubuntu:20.04
      intermediate_instructions:
        - RUN apt-get update
        - RUN apt-get -y install some_extra_package
      pid_one_command: /lib/systemd/systemd
```

#### ipv6

The `ipv6` configuration options enables IPv6 in the Docker daemon. This configuration option should be considered a global setting for all containers since dokken does not update the dokken network once it's been created. It is not recommend to use this configuration option within suites.

```yaml
driver:
  name: dokken
  ipv6: true
```

You can check to see if IPv6 is enabled on the dokken network by seeing if the following command returns true:

```shell
docker network inspect dokken --format='{{.EnableIPv6}}'
```

If the command returns false, we recommend you delete the network and allow dokken to recreate it with IPv6.

To allow IPv6 Docker networks to reach the internet IPv6 firewall rules must be set up. The simplest way to achieve this is to update Docker's /etc/docker/daemon.json to use the following settings. You will need to restart the docker daemon after making these changes.

```json
{
  "experimental": true,
  "ip6tables": true
}
```

Some containers require the ip6table_filter kernel module to be loaded on the host system or ip6tables will not function on the container. To check if the module is loaded use the command

```shell
sudo lsmod | grep ip6table_filter
```

If there is no output then the module is not loaded and should be loaded using the command

```shell
modprobe ip6table_filter
```

#### ipv6_subnet

The `ipv6_subnet` configuration option specifies the IPv6 subnet to run containers in. This configuration option requires that the `ipv6` configuration option be set true. Similar to the `ipv6` configuration option, this option should be considered global to all platform/suites since these network options aren't reset between suites.

```yaml
driver:
  name: dokken
  ipv6: true
  ipv6_subnet: "2001:db8:1::/64"  # "2001:db8::/32 Range reserved for documentation"
```

<!-- NOTE: links is not documented here as it's legacy in Docker and may be removed in a future release. -->
#### memory_limit

The `memory_limit` configuration option specifies the maximum amount of memory that a Test Kitchen container can consume. By default the memory limit of the containers you run is unbound (or limited by the Docker client on macOS).

```yaml
driver:
  name: dokken
  memory_limit: 2147483648 # 2GB
```
<!--
#### network_mode

default: "dokken" -->

#### pid_one_command

The `pid_one_command` configuration option sets the pid 1 command of the container being created. By default this is a simple loop command. For testing Chef Infra cookbooks that manage services you will need to set this to the init system binary.

```yaml
platforms:
  - name: ubuntu-24.04
    driver:
      image: dokken/ubuntu-24.04
      pid_one_command: /bin/systemd

  - name: almalinux-10
    driver:
      image: dokken/almalinux-10
      pid_one_command: /usr/lib/systemd/systemd
```

#### platform

This options can be used to specify which platform/architecture needs to be used. It allows users to specify either the following in a global config file

```yaml
---
driver:
  platform: linux/amd64
```

or the following under a specif platform.

```yaml
platforms:
  - name: ubuntu-24.04
    driver:
      image: dokken/ubuntu-24.04
      platform: linux/amd64
```

#### ports

The `ports` configuration option specifies ports on the local container to map back to the host running Test Kitchen. This is useful when testing web services so you can browse them locally on your workstation.

```yaml
suites:
  - name: my_webserver
    run_list:
      - recipe[my_cookbook::default]
    driver:
      ports:
        - 80 # map 80 on the container to 80 locally
        - 9000:8080 # map 8080 on the container to 9000 locally
        - 9001:8081/tcp # map TCP 8080 on the container to TCP 9000 locally
```

#### privileged

The `privileged` configuration option allows starting the container with extended Docker privileges. This is necessary when testing systemd services in Chef Infra cookbooks. By default this value is `false`.

```yaml
driver:
  name: dokken
  privileged: true
```

#### pull_chef_image

The `pull_chef_image` configuration option specifies if the Chef Infra docker image should be pulled or not.

```yaml
driver:
  name: dokken
  pull_chef_image: false
```

#### pull_platform_image

The `pull_platform_image` configuration option specifies if the Linux distro container should be pulled by Docker before each Test Kitchen converge. This option is set to `true` by default, but it may be useful to disable it in low bandwidth situations or if you are testing local platform containers that aren't yet pushed to Docker Hub.

```yaml
driver:
  name: dokken
  pull_platform_image: false
```

<!--
TODO: Document these
#### read_timeout

default: 3600

#### security_opt
-->

#### tmpfs

The `tmpfs` configuration option specifies tmpfs volumes to mount on the Test Kitchen container including the mount option for those volumes.

```yaml
driver:
  name: dokken
  tmpfs:
    /tmp: rw,noexec,nosuid,nodev,size=65536k
```

<!--
#### userns_host

default: false -->

#### volumes

The `volumes` configuration option specifies local volumes to mount into the Test Kitchen containers.

```yaml
driver:
  name: dokken
  volumes:
    - /mnt # mount the local /mnt directory to /mnt in the container
```

<!--
TODO: Document this
#### write_timeout

default: 3600 -->

### Provisioner Configuration Options

#### root_path

The `root_path` configuration option specifies the directory used by Chef Infra Client for storing cookbooks, remote file downloads, and other cached data. By default `/opt/kitchen` is used.

#### chef_binary

The `chef_binary` configuration option specifies the path to the Chef Infra Client binary. By default kitchen-dokken uses `/opt/chef/bin/chef-client`. If you'd like to test with Chef Infra Solo you may want to change this to `/opt/chef/bin/chef-solo`.

#### chef_options

The `chef_options` configuration option specifies a string of additional command line flags to pass to the Chef Infra Client. By default the `-z` flag for running in Local Mode is specified.

#### chef_log_level

The `chef_log_level` configuration option specifies the logging level used when running Chef Infra Client. By default this is set to `warn`. `info`, `debug`, or `trace` levels may also be specified.

#### chef_output_format

The `chef_output_format` configuration option specifies the output formatter used by Chef Infra Client when logging. By default this is set to `doc` for the documentation formatter. For less verbose output you may set this to `minimal`.

#### chef_license

The `chef_license` configuration option specified if the Chef Infra license should be automatically accepted in the Test Kitchen run. Valid values: `accept`, `accept-no-persist`, or `accept-silent`

```yaml
provisioner:
  chef_license: accept-no-persist
```

#### profile_ruby

The `profile_ruby` configuration option specifies enabling low level Ruby profiling of the Chef Infra Client when run by Test Kitchen. This flag is used by Chef Infra Client contributors for testing of the application itself. For testing performance of cookbooks see `slow_resource_report` instead.

#### slow_resource_report

The `slow_resource_report` configuration option specifies running Chef Infra Client with the slow resource report mode enabled. This functionality is available in Chef Infra Client 17.2 or later and provides timing information on the 10 slowest resources in your cookbooks.

```yaml
provisioner:
  slow_resource_report: true
```

<!--
TODO: Do we need to set this in both locations?
#### docker_host_url -->

#### clean_dokken_sandbox

<!-- TODO: rewrite this for the standard format -->
When Chef Infra Client converges kitchen-dokken populates /opt/kitchen/ with the Chef Infra Client and Test Kitchen data required to converge. By default this directory is cleared out at the end of every run. One of the subdirectories of /opt/kitchen/ is the chef cache directory. For cookbooks that download significant amounts of data from the network, i.e. many remote_file calls, this can make subsequent converges unnecessarily slow. If you would like the chef cache to be preserved between converges add clean_dokken_sandbox: false to the provisioner section of kitchen.yml. The default value is true.

```yaml
provisioner:
  name: dokken
  clean_dokken_sandbox: false
```

### Transport Configuration Options

<!--
TODO: Do we need to set this in both locations?
#### docker_host_url -->

<!-- #### host_ip_override

Allow connecting to any ip/hostname to support sibling containers -->

#### timeout

The `timeout` configuration option specifies the timeout in seconds for communicating with the Docker daemon.

### Dokken Linux Containers

Specially created containers for kitchen-dokken, build off official Linux distro images, but include all of the packages and services necessary to test Chef Infra cookbooks. These containers are produced for leading Linux distributions such as AlmaLinux, Amazon Linux, Fedora, OpenSUSE, and Ubuntu. For a complete list of available dokken specific container images see [u/dokken](https://hub.docker.com/u/dokken) on Docker Hub.

### Example **kitchen.yml**

```yaml
---
driver:
  name: dokken
  privileged: true  # allows systemd services to start

provisioner:
  name: dokken

transport:
  name: dokken

verifier:
  name: inspec

platforms:
  - name: ubuntu-24.04
    driver:
      image: dokken/ubuntu-24.04
      pid_one_command: /bin/systemd
      intermediate_instructions:
        - RUN /usr/bin/apt-get update

  - name: almalinux-10
    driver:
      image: dokken/almalinux-10
      pid_one_command: /usr/lib/systemd/systemd

suites:
  - name: default
    run_list:
      - recipe[my_cookbook::default]
    verifier:
      inspec_tests:
        - test/integration/default
```

## Using Kitchen Dokken with Podman

Using Dokken with podman is a little less straight forward than with Docker. The main problem is volumes are not populated when they are first created.

As per [this issue](https://github.com/test-kitchen/kitchen-dokken/issues/255), we can use lifecycle hooks to create the volume and populate it with the Chef executable before we try and start the main container.

*Note*, if you’re using a specific version of Chef, and not latest, then you need to reference the correct version in your podman create command because this breaks the automatic pulling of the correct version of the Chef Docker image by kitchen-dokken.

```yaml
---
driver:
  name: dokken
  privileged: true  # allows systemd services to start
provisioner:
  name: dokken
transport:
  name: dokken
verifier:
  name: inspec
platforms:
  - name: ubuntu-24.04
    driver:
      image: dokken/ubuntu-24.04
      pid_one_command: /bin/systemd
      intermediate_instructions:
        - RUN /usr/bin/apt-get update
  - name: almalinux-10
    driver:
      image: dokken/almalinux-10
      pid_one_command: /usr/lib/systemd/systemd
suites:
  - name: default
    run_list:
      - recipe[test_linux::default]
    verifier:
      inspec_tests:
        - test/integration/default
    lifecycle:
      pre_create:
        - podman create --name chef-latest --replace docker.io/chef/chef:latest sh
        - podman start chef-latest
      post_destroy:
        - podman volume prune -f
```
