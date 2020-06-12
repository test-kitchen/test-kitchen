---
title: Reboots
menu:
  docs:
    parent: reference
    weight: 35
---

Test Kitchen has support for enduring reboots initiated by a Chef provisioner.

```
provisioner:
  name: chef_zero
  max_retries: 3 # tweak in conjunction with wait_for_retry
  wait_for_retry: 90 # tweak based on machine shutdown speed
  retry_on_exit_code: [35, 213] # retry for array of exit codes
  client_rb:
    exit_status: :enabled # default in 13+, only required for 12.x
    client_fork: false # don't fork so we get true exit code, not needed for Windows
```

`wait_for_retry` is necessary so that Test Kitchen doesn't try to reconnect before the system reboots (or at least before the transport stops taking connections). This is the most likely option to need tweaking and varies between drivers as well as the specifications of the instances.

`retry_on_exit_code` does not typically need to be set. The default value is `[35, 213]` - `35` from chef-client indicates a reboot has been scheduled during the run, while `213` indicates an exit due to a chef-client upgrade.
