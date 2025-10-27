---
title: Microsoft Azure
menu:
  docs:
    parent: drivers
    weight: 15
---

kitchen-azurerm is a Test Kitchen *driver* for Microsoft Azure.

### Setting Driver Configuration

The Microsoft Azure driver for Test Kitchen includes many configuration options that can be set globally in the driver section of your kitchen.yml config file or within each platform configuration. Global settings apply to all platforms in the `kitchen.yml`, while platform level driver configuration is applied to only those platforms and override globally set configuration options. Even if you use platform level configuration options, it's a good idea to specify the driver you use to use globally.

#### Example Global Driver Option

This configuration sets the driver to `azurerm` and then sets the `some_config` configuration to true.

```yaml
driver:
  name: azurerm
  some_config: true
```

#### Example Platform Driver Option

This configuration sets the driver to `azurerm` globally and then sets the `some_config` configuration to true for just `ubuntu-20`.

```yaml
driver:
  name: azurerm

platforms:
  - name: ubuntu-20
    driver:
      some_config: true
```

### Driver Configuration Options

#### subscription_id (required)

* *string* : Reads string from `ENV["AZURE_SUBSCRIPTION_ID"]` or must be specified if not present in `ENV`.
  * Default Value: `ENV["AZURE_SUBSCRIPTION_ID"]`

#### azure_environment

* *string* : Name of Azure environment to use.

#### machine_size (required)

* *string* : Machine size to use for instances created.

#### location (required)

* *string* : Azure location to use, example `"Central US"`

#### zone

* *string* : Used for specifying the availability zone for vm creation.
  * Default Value: `"1"`

#### azure_resource_group_prefix

* *string* : Prefix to use for the resource group configuration which will be created.
  * Default Value: `"kitchen-"`

#### azure_resource_group_suffix

* *string* : Optional suffix to append to resource group name.
  * Default Value: `""`

#### azure_resource_group_name

* *string* : Optional override for base name of the Azure Resource group which is created, uses prefix and suffix.
  * Default Value: `""`

#### explicit_resource_group_name

* *string* : Optional explicit resource group name, does not use `azure_resource_group_prefix`/`azure_resource_group_suffix`
  * Default Value: `""`

#### destroy_explicit_resource_group

* *boolean* : Used for cleanup with `explicit_resource_group_name`
  * Default Value: `true`

#### destroy_explicit_resource_group_tags

* *boolean* : Used for cleanup with `explicit_resource_group_name`
  * Default Value: `true`

#### destroy_resource_group_contents

* *boolean* : Can be used when you want to destroy the resources within a resource group without destroying the resource group itself. For example, the following configuration options used in combination would use an existing resource group (or create one if it doesn't exist) and will destroy the contents of the resource group in the ```kitchen destroy``` phase. If you wish to destroy the empty resource group created after you empty the resource group with this flag you can now set the ```destroy_explicit_resource_group``` to "true" to destroy the empty resource group.
  * Default Value: `false`

#### resource_group_tags

* *hash* : Optional hash of tags to pass to resource group

  ```yaml
  driver:
    name: azurerm
    resource_group_tags:
      tag1: tag1value
  ```

#### image_urn

* *string* : Image URN to use for vm creation. List can be found using `az` cli - [https://learn.microsoft.com/en-us/azure/virtual-machines/linux/cli-ps-findimage#list-popular-images]
  * Default Value: `"Canonical:UbuntuServer:14.04.3-LTS:latest"`

#### image_url

* *string* : (unmanaged disks only) can be used to specify a custom vhd
  * This VHD must be in the same storage account as the disks of the VM, therefore ```existing_storage_account_blob_url``` must also be set and ```use_managed_disks``` must be set to false.

#### image_id

* *string* : (managed disks only) can be used to specify an image by id (managed disk). This works only with managed disks.

#### use_ephemeral_osdisk

* *boolean* : Optional flag to use ephemeral disk for instances.
  * Default Value: `false`

#### os_disk_size_gb

* *string* : Optional override of os disk size for instances.

#### os_type

* *string* : Should be specified when os type is not `linux`
  * Default Value: `"linux"`

#### custom_data

* *string* : Optional custom data which may be specified for instances ([Azure custom data documentation](https://learn.microsoft.com/azure/virtual-machines/custom-data)).
  * Value can be a file or the data itself, this module handles base64 encoding for you.

#### username

* *string* : Username to use for connecting to instances.
  * Default Value: `"azure"`

#### password

* *string* : Optional password to use for connecting to instances.
  * Default Value: `SecureRandom.base64(25)` (Randomly generated 24 digit password)

#### vm_name

* *string* : Optional name for vm instances to create.
  * Default Value: `"tk-#{SecureRandom.hex(6)[0..11]}"` (Randomly generated 12 character name prefixed with `tk-`)

#### nic_name

* *string* : Optional name to provide for nic, if not specified then nic name will be `"nic-#{config[:vm_name]}"`.

#### vnet_id

* *string* : Optional `vnet` to provide.  If no `vnet` is chosen then public IP will be assigned using default values.

#### subnet_id

* *string* : Optional subnet to provide, should be used with `vnet_id`.

#### public_ip

* *boolean* : Option to specify if a public IP should be assigned.  In default configuration if all other options are left at default then a public IP *will* be assigned, due to `vnet_id` having no value.
  * Default Value: `false`

#### public_ip_sku

* *string* : Optional string to change the SKU of allocated public IP address.  Defaults to `Basic`.
  * Default Value: `"Basic"`

#### storage_account_type

* *string* : Optional storage account type.
  * Default Value: `"Standard_LRS"`

#### existing_storage_account_blob_url

* *string* : Used with private image specification, the URL of the existing storage account (blob) (without container)

#### existing_storage_account_container

* *string* : Used with private image specification, the Container Name for OS Images (blob)

#### boot_diagnostics_enabled

* *boolean* : Whether to enable (true) or disable (false) boot diagnostics. Default: true (requires Standard storage).
  * Default Value: `true`

#### winrm_powershell_script

* *string* : By default on Windows machines, a PowerShell script runs that enables WinRM over the SSL transport, for Basic, Negotiate and CredSSP connections. To supply your own PowerShell script (e.g. to enable HTTP), use the `winrm_powershell_script` parameter. Windows 2008 R2 example:

    ```yaml
    platforms:
    - name: windows2008-r2
        driver_config:
        image_urn: MicrosoftWindowsServer:WindowsServer:2008-R2-SP1:latest
        winrm_powershell_script: |-
            winrm quickconfig -q
            winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="512"}'
            winrm set winrm/config '@{MaxTimeoutms="1800000"}'
            winrm set winrm/config/service '@{AllowUnencrypted="true"}'
            winrm set winrm/config/service/auth '@{Basic="true"}'

    ```

#### pre_deployment_template

* *string* : Optional path to name of pre-deployment template to use.

#### pre_deployment_parameters

* *hash* : Optional parameters to pass to pre-deployment template.

#### post_deployment_template

* *string* : Optional path to name of post-deployment template to use.

#### post_deployment_parameters

* *hash* : Optional parameters to pass to post-deployment template.

#### plan

* *hash* : Optional JSON object which allows you to define plan information when creating VMs from Marketplace images. Please refer to [Deploy an image with Marketplace terms](https://learn.microsoft.com/azure/virtual-machines/linux/cli-ps-findimage#deploy-an-image-with-marketplace-terms) for more details. Not all Marketplace images support programmatic deployment, and support is controlled by the image publisher.

#### vm_tags

* *hash* : Optional hash of vm tags to populate.

#### use_managed_disks

* *boolean* : Must be set to `true` to use `data_disks` property.
  * Default Value: `true`

#### data_disks

* *array* : Additional disks to configure for instances.

    ```yaml
    platforms:
    - name: windows2016-noformat
    driver:
        image_urn: MicrosoftWindowsServer:WindowsServer:2016-Datacenter:latest
        data_disks:
        - lun: 0
            disk_size_gb: 128
        - lun: 1
            disk_size_gb: 128
        - lun: 2
            disk_size_gb: 128
    ```

#### format_data_disks

* *boolean* : Run format operations on attached data disks
  * Default Value: `false`

#### format_data_disks_powershell_script

* *boolean* : Customize the content of format operations for attached `data_disks`
  * Default Value: `false`

#### system_assigned_identity

* *boolean* : Whether to enable system assigned identity for the vm.
  * Default Value: `false`

#### user_assigned_identities

* *hash* : An object whose keys are resource IDs for user identities to associate with the Virtual Machine and whose values are empty objects, or empty to disable user assigned
identities.

#### deployment_sleep

* *string* : Time in seconds to sleep at the end of deployment before fetching details.
  * Default Value: `10`

#### secret_url

* *string* : used with connecting to Azure Key Vault

#### vault_name

* *string* : used with connecting to Azure Key Vault

#### vault_resource_group

* *string* : used with connecting to Azure Key Vault

#### azure_api_retries

* *string* : Number of times to retry connections to Azure API.
  * Default Value: `5`

#### use_fqdn_hostname

* *boolean* : When true, Kitchen will use the FQDN that is assigned to the Virtual Machine. When false, kitchen will use the public IP address of the machine. This may overcome issues with Corporate firewalls or VPNs blocking Public IP addresses.
  * Default Value: `false`

#### store_deployment_credentials_in_state

* *boolean* : When enabled it will store the provisioner credentials in the state (default). Otherwise you will need to specify credentials under the transport. Disabling this is only useful in extremely unusual circumstances, e.g. you want to use credentials setup by cloud init or some other means other than the azure provisioning process.
  * Default Value: `true`

### Example **kitchen.yml**

```yaml
---
driver:
  name: azurerm
  subscription_id: '4801fa9d-YOUR-GUID-HERE-b265ff49ce21'
  location: 'West Europe'
  machine_size: 'Standard_D2_V2'

provisioner:
  name: chef_infra

verifier:
  name: inspec

platforms:
  - name: windows2016
    driver:
      image_urn: MicrosoftWindowsServer:WindowsServer:2016-Datacenter:latest
    transport:
      name: winrm
      elevated: true

suites:
  - name: default
    run_list:
      - recipe[my_cookbook::default]
    attributes:
```
