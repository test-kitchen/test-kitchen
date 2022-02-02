---
title: SSH
menu:
  docs:
    parent: transports
    weight: 15
---

`ssh` is the default transport for all non-Windows hosts. The default transport settings are sufficient for most users, and the transport section does not need to be defined in the `kitchen.yml` file.

## SSH Transport Settings

### General Settings

#### port

The port used to connect to the test instance. This defaults to `22`.

#### ssh_key

Path to an ssh key identity file.

#### username

The username used for authenticating to the test instance. This defaults to `root`. Some drivers may change this default.

#### password

The password used for authenticating to the test instance.

#### compression

Whether or not to use compression. The default is `false`.

#### compression_level

This defaults to `6` if compression is `true`.

#### max_ssh_sessions

Maximum number of parallel ssh sessions. This defaults to `9`.

### Retry and Timeout Settings

#### connection_retries

The maximum number of times to retry after a failed attempt to open a connection. This defaults to `5`.

#### connection_retry_sleep

The number of seconds to wait until attempting to make another connection after a failure. This defaults to `1`.

#### max_wait_until_ready

The maximum number of attempts to determine if the test instance is ready to accept commands. This defaults to `600`.

#### connection_timeout

The number of seconds attempting to connect before timing out. This defaults to `15`.

#### keepalive

Send keepalive messages to keep the SSH connection open. This defaults to `true`.

#### keepalive_interval

The number of seconds to wait after receiving data before sending a keepalive message. This defaults to `60`.

#### keepalive_maxcount

The maximum number of keepalive messages to be sent without a response. This defaults to `3`.

### Proxy Settings

#### ssh_http_proxy

The address of a HTTP proxy to use for the SSH connection. This has no default value.

#### ssh_http_proxy_port

The port of the HTTP proxy to use for the SSH connection. This has no default value.

#### ssh_http_proxy_user

The username for the HTTP proxy to use for the SSH connection. This has no default value.

#### ssh_http_proxy_password

The password for the HTTP proxy to use for the SSH connection. This has no default value.
