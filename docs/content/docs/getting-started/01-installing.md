---
title: "Installing"
slug: installing
menu:
  docs:
    parent: getting_started
    weight: 10
---

This quick start guide is designed for users with little or no experience with Chef Infra or Ruby. It will walk you through creating a Chef Infra cookbook and introduce automated testing as a standard practice. Before we begin, let's make sure you have the necessary tools installed.

##### Pre-requisites

- 64 bit operating system
- CPU Virtualization enabled

To run 64-bit virtual machines, your computer must have a 64-bit operating system and a processor that supports hardware virtualization. These virtualization features—Intel VT-x for Intel CPUs or AMD-V for AMD CPUs—must be enabled in your system's BIOS or EFI settings. Most modern processors include these extensions, but they may be disabled by default, so check your system documentation if you're unsure.

<div class="callout">
<h3 class="callout--title">Windows and Hyper-V</h3>
Unfortunately Hyper-V doesn't like other hypervisors running at the same time and it must be disabled as a Windows Feature for VirtualBox to function properly.
</div>

##### Chef Workstation

First, install the [Chef Workstation](https://www.chef.io/downloads). This package includes Chef Infra Client, Chef InSpec, Test Kitchen, Cookstyle, and a variety of useful tools for the Chef ecosystem.

```ruby
$ chef --version
Chef Workstation version: 25.5.1084
Chef CLI version: 5.6.21
Chef Habitat version: 1.6.1243
Test Kitchen version: 3.7.0
Cookstyle version: 7.32.8
Chef Infra Client version: 18.7.10
Chef InSpec version: 5.22.80
```

##### VirtualBox

VirtualBox is a popular open-source hypervisor that enables you to run multiple virtual machines on your local system. To get started, download and install the correct version for your operating system from the [VirtualBox Downloads page](https://www.virtualbox.org/wiki/Downloads). After installation, confirm that VirtualBox is correctly set up and its command-line tools are available in your `$PATH` by running:

```bash
$ VBoxManage --version
7.1.8r168469
```

##### Vagrant

Vagrant acts as a wrapper for hypervisors like VirtualBox, simplifying the process of creating, configuring, and sharing reproducible development environments. It uses pre-built virtual machine images called "boxes" to quickly spin up environments. To get started, download and install the correct Vagrant package for your operating system from the [Vagrant Downloads page](https://www.vagrantup.com/downloads).

```bash
$ vagrant --version
Vagrant 2.4.7
```

With Chef Workstation, VirtualBox, and Vagrant installed, you're ready to use Test Kitchen's default setup. By default, Test Kitchen uses the `kitchen-vagrant` driver, which leverages Vagrant to create, manage, and destroy local virtual machines. Vagrant supports a variety of hypervisors and cloud providers, but for this guide, we'll use VirtualBox for local virtualization.

Test Kitchen is highly modular, allowing you to mix and match different drivers (such as Vagrant, VMware, Azure, EC2, or Docker), provisioners (like Chef Infra, Ansible, Puppet, Salt, or DSC), and verifiers (including InSpec, Serverspec, or BATS). In this quick start, we'll focus on the most common workflow: Vagrant with VirtualBox for virtualization, Chef Infra for provisioning, and InSpec for testing.

<div class="sidebar--footer">
<a class="button primary-cta" href="/docs/getting-started/getting-help">Next - Getting Help</a>
<a class="sidebar--footer--back" href="/docs/getting-started/">Back to previous step</a>
</div>
