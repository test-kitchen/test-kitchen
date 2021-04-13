---
title: About Tranports
menu:
  docs:
    parent: transports
    weight: 1
---

A Test Kitchen *transport* is how Test Kitchen connects to the instance created via drivers so that the provisioners can run.

The two most common transports are `ssh` and `winrm`. On Windows sysystems `winrm` is used by default and on all other systems `ssh` is used by default.
