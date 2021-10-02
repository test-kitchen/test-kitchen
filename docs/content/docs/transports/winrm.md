---
title: WinRM
menu:
  docs:
    parent: transports
    weight: 15
---

`winrm` is the default transport for all Windows hosts. For most users the default transport settings are sufficient and the transport section does not need to be defined in the `kitchen.yml` file.

## WinRM Transport Settings

### connection_retries

Maximum number of times to retry after a failed attempt to open a connection. The default is `5`.

### connection_retry_sleep

The number of seconds to wait until attempting to make another connection after a failure.

### max_wait_until_ready

The maximum number of attempts to determine if the test instance is ready to accept commands. This defaults to `600`.

### password

The password used for authenticating to the test instance.

### port

The port used to connect to the test instance. This defaults `5985` when using `http` or `5986` when using `https`.

### username

The username used for authenticating to the test instance. This defaults to `administrator`. Some drivers may change this default.

### client_cert

The path to a local client certificate used as the CA for authentication in lieue of a username and password. Client certs only work with local accounts on the remote host per WinRM documentation. The client cert (when created with OpenSSL) and if applicable the CA cert need to be pre-installed on the remote server in order for certificate authentication to work. Requires the client_key option. When client_cert and client_key are provided the username and password will be ignored.

### client_key

The path to a local client key used for authentication in lieue of a username and password.

### elevated

When true, all commands are executed via a scheduled task. This may eliminate access denied errors related to double hop authentication, interacting with Windows updates and installing some MSIs such as SQL Server and .NET runtimes. Defaults to `false`.

### elevated_password

The password used by the identity running the scheduled task. This may be null in the case of service accounts. Defaults to `password`.

### elevated_username

The identity that the task runs under. This may also be set to service accounts such as System. This defaults to `username`.

### rdp_port

Port used making rdp connections for kitchen login commands. Defaults to `3389`.

### winrm_transport

The transport type used by winrm as explained here. The default is `negotiate`. `ssl` and `plaintext` are also acceptable values.
