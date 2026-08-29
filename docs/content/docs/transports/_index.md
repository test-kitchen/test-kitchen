---
title: About Transports
menu:
  docs:
    parent: transports
    weight: 1
---

A Test Kitchen *transport* is how Test Kitchen connects to the instance created via drivers so that the provisioners can run.

The two most common transports are `ssh` and `winrm`. On Windows systems, `winrm` is used by default, and `ssh` is used by default on all other systems.

### Transports documented here

| Transport | Connects with |
| ---- | ---- |
| [SSH](/docs/transports/ssh) | SSH. The default on non-Windows platforms. |
| [WinRM](/docs/transports/winrm) | WinRM. The default on Windows platforms. |
| [Docker](/docs/transports/docker) | `docker exec`, with no SSH or WinRM server needed. Ships with [kitchen-docker](https://github.com/test-kitchen/kitchen-docker). |

Some drivers ship their own transport. [kitchen-dokken](/docs/drivers/dokken) provides a `dokken` transport, and [kitchen-docker](https://github.com/test-kitchen/kitchen-docker) provides the `docker` transport above. Where a driver offers one, it is usually the fastest and most reliable pairing, because it talks to the container or hypervisor directly instead of going over the network.

{{% info %}}
A transport is chosen independently of the driver. If your driver builds a machine that a standard SSH or WinRM client can reach, the built-in transports work without configuration.
{{% /info %}}
