---
title: "Installing"
slug: installing
menu:
  docs:
    parent: getting_started
    weight: 10
---

As this is a quick start guide, it doesn't assume any great familiarity with Chef Infra or Ruby and takes you through the process of writing a Chef Infra cookbook with automated testing as standard. In order to follow this guide, we'll need a few tools first.

##### Pre-requisites

- 64 bit operating system
- CPU Virtualization enabled

In order to virtualize a 64 bit operating system, one must also be running a 64 bit operating system. Most importantly, the CPU itself must support hardware virtualization extensions and this must be enabled in the BIOS/EFI. Most modern processors support virtualization extensions in the form of VT-x (Intel) or AMD-V (AMD).

<div class="callout">
<h3 class="callout--title">Windows and Hyper-V</h3>
Unfortunately Hyper-V doesn't like other hypervisors running at the same time and it must be disabled as a Windows Feature for VirtualBox to function properly.
</div>

##### Chef Workstation

First, install the [Chef Workstation](https://www.chef.io/downloads/tools/workstation). This package includes Chef Infra Client, Chef InSpec, Test Kitchen, Cookstyle, and a variety of useful tools for the Chef ecosystem.

```ruby
$ chef --version
Chef Workstation version: 22.1.774
Chef Habitat version: 1.6.420
Test Kitchen version: 3.2.2
Cookstyle version: 7.30.4
Chef Infra Client version: 17.9.26
Chef InSpec version: 4.52.9
Chef CLI version: 5.5.6
```

##### VirtualBox

VirtualBox is a hypervisor that lets you run virtual machines on your local workstation. Obtain the correct installer for your platform [here](https://www.virtualbox.org/wiki/Downloads). Verify that the command is accessible and in the $PATH with the following:

```bash
$ VBoxManage --version
6.1.32r149290
```

##### Vagrant

Vagrant manages hypervisors such as VirtualBox and makes it easy to distribute pre-packaged virtual machines, known as "boxes". Obtain the correct installer for your platform [here](https://www.vagrantup.com/downloads).

```bash
$ vagrant --version
Vagrant 2.2.18
```

We've just installed Chef Workstation, VirtualBox, and Vagrant. The reason we have done so is that the default `driver` for Test Kitchen is `kitchen-vagrant` which uses Vagrant to create, manage, and destroy local virtual machines. Vagrant itself supports many different hypervisors and clouds but for the purposes of this exercise we are interested in the default local virtualization provided by VirtualBox.

Kitchen is modular so that one may use a variety of different drivers (Vagrant, VMware, Azure, EC2, Docker), provisioners (Chef Infra, Ansible, Puppet, Salt, DSC), or verifiers (InSpec, Serverspec, BATS) but for the purposes of the guide we're focusing on the default "happy path" of Vagrant with VirtualBox, Chef Infra, and InSpec.

<div class="sidebar--footer">
<a class="button primary-cta" href="/docs/getting-started/getting-help">Next - Getting Help</a>
<a class="sidebar--footer--back" href="/docs/getting-started/">Back to previous step</a>
</div>
