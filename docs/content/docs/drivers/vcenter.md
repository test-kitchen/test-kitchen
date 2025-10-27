---
title: VMware vCenter
menu:
  docs:
    parent: drivers
    weight: 15
---

kitchen-vcenter is a Test Kitchen *driver* for VMware vCenter using the vSphere Automation SDK.

## Requirements

- VMware vCenter/vSphere 5.5 or higher
- VMs or templates to clone, with the `open-vm-tools` package installed
- DHCP server to assign IPs to Test Kitchen instances

## Configuration

### Required parameters

The following parameters should be set in the main `driver` section as they are common to all platforms:

- `vcenter_username` - Name to use when connecting to the vSphere environment
- `vcenter_password` - Password associated with the specified user
- `vcenter_host` - Host against which logins should be attempted

The following parameters should be set in the `driver` section for the individual platform:

- `datacenter` - Name of the datacenter to use to deploy into
- `template` - Template or virtual machine to use when cloning the new machine (needs to be a VM for linked clones)

### Optional Parameters

The following parameters should be set in the main `driver` section as they are common to all platforms:

- `vcenter_disable_ssl_verify` - Whether or not to disable SSL verification checks. Good when using self signed certificates. Default: false
- `vm_wait_timeout` - Number of seconds to wait for VM connectivity. Default: 90
- `vm_wait_interval` - Check interval between tries on VM connectivity. Default: 2.0
- `vm_rollback` - Automatic roll back (destroy) of VMs failing the connectivity check. Default: false
- `benchmark` - Write benchmark data for comparisons. Default: false
- `benchmark_file` - Filename to write CSV data to. Default: "kitchen-vcenter.csv"
- `transform_ip` - Ruby code to rewrite instance IP (available as `ip` variable in contents)

The following optional parameters should be used in the `driver` for the platform.

- `resource_pool` - Name of the resource pool to use when creating the machine. Default: first pool
- `cluster` - Cluster on which the new virtual machine should be created. Default: cluster of the `targethost` machine.
- `targethost` - Host on which the new virtual machine should be created. If not specified then the first host in the cluster is used.
- `folder` - Folder into which the new machine should be stored. If specified the folder *must* already exist. Nested folders can be specified by separating the folder names with a `/`.
- `poweron` - Power on the new virtual machine. Default: true
- `vm_name` - Specify name of virtual machine in vSphere. Default: `<suite>-<platform>-<random-hexid>`
- `clone_type` - Type of clone, use "full" to create complete copies of template. Values: "full", "linked", "instant". Default: "full"
- `networks` - A list of networks to either reconfigure or attached to the newly created vm, needs a VM Network name. Default: do not change
- `tags` - Array of pre-defined vCenter tag names to assign (VMware tags are not key/value pairs). Default: none
- `vm_customization` - Dictionary customizations like annotation, memoryMB or numCPUs (see below for details). Default: none
- `interface`- VM Network name to use for kitchen connections. Default: not set = first interface with usable IP

 The following optional parameters are relevant for active IP discovery.

- `active_discovery` - Use active IP retrieval to speed up provisioning. Default: false
- `active_discovery_command` - String or list of specific commands to retrieve VM IP (see Active Discovery Mode section below)
- `vm_os` - OS family of the VM . Values: "linux", "windows". Default: autodetect from VMware
- `vm_username` - Username to access the VM. Default: "vagrant"
- `vm_password` - Password to access the VM. Default: "vagrant"

In addition to active IP discovery, the following optional parameter is relevant for instant clones using Windows.

- `vm_win_network` - Internal Windows name of the Kitchen network adapter for reloading. Default: Ethernet0

The following `vm_customization` (previously `customize`) subkeys for VM customization are available. They inherit from the specified `template` by default.

- `annotation` - Notes to attach to the VM (requires VirtualMachine.Config.Rename)
- `memoryMB` - Memory size to set in Megabytes (requires VirtualMachine.Config.Memory)
- `numCPUs` - Number of CPUs to assign (requires VirtualMachine.Config.CpuCount)
- `guestinfo.*` - Adds guestinfo to the VM, e.g.
  - `guestinfo.my.thing`
  - `guestinfo.other.thing`
- `add_disks` - Array of disks to add to the VM (requires VirtualMachine.Config.AddNewDisk).
   Keys per disk: `type` (default: `thin`, other values: `flat`/`flat_lazy` or `flat_eager`), `size_mb` in MB (default: 10 GB)

The following `guest_customization` subkeys are available for general guest OS customization. Please note that this feature will significantly slow instance creation.

- `ip_address` - (*Optional*) String for configuring a static IPv4 address (performs validation as IPv4 only is supported at this time), if omitted DHCP will be used
- `gateway` - (*Optional*) Array for configuring IPv4 addresses as gateways
- `subnet_mask` - (*Optional*) String for configuring subnet mask, this is *required if* `ip_address` is set
- `dns_domain` - (*Required*) String for configuring DNS domain
- `timezone` - (*Required*) String for configuring timezone. Linux requires "Area/Location", while Windows requires a numeric value. Default: UTC
- `hostname` - (*Optional*) Hostname, will revert to `vm_name` if not given
- `dns_server_list` - (*Required*) Array for configuring DNS servers
- `dns_suffix_list` - (*Required*) Array for configuring DNS suffixes
- `timeout_task` - (*Optional*) Timeout for guest customization to finish. Default: 600 seconds
- `timeout_ip` - (*Optional*) Time to wait after successful customization to let vSphere catch a new static IP. Default: 30 seconds
- `continue_on_ip_conflict` - (*Optional*) Continue, even if a reachable host already uses the customized IP. Default: false

### Linux Guest Customization

Linux Example:

```yaml
platforms:
  - name: centos-7
    driver:
      # ...
      guest_customization:
        ip_address: 10.10.176.15
        gateway:
        - 17.10.176.1
        subnet_mask: 255.255.252.0
        dns_domain: 'example.com'
        timezone: 'US/Pacific'
        dns_server_list:
        - 8.8.8.8
        - 7.7.7.7
        dns_suffix_list:
        - 'test.example.com'
        - 'example.com'
        hostname: 'centos-7-kitchen'
```

Known customization issues:

- Sometimes the `libpath-class-file-stat-perl` package is missing which is needed for IP customization.
- `open-vm-tools` should be newer than 10.3.10 to avoid compatibility issues

### Windows Guest Customization

The following `guest_customization` subkeys are Windows specific:

- `org_name` - (*Optional*) Organization name for the Machine. Default: "TestKitchen"
- `product_id` - (*Required*) Product Key for the OS. Default: Attempt automatic selection, but this might fail
- `administrator_password` - (*Optional*) The plain text password to assign to the 'Administrator' account during customization

On guest customizations after Windows Vista the machine SID will be regenerated to avoid conflicts.

Windows Example:

```yaml
platforms:
  - name: windows-2019
    driver:
      # ...
      guest_customization:
        ip_address: 10.10.176.16
        gateway:
        - 17.10.176.1
        subnet_mask: 255.255.252.0
        dns_domain: 'example.com'
        timezone: 0x4
        dns_server_list:
        - 8.8.8.8
        - 7.7.7.7
        dns_suffix_list:
        - 'test.example.com'
        - 'example.com'
        hostname: 'win2019-kitchen'
        product_id: 00000-00000-00000-00000-00000
```

Debugging customization issues on Windows:

- Timezone IDs can be found at [Microsoft Support](https://support.microsoft.com/en-us/help/973627/microsoft-time-zone-index-values)
- Official KMS 120 day evaluation keys can be found at [Microsoft Documentation](https://learn.microsoft.com/en-us/windows-server/get-started/kms-client-activation-keys)
- On "Windows could not parse or process the unattend answer file" errors press Shift-F10 and check `C:\\Windows\\Panther\\UnattendGC\\*.log`

## Clone types

### Clone type: full

This takes a VM or template, copies the whole disk and then boots up the machine. Default mode of operation.

Required privileges:

- Datastore.AllocateSpace
- Network.Assign
- Resource.AssignVMToPool
- VirtualMachine.Interact.PowerOn
- VirtualMachine.Provisioning.Clone
- VirtualMachine.Provisioning.DeployTemplate

- VirtualMachine.Config.Annotation (depending on `vm_customization` parameters)
- VirtualMachine.Config.CPUCount (depending on `vm_customization` parameters)
- VirtualMachine.Config.Memory (depending on `vm_customization` parameters)
- VirtualMachine.Config.EditDevice (if `networks` is used)
- DVSwitch.CanUse (if `networks` is used with dVS/lVS)
- DVPortgroup.CanUse (if `networks` is used with dVS/lVS)

### Clone mode: linked

Instead of a full copy, "linked" uses delta disks to speed up the cloning process and uses many fewer IO operations. After creation of the delta disks, the machine is booted up and writes only to its delta disks.

The `template` parameter has to reference a VM (a template will not work) and a snapshot must be present. Otherwise, the driver will fall back to creating a full clone.

Depending on the underlying storage system, performance may vary greatly compared to full clones.

Required privileges: (see "Clone mode: full")

### Clone mode: instant

The instant clone feature has been available under the name "VMFork" in earlier vSphere versions, but without a proper public API. With version 6.7.0, instant clones became an official feature. They work by not only using a delta disk like linked clones, but also share memory with the source machine. Because of sharing memory contents, the new machines are already booted up after cloning.

Prerequisites:

- vCenter version 6.7.0 or higher
- vSphere Hypervisor (aka ESXi) version 6.7.0 or higher
- VMware Tools installed and running
- a running source virtual machine (`template` parameter)
- for Linux, currently only `dhclient` is supported as DHCP client

Limitations:

- A new VM is always on the same host because of memory sharing
- The current driver supports only the "Frozen Source VM" workflow, which is more efficient than the "Running Source VM" version

Freezing the source VM:

- Login to the machine
- Execute the freeze operation, for example via `vmtoolsd --cmd "instantclone.freeze"`
- The machine does not execute any CPU instructions after this point

New clones resume from exactly the frozen point in time and also resume CPU activity automatically. The OS level network adapters get rescanned automatically
to pick up MAC address changes, which requires the privileges to use the Guest Operations API and login credentials (`vm_username`/`vm_password`).

Architectural description see <https://williamlam.com/2018/04/new-instant-clone-architecture-in-vsphere-6-7-part-1.html>

Required privileges in addition to "Clone mode: full":

- VirtualMachine.Config.EditDevice
- VirtualMachine.Inventory.CreateFromExisting
- VirtualMachine.GuestOperations.Execute
- VirtualMachine.GuestOperations.Query

## Active Discovery Mode

This mode is used to speed up provisioning of kitchen machines as much as possible. One of the limiting factors despite actual provisioning time
(which can be improved using the linked/instant clone modes) is waiting for the VM to return its IP address. While VMware tools are usually available and
responding within 10-20 seconds, sending back IP/OS information to vCenter can take additional 30-40 seconds easily.

Active mode invokes OS specific commands for IP retrieval as soon as the VMware Tools are responding, by using the Guest Operations Manager
feature within the tools agent. Depending on the OS, a command to determine the IP will be executed using Bash (Linux) or CMD (Windows) and the
resulting output parsed. While the driver has sensible default commands, you can set your own via the `active_discovery_command` directive on the
platform level.

Active mode can speed up tests and pipelines by up to 30 seconds, but may fail due to asynchronous OS interaction in some instances. If retrieving the IP
fails for some reason, the VMware Tools provided data is used as fallback.

Required privileges:

- VirtualMachine.GuestOperations.Execute
- VirtualMachine.GuestOperations.Query

Linux default:
`ip address show scope global | grep global | cut -b10- | cut -d/ -f1`

Windows default:
`sleep 5 & ipconfig`

## Benchmarking

To get some insight into the performance of your environment with different configurations, some simple benchmark functionality was built in. When you
enable this via the `benchmark` property, data gets appended to a CSV file (`benchmark_file` property) and printed to standard out (`-l debug` on CLI)

This file includes a header line describing the different fields such as the value of `template`, `clone_type` and `active_discovery` plus the different
steps within cloning a VM. The timing of steps is relative to each other and followed by a column with the total number of seconds for the whole cloning
operation.

## Networking

When creating a VM using the vCenter driver, the user can reconfigure the existing network or attach multiple networks.

The previous configuration for managing the networks was `network_name` which could be able to reconfigure the existing network when a new VM is created.
This configuration is now deprecated and the `networks` configuration is introduced to support the multi-network functionality.

The type of operation that needs to be performed on the network device is also configurable.
By default, the network will be added to the VM. If the user specify the `edit` operation, then the existing network in the template will be replaced by the specified network.
Currently, only `add` and `edit` operations are implemented.

Example:

```yaml
driver:
  # ... other settings
  networks:
    - name: VLAN-1
      operation: "edit"
    - name: VLAN-2
      operation: "add"
```

## 1:1 NAT Support

Due to limited IPv4 space, some enterprises use NAT to transform the VM IPs into a routable IP. As the driver cannot detect such a NAT automatically,
but has to rely on the IP retrieved by the Guest OS, this has to be handled manually.

Example:

```yaml
driver:
  # ... other settings
  networks:
    - name: TEST-NET
      operation: "edit"
  transform_ip: "ip.sub '172.16.', '10.25.'"
```

This example reassociates the VM to the separate VMware network "TEST-NET", which would provision addresses from 172.16.x.x to the VMs. In between
this network and the developers, there is a router with 1:1 NAT configured so that those machines will be reachable as 10.25.x.x externally.

Any passed Ruby code will be executed with the `ip` variable (as discovered by VMware) available. The returned value will then be used as new IP.
As you can use arbitrary Ruby code, it is possible to do complex arithmetics or even implement remote API/IPAM lookups.

## Example **kitchen.yml**

```yaml
---
driver:
  name: vcenter
  vcenter_username: 'administrator@vsphere.local'
  vcenter_password: <%= ENV['VCENTER_PASSWORD'] %>
  vcenter_host:  <%= ENV['VCENTER_HOST'] %>
  vcenter_disable_ssl_verify: true
  vm_customization:
    annotation: "Kitchen VM by <%= ENV['USER'] %> on <%= Time.now.to_s %>"

provisioner:
  name: chef_infra
  sudo_command: sudo
  deprecations_as_errors: true
  retry_on_exit_code:
    - 35 # 35 is the exit code signaling that the node is rebooting
  max_retries: 2
  wait_for_retry: 90

verifier:
  name: inspec

platforms:
  - name: ubuntu-1604
    driver:
      targethost: 10.0.0.42
      template: ubuntu16-template
      interface: "VM Network"
      datacenter: "Datacenter"
    transport:
      username: "admini"
      password: admini

  - name: centos-7
    driver:
      targethost: 10.0.0.42
      template: centos7-template
      datacenter: "Datacenter"
    transport:
      username: "root"
      password: admini

  - name: windows2012R2
    driver:
      targethost: 10.0.0.42
      networks:
        - name: "Internal"
          operation: "edit"
      template: folder/windows2012R2-template
      datacenter: "Datacenter"
      vm_customization:
        numCPUs: 4
        memoryMB: 1024
        add_disks:
         - type: "thin"
           size_mb: 10240
    transport:
      username: "Administrator"
      password: "p@ssW0rd!"

suites:
  - name: default
    run_list:
      - recipe[cookbook::default]
```
