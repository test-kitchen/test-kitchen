---
title: SSH
menu:
  docs:
    parent: transports
    weight: 15
---

`ssh` is the default transport for all non-Windows hosts. For most users the default transport settings are sufficient and the transport section does not need to be defined in the `kitchen.yml` file.

## SSH Tranport Settings

### connection_retries

The jaximum number of times to retry after a failed attempt to open a connection. This defaults to `5`.

### connection_retry_sleep

The number of seconds to wait until attempting to make another connection after a failure. This defaults to `1`.

### max_wait_until_ready

The maximum number of attempts to determine if the test instance is ready to accept commands. This defaults to `600`.

### password

The password used for authenticating to the test instance.

### port

The port used to connect to the test instance. This defaults to `22`.

### username

The username used for authenticating to the test instance. This defaults to `root`. Some drivers may change this default.

### compression

Wether or not to use compression. The default is `false`.

### compression_level

This defaults to 6 if compression is `true`.

### connection_timeout

This defaults to `15` (seconds).

### keepalive

This defaults to `true`.

### keepalive_interval

This defaults to `60` (seconds).

### keepalive_maxcount

This defaults to `3`.

### max_ssh_sessions

Maximum number of parallel ssh sessions. This defaults to `9`.

### ssh_key

Path to an ssh key identity file.
