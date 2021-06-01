---
title: SSH
menu:
  docs:
    parent: transports
    weight: 15
---

`ssh` is the default transport for all non-Windows hosts. For most users the default tranport settings are sufficient and the transport section does not need to be defined in the `kitchen.yml` file.

## SSH Tranport Settings

### connection_retries

Maximum number of times to retry after a failed attempt to open a connection. The default is `5`.

### connection_retry_sleep

The number of seconds to wait until attempting to make another connection after a failure.

### max_wait_until_ready

The maximum number of attempts to determine if the test instance is ready to accept commands. This defaults to `600`.

### password

The password used for authenticating to the test instance.

### port

The port used to connect to the test instance. This defaults to `22`.

### username

The username used for authenticating to the test instance. This defaults to `root`. Some drivers may change this default.

### compression

Wether or not to use compression. The default is ### .

### compression_level

The default is 6 if compression is ### .

### connection_timeout

Defaults to ### .

### keepalive

Defaults to ### .

###  keepalive_interval

Defaults to ### .

### max_ssh_sessions

Maximum number of parallel ssh sessions.

### ssh_key

Path to an ssh key identity file.
