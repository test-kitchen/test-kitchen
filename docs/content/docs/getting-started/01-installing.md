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

##### Test Kitchen and Workstation tooling

Install Test Kitchen from RubyGems, your system packages, or [Cinc Workstation](https://cinc.sh/start/workstation/). This guide uses Cinc Workstation, the community distribution, which bundles Test Kitchen along with the drivers, provisioners, and verifiers you need to follow along.

Test Kitchen itself does not bundle Cinc or Chef tooling. When you use a Workstation package, the available drivers, provisioners, verifiers, and commands are the ones bundled by that package. [Chef Workstation](https://www.chef.io/downloads) works the same way — substitute `chef` for `cinc` in the commands below, and `chef_infra` for `cinc_infra` in the examples.

For a RubyGems install:

```bash
$ gem install test-kitchen
$ kitchen version
Test Kitchen version 4.0.0
```

For a Workstation install, use the Workstation command to see what it bundles:

```bash
$ cinc --version
```

##### VirtualBox

VirtualBox is a popular open-source hypervisor that enables you to run multiple virtual machines on your local system. To get started, download and install the correct version for your operating system from the [VirtualBox Downloads page](https://www.virtualbox.org/wiki/Downloads). After installation, confirm that VirtualBox is correctly set up and its command-line tools are available in your `$PATH` by running:

```bash
$ VBoxManage --version
7.2.16r174877
```

##### Vagrant

Vagrant acts as a wrapper for hypervisors like VirtualBox, simplifying the process of creating, configuring, and sharing reproducible development environments. It uses pre-built virtual machine images called "boxes" to quickly spin up environments. To get started, download and install the correct Vagrant package for your operating system from the [Vagrant Downloads page](https://www.vagrantup.com/downloads).

```bash
$ vagrant --version
Vagrant 2.4.9
```

With Test Kitchen, VirtualBox, and Vagrant installed, you're ready to create a local virtual machine. By default, `kitchen init` generates a `kitchen-vagrant` driver configuration and a shell provisioner. This guide uses Vagrant with VirtualBox for virtualization, and Cinc Workstation for the cookbook examples.

Test Kitchen is highly modular, allowing you to mix and match drivers (such as Vagrant, VMware, Azure, EC2, or Docker), provisioners (such as shell, Cinc/Chef, Ansible, Puppet, Salt, or DSC), and verifiers (including InSpec, Serverspec, or BATS). Install those plugins into the same Ruby environment that runs `kitchen`.

<div class="sidebar--footer">
<a class="button primary-cta" href="/docs/getting-started/getting-help">Next - Getting Help</a>
<a class="sidebar--footer--back" href="/docs/getting-started/">Back to previous step</a>
</div>
