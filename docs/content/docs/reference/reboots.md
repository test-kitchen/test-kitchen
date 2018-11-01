---
title: Reboots
menu:
  docs:
    parent: reference
    weight: 35
---

Test-kitchen has support for enduring reboots initiated by a Chef provisioner. 

```
provisioner:
  name: chef_zero
  max_retries: 3 # tweak in conjunction with below
  wait_for_retry: 90 # tweak based on machine shutdown speed
  retry_on_exit_code:
    - 35 # chef-client's reboot scheduled exit status
  client_rb:
    exit_status: :enabled # default in 13+, only required for 12.x
    client_fork: false # don't fork so we get true exit code, not needed for Windows
```

`wait_for_retry` is necessary so that Test-kitchen doesn't try to reconnect before the system reboots (or at least before the transport stops taking connections).  This is the most likely option to need tweaking and varies between drivers as well as the specifications of the instances.
