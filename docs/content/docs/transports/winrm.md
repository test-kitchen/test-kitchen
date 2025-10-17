---
title: WinRM
menu:
  docs:
    parent: transports
    weight: 15
---

`winrm` is the default transport for all Windows hosts. The default transport settings are sufficient for most users, and the transport section does not need to be defined in the `kitchen.yml` file.

## WinRM Transport Settings

### General Settings

#### port

The port used to connect to the test instance. This defaults `5985` when using `http` or `5986` when using `https`.

#### username

The username used for authenticating to the test instance. This defaults to `administrator`. Some drivers may change this default.

#### password

The password used for authenticating to the test instance.

#### client_cert

The path to a local client certificate used as the CA for authentication in lieu of a username and password. Client certs only work with local accounts on the remote host per WinRM documentation. The client cert (when created with OpenSSL) and if applicable the CA cert need to be pre-installed on the remote server in order for certificate authentication to work. Requires the client_key option. When `client_cert` and `client_key` are provided the username and password will be ignored.

#### client_key

The path to a local client key used for authentication in lieu of a username and password.

#### elevated

When true, all commands are executed via a scheduled task. This may eliminate access denied errors related to double hop authentication, interacting with Windows updates, and installing some MSIs such as SQL Server and .NET runtimes. This defaults to `false`.

#### elevated_password

The password used by the identity running the scheduled task. This may be null in the case of service accounts. This defaults to `password`.

#### elevated_username

The identity that the task runs under. This may also be set to service accounts such as System. This defaults to `username`.

#### rdp_port

Port used making rdp connections for kitchen login commands. This defaults to `3389`.

#### winrm_transport

The transport type used by winrm as [explained here](https://learn.microsoft.com/en-us/windows/win32/winrm/authentication-for-remote-connections). This defaults to `negotiate`. `ssl,` and `plaintext` are also acceptable values.

### Retry Settings

#### connection_retries

Maximum number of times to retry after a failed attempt to open a connection. This defaults to `5`.

#### connection_retry_sleep

The number of seconds to wait until attempting to make another connection after a failure. This defaults to `1`

#### max_wait_until_ready

The maximum number of attempts to determine if the test instance is ready to accept commands. This defaults to `600`.
