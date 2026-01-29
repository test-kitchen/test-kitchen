---
title: Microsoft Hyper-V
menu:
  docs:
    parent: drivers
    weight: 15
---

kitchen-hyperv is a Test Kitchen *driver* for Microsoft's Hyper-V hypervisor.

## Usage

In the `kitchen.yml` file:

```yaml
driver:
  name: 'hyperv'
```

### Required parameters

#### Driver parameters

* parent_vhd_folder
  * Location of the base vhd files
* parent_vhd_name
  * Vhd file name for the base vhd file

#### Transport parameters

* password
  * Password used to connect to the instance

### Optional parameters

* memory_startup_bytes
  * amount of RAM to assign to each virtual machine.  Defaults to 536,870,912.
* processor_count
  * number of virtual processors to assign to each virtual machine. Defaults to 2.
* dynamic_memory
  * if true, the amount of memory allocated to a virtual machine is adjusted by Hyper-V dynamically. Defaults to false.
* dynamic_memory_min_bytes / dynamic_memory_max_bytes
  * The minimum and maximum amount of memory Hyper-V will allocate to a virtual machine if dynamic_memory is enabled. Defaults to 536,870,912 and 2,147,483,648 (512MB-2GB)
* ip_address
  * IP address for the virtual machine.  If the VM is not on a network with DHCP, this can be used to assign an IP that can be reached from the host machine.
* subnet
  * The subnet of the virtual machine. Defaults to `255.255.255.0`
* gateway
  * The default gateway of the virtual machine.
* dns_servers
  * A list of DNS Servers that can be reached on the virtual network.
* vm_switch
  * The virtual switch to attach the guest VMs.  Defaults to the first switch returned from Get-VMSwitch.
* vm_vlan_id
  * The VLAN ID to assign the virtual network adapter on the VM (Valid values: 1-4094).  Defaults to untagged.
* iso_path
  * Path on the host to the ISO to mount on the VMs.
* boot_iso_path
  * Path on the host to the ISO to mount before starting the VMs.
* vm_generation
  * The generation for the hyper-v VM.  Defaults to 1.
* disable_secureboot
  * Boolean.  If true, will disable secure boot for the VM.  Only applies if `vm_generation=2`.  Defaults to false.
* enable_guest_services
  * Enable the Hyper-V Integration Guest services for the VM before starting it. Hyper-V defaults is false (true|false)
* disk_type
  * The type of virtual disk to create, .VHD or .VHDX.  Defaults to the file extension of the parent virtual hard drive.
* resize_vhd
  * Resize the disk to the specified size. Leave empty to keep the original size. Only works on newly created VM's. Defaults to empty.
* additional_disks
  * An array of hashes (`name`,`size_gb`, and `type`) of additional disks to attach to the VM.
  * **Required parameters:**
    * name
      * Unique name for the virtual disk.
  * **Optional parameters:**
    * size_gb
      * Integer. If not provided, will default to 5.
    * type
      * The type of virtual disk to create, .VHD or .VHDX.  Defaults to the file extension of the parent virtual hard drive.
  * Example:

```yaml
driver:
  name: hyperv
  parent_vhd_folder: 'D:\Hyper-V\Virtual Hard Disks'
  parent_vhd_name: tk_test.vhdx
  additional_disks:
    - name: disk1
      size_gb: 10
    - name: disk2
      size_gb: 50
      type: .VHD
```

* vm_note
  * A note to add to the VM's note field. Defaults to empty.
* copy_vm_files
  * An array of hashes (`source` and `dest`) of files or directories to copy over to the system under test. Requires enable_guest_services to be true.
  * example:

```yaml
driver:
  name: hyperv
  copy_vm_files:
    - source: c:/users/steven/downloads/chef-client-12.19.36-1-x64.msi
      dest: c:/users/administrator/appdata/local/temp/chef-client-12.19.36-1-x64.msi
```

* static_mac_address
  * String value specifying a static MAC Address to be set at virtual machine creation time.
  * Hyper-V will automatically assign a valid dynamic address if your input doesn't give a valid MAC Address.
  * example: `static_mac_address: '00155d123456'`

## Image Configuration

 The following changes need to be made to a Windows image that is going to be used for testing.  This is not an exhaustive list and, your mileage may vary.

* Guest VMs should have the latest Integration Components installed.  See <https://support.microsoft.com/en-us/help/3063109/hyper-v-integration-components-update-for-windows-virtual-machines-that-are-running-on-a-windows-10-based-host>

 Ubuntu and other Linux virtual machines may require installation of cloud tools to allow Hyper-V to determine the virtual machine's IP.

* Resolved by installing linux cloud tools. See <https://stackoverflow.com/a/33059342>

## Using Remote Hyper-V Servers

You can use a remote Hyper-V installation with this driver. For this you need to set:

* `hyperv_server` as the IP or FQDN of the server
* `hyperv_username`
* `hyperv_password`

All PowerShell commands to create and manage the VM will then be forwarded via WinRM by the Train framework. The accompanying `hyperv.ps1` helper script will be uploaded on the first connection.

### Optional Parameters

* `hyperv_ssl` (default: `false`) controls if the connection should be encrypted
* `hyperv_insecure` (default: `true`) sets if self-signed certificates should be accepted
* `remote_vm_path` (default: `C:\Users\Public\Documents\Hyper-V`) to specify where VMs should be stored

## Example **kitchen.yml**

```yaml
---
driver:
  name: hyperv
  parent_vhd_folder: C:\HyperV\WindowsServer
  parent_vhd_name: Server2016.vhdx
  vm_switch: ExternalSwitch
  memory_startup_bytes: 4GB

provisioner:
  name: chef_infra

transport:
  password: password123
  elevated: true
  name: winrm

verifier:
  name: inspec

platforms:
  - name: windows-kitchen

suites:
  - name: default
    run_list:
      - recipe[my_cookbook::default]
    attributes:
```
