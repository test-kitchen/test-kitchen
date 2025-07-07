---
title: HashiCorp Vagrant
menu:
  docs:
    parent: drivers
    weight: 15
---

Kitchen-vagrant is a Test Kitchen *driver* for HashiCorp Vagrant 1.6 and later. The Vagrant driver is the preferred driver for local cookbooks testing due to the extensive platform and hypervisor support in Vagrant before running Test Kitchen.

## Supported Virtualization Hypervisors

Vagrant supports a large number of hypervisors, including both commercial and free/open-source products. Our recommended hypervisors for use with kitchen-vagrant are:

| Provider                                            | Vagrant Plugin              | Paid Hypervisor
| ---------                                           | ---------                   | ---------
| `virtualbox` - [Oracle VirtualBox][virtualbox_dl]   | built-in                    | N
| `vmware_fusion` - [VMware Fusion][fusion_dl]        | vagrant-vmware-desktop      | Y
| `vmware_desktop` - [VMware Workstation Pro][ws_dl]  | vagrant-vmware-desktop      | Y
| `parallels`- [Parallels Desktop][parallels_dl]      | vagrant-parallels           | Y
| `hyperv` - [Microsoft Hyper-V][hyperv_about]        | built-in                    | N

### Specifying Your Hypervisor

Kitchen-vagrant defaults to the `virtualbox` provider, which provides a high-performance virtualization experience on macOS, Windows, and Linux hosts. Specify the `provider` within your `kitchen.yml` config to use a different hypervisor.

Example configuration using parallels:

```yaml
driver:
  name: vagrant
  provider: parallels
```

### Installing Hypervisor Plugins

VMware and Parallels hypervisors require the installation of hypervisor plugins in Vagrant.

For VMware Fusion or Workstation Pro run:

```shell
vagrant plugin install vagrant-vmware-desktop
```

For Parallels Desktop run:

```shell
vagrant plugin install vagrant-parallels
```

To learn more about the installation, upgrade, and usage of these plugins see [Vagrant VMware Desktop Plugin Documentation][vmware_plugin] and [Parallels + Vagrant Documentation][parallels_plugin].

### Setting up Hyper-V

Microsoft Hyper-V is an exclusive hypervisor, meaning it cannot be used when another hypervisor is active on a system. Due to this restriction it is recommended that you either set the provider to `hyperv` in your `kitchen.yml` config or set the environment variable `VAGRANT_DEFAULT_PROVIDER` to `hyperv`. The `VAGRANT_DEFAULT_PROVIDER` environment variable allows controlling the default provider when one is not defined in the `kitchen.yml`. This environment variable is particularly useful is you are using Hyper-V in a project where other users rely on VirtualBox.

It is also important to consider how network switches are defined and selected when using Hyper-V. Kitchen-vagrant will select the switch to use with new VMs in the following order:

1) The environment variable `KITCHEN_HYPERV_SWITCH`
2) 'Default Switch' when running on Windows 10 Fall Creator edition and later
3) The first switch defined on the system

If `VAGRANT_DEFAULT_PROVIDER` is set and the above logic has a valid virtual switch, no additional configuration is needed. This will effectively generate a configuration similar to:

```yaml
driver:
  name: vagrant
  provider: hyperv
  network:
  - ["public_network", bridge: "Default Switch"]
```

## Default Boxes

Kitchen-vagrant defaults to using Vagrant boxes published under the [Bento organization][bento_org] on [Vagrant Cloud][vagrant_cloud]. These systems are purpose-built for use with Test Kitchen are can be configured in the `kitchen.yml` config without specifying the full path to a Vagrant box.

Example configuration using Bento images:

```yaml
platforms:
  - name: ubuntu-24.04
  - name: almalinux-10
  - name: freebsd-14
```

This short-hand configuration is the same as the following configuration explicitly specifying box names:

```yaml
platforms:
  - name: ubuntu-24.04
    driver:
      box: bento/ubuntu-24.04
  - name: almalinux-10
    driver:
      box: bento/almalinux-10
  - name: freebsd-14
    driver:
      box: bento/freebsd-14
```

### Supported Bento Platforms

Bento boxes are created for many popular open-source operating systems. All amd64(x86_64) boxes are published for the VirtualBox hypervisor and many, but not all, are also published for VMware and Parallels hypervisors.
Where available arm64 boxes are also provided for Parallels and VMware hypervisors.

Currently supported Bento platforms:

- almalinux
- amazonlinux
- centos
- centos-stream
- debian
- fedora
- freebsd
- freebsd-latest
- opensuse-leap
- oracle
- rockylinux
- ubuntu

### Using Non-Bento Vagrant Boxes

If a platform name is specified that is not published by the Bento project, it will be assumed this is a fully qualified Vagrant box name.

```yaml
platforms:
  - name: my_vagrant_account/redhat-10
```

This short-hand configuration is the same as the following configuration explicitly specifying box names:

```yaml
platforms:
  - name: my_vagrant_account/redhat-10
    driver:
      box: my_vagrant_account/redhat-10
```

Vagrant boxes can also be fetched from non-Vagrant Cloud location by specifying the `box_url`:

```yaml
platforms:
  - name: my-redhat
    driver:
      box_url: "https://example.com/my-redhat.box"
```

## Configuration

### cachier

Enable and configure scope for [vagrant-cachier][vagrant_cachier] plugin.
Valid options are `:box` or `:machine`, setting to a truthy value yields `:box`

For example:

```yaml
driver:
  cachier: true
```

will generate a Vagrantfile configuration similar to:

```ruby
  config.cache.scope = :box
```

The default is `nil`, indicating unset.

### box

**Required** This determines which Vagrant box will be used. For more
details, please read the Vagrant [machine settings][vagrant_machine_settings]
page.

The default will be computed from the platform name of the instance. However,
for a number of common platforms in the [Bento][bento] project, the default will
prefix the name with `bento/` in accordance with Vagrant Cloud naming standards.

For example, a platform with name `ubuntu-24.04` will produce a
default `box` value of `bento/ubuntu-24.04`. Alternatively, a box called
`slackware-14.1` will produce a default `box` value of `slackware-14.1`.

### box_check_update

Whether to check for box updates (enabled by default).

### box_auto_update

Whether to update box to the latest version prior to running the `vagrant up` command

### box_auto_prune

Whether to prune older versions of the box and only keep the newest version

### box_url

A box_url is not required when using the Vagrant Cloud format of
`bento/ubuntu-24.04` assuming the organization and box referenced
exist. If using a custom box this can be an `https://` or `file://`
URL.

### box_download_ca_cert

Path relative to the `.kitchen.yml` file for locating the trusted CA bundle.
Useful when combined with `box_url`.

The default is `nil`, indicating to use the default Mozilla CA cert bundle.
See also `box_download_insecure`.

### box_download_insecure

If true, then SSL certificates from the server will
not be verified.

The default is `false`, meaning if the URL is an HTTPS URL,
then SSL certs will be verified.

### box_version

The [version][vagrant_versioning] of the configured box.

The default is `nil`, indicating unset.

This option is only relevant when used with Vagrant Cloud boxes which support versioning.

### box_arch

Defaults to `nil`. When not set will use the host workstation cpu architecture for downloading boxes of similar architecture.
Setting this option will make vagrant download a box the specified cpu architecture. Bento boxes only support `amd64` or `arm64` architectures.

```yaml
driver:
  box_arch: arm64
```

### communicator

**Note:** It should largely be the responsibility of the underlying Vagrant
base box to properly set the `config.vm.communicator` value. For example, if
the base box is a Windows operating system and does not have an SSH service
installed and enabled, then Vagrant will be unable to even boot it (using
`vagrant up`), without a custom Vagrantfile. If you are authoring a base box,
please take care to set your value for communicator to give your users the best
possible out-of-the-box experience.

For overriding the default communicator setting of the base box.

For example:

```yaml
driver:
  communicator: ssh
```

will generate a Vagrantfile configuration similar to:

```ruby
  config.vm.communicator = "ssh"
```

The default is `nil` assuming ssh will be used.

### customize

A **Hash** of customizations to a Vagrant virtual machine. Each key/value
pair will be passed to your providers customization block. For example, with
the default `virtualbox` provider:

```yaml
driver:
  customize:
    memory: 1024
    cpuexecutioncap: 50
```

will generate a Vagrantfile configuration similar to:

```ruby
Vagrant.configure("2") do |config|
  # ...

  config.vm.provider :virtualbox do |virtualbox|
    virtualbox.customize ["modifyvm", :id, "--memory", "1024"]
    virtualbox.customize ["modifyvm", :id, "--cpuexecutioncap", "50"]
  end
end
```

Please read the "Customizations" sections for [VirtualBox][vagrant_config_vbox]
and [VMware][vagrant_config_vmware] for more details.

#### VirtualBox additional disk

Adding the `createhd` and `storageattach` keys in `customize` allows for creation
of additional disks in VirtualBox. Full paths must be used as required by VirtualBox.

Adding the `storagectl` key in `customize` allows for creation or customization of
disks controller in Virtualbox.

*NOTE*: IDE Controller based drives always show up in the boot order first, regardless of if they
are [bootable][vbox_ide_boot].

```yaml
driver:
  customize:
    createhd:
      - filename: /tmp/disk1.vmdk
        size: 1024
      - filename: /tmp/disk2.vmdk
        size: 2048
    storagectl:
      - name: IDE Controller
        portcount: 4
    storageattach:
      - storagectl: IDE Controller
        port: 1
        device: 0
        type: hdd
        medium: /tmp/disk1.vmdk
      - storagectl: IDE Controller
        port: 1
        device: 1
        type: hdd
        medium: /tmp/disk2.vmdk
```

will generate a Vagrantfile configuration similar to:

```ruby
Vagrant.configure("2") do |config|
  # ...

  config.vm.provider :virtualbox do |virtualbox|
    virtualbox.customize ["createhd", "--filename", "./tmp/disk1.vmdk", "--size", 1024]
    virtualbox.customize ["storagectl", :id, "--name", "IDE Controller", "--portcount", 4]
    virtualbox.customize ["storageattach", :id, "--storagectl", "IDE Controller", "--port", "1", "--device", 0, "--type", "hdd", "--medium", "./tmp/disk1.vmdk"]
  end
end
```

Please read [createhd](https://www.virtualbox.org/manual/ch08.html#vboxmanage-createvdi)
, [storageattach](https://www.virtualbox.org/manual/ch08.html#vboxmanage-storageattach)
and [storagectl](https://www.virtualbox.org/manual/ch08.html#vboxmanage-storagectl)
for additional information on these options.

#### VirtualBox audio

Audio for VirtualBox guests is disabled by default mostly for reasons around
[people wanting to enjoy listening to music while they work](https://github.com/test-kitchen/kitchen-vagrant/issues/388).
We expect 99.9% of the use cases for test-kitchen and kitchen-vagrant do not
require sound be enabled for guests. If you need to enable audio for your
Test-Kitchen-managed VirtualBox guest VMs, you can use `customize` to configure
sound. You will need to set the `audio` subkey—defaulted to `none`—to one of
[the options VirtualBox supports](https://www.virtualbox.org/manual/ch08.html#vboxmanage-modifyvm-other)
for `VBoxManage modifyvm --audio`. For example:

```yaml
driver:
  customize:
    audio: oss
```

### guest

**Note:** It should largely be the responsibility of the underlying Vagrant
base box to properly set the `config.vm.guest` value. For example, if the base
box is a Windows operating system, then Vagrant will be unable to even boot it
(using `vagrant up`), without a custom Vagrantfile. If you are authoring a base
box, please take care to set your value for communicator to give your users the
best possible out-of-the-box experience.

For overriding the default guest setting of the base box.

The default is unset, or `nil`.

### gui

Allows GUI mode for each defined platform. Default is **nil**. Value is passed
to the `config.vm.provider` but only for the VirtualBox and VMware-based
providers.

```yaml
platforms:
  - name: ubuntu-24.04
    driver:
      gui: true
```

will generate a Vagrantfile configuration similar to:

```ruby
Vagrant.configure("2") do |config|
  # ...

  c.vm.provider :virtualbox do |p|
    p.gui = true
  end
end
```

For more info about GUI vs. Headless mode please see [vagrant configuration docs][vagrant_config_vbox]

### linked_clone

Allows to use linked clones to import boxes for VirtualBox, VMware, Parallels Desktop and Hyper-V. Default is **nil**.

```yaml
platforms:
  - name: ubuntu-24.04
    driver:
      linked_clone: true
```

will generate a Vagrantfile configuration similar to:

#### VirtualBox, VMware and Parallels Desktop

```ruby
Vagrant.configure("2") do |config|
  # ...

  c.vm.provider :virtualbox do |p|
    p.linked_clone = true
  end
end
```

#### Hyper-V

```ruby
Vagrant.configure("2") do |config|
  # ...

  c.vm.provider :hyperv do |p|
    p.linked_clone = true
  end
end
```

### network

An **Array** of network customizations for the virtual machine. Each Array
element is itself an Array of arguments to be passed to the `config.vm.network`
method. For example:

```yaml
driver:
  network:
    - ["forwarded_port", {guest: 80, host: 8080}]
    - ["private_network", {ip: "192.168.33.33"}]
```

will generate a Vagrantfile configuration similar to:

```ruby
Vagrant.configure("2") do |config|
  # ...

  config.vm.network :forwarded_port, guest: 80, host: 8080
  config.vm.network :private_network, ip: "192.168.33.33"
end
```

Please read the Vagrant [networking basic usage][vagrant_networking] page for
more details.

The default is an empty Array, `[]`.

### pre_create_command

An optional hook to run a command immediately prior to the
`vagrant up --no-provisioner` command being executed.

There is an optional token, `{{vagrant_root}}` that can be used in the
`pre_create_command` string which will be expanded by the driver to be the full
path to the sandboxed Vagrant root directory containing the Vagrantfile. This
command will be executed from the directory containing the .kitchen.yml file,
or the `kitchen_root`.

For example, if your project requires
[Bindler](https://github.com/fgrehm/bindler), this command could be:

```yaml
driver
  pre_create_command: cp .vagrant_plugins.json {{vagrant_root}}/ && vagrant plugin bundle
```

The default is unset, or `nil`.

### provider

This determines which Vagrant provider to use. The value should match
the provider name in Vagrant. For example, to use VMware Fusion the provider
should be `vmware_fusion`. Please see the docs on [providers][vagrant_providers]
for further details.

By default the value is unset, or `nil`. In this case the driver will use the
Vagrant [default provider][vagrant_default_provider] which at this current time
is `virtualbox` unless set by `VAGRANT_DEFAULT_PROVIDER` environment variable.

### provision

Set to true if you want to do the provision of vagrant in create.
Useful in case of you want to customize the OS in provision phase of vagrant

### ssh_key

This is the path to the private key file used for SSH authentication if you
would like to use your own private ssh key instead of the default vagrant
insecure private key.

If this value is a relative path, then it will be expanded relative to the
location of the main Vagrantfile. If this value is nil, then the default
insecure private key that ships with Vagrant will be used.

The default value is unset, or `nil`.

### synced_folders

Allow the user to specify a collection of synced folders on each Vagrant
instance. Source paths can be relative to the kitchen root.

The default is an empty Array, or `[]`. The example:

```yaml
---
driver:
  synced_folders:
    - ["data/%{instance_name}", "/opt/instance_data"]
    - ["/host_path", "/vm_path", "create: true, type: :nfs"]
```

will generate a Vagrantfile configuration similar to:

```ruby
Vagrant.configure("2") do |config|
  # ...

  c.vm.synced_folder "/Users/mray/cookbooks/pxe_dust/data/default-ubuntu-1204", "/opt/instance_data"
  c.vm.synced_folder "/host_path", "/vm_path", create: true, type: :nfs
end
```

### cache_directory

Customize the cache directory on the Vagrant instance. This parameter must be an
absolute path.

The defaults are:

- Windows: `C:\\omnibus\\cache`
- Unix: `/tmp/omnibus/cache`

The example:

```yaml
---
driver:
  cache_directory: Z:\\custom\\cache
```

To disable usage of cache directory set `cache_directory` parameter to `false`.

### kitchen_cache_directory

Customize the kitchen cache directory on the system running Test Kitchen. This parameter must be an
absolute path.

The defaults are:

- Windows: `~/.kitchen/cache`
- Unix: `~/.kitchen/cache`

The example:

```yaml
---
driver:
  kitchen_cache_directory: Z:\\custom\\kitchen_cache
```

### use_cached_chef_client

Allows for use of Chef Infra Client installers downloaded during previous Test Kitchen runs from the cache folder on a non-Bento customized build Vagrant box image.
The `Guest Additions` tools must be installed in the box image to support shared folder.

The default is `false`

The example:

```yaml
---
driver:
  use_cached_chef_client: true
```

### vagrantfile_erb

An alternate Vagrantfile ERB template that will be rendered for use by this
driver. The binding context for the ERB processing is that of the Driver
object, which means that methods like `config[:kitchen_root]`, `instance.name`,
and `instance.provisioner[:run_list]` can be used to compose a custom
Vagrantfile if necessary.

```yaml
---
driver:
  vagrantfile_erb: CustomVagrantfile.erb
```

**Warning:** Be cautious when going down this road as your setup may cease to
be portable or applicable to other Test Kitchen Drivers such as Ec2 or Docker.
Using the alternative Vagrantfile template strategy may be a dangerous
road--be aware.

The default is to use a template which ships with this gem.

### vagrantfiles

An array of paths to other Vagrantfiles to be merged with the default one. The
paths can be absolute or relative to the .kitchen.yml file.

**Note:** the Vagrantfiles must have a .rb extension to satisfy Ruby's
Kernel#require.

```yaml
---
driver:
  vagrantfiles:
    - VagrantfileA.rb
    - /tmp/VagrantfileB.rb
```

### vm_hostname

Sets the internal hostname for the instance. This is not used when connecting
to the Vagrant virtual machine.

To prevent this value from being rendered in the default Vagrantfile, you can
set this value to `false`.

The default will be computed from the name of the instance. For example, the
instance was called "default-fuzz-9" will produce a default `vm_hostname` value
of `"default-fuzz-9"`. For Windows-based platforms, a default of `nil` is used
to save on boot time and potential rebooting.

```yaml
---
platforms:
  - name: ubuntu-24.04
    driver:
      vm_hostname: server1.example.com
```

will generate a Vagrantfile configuration similar to:

```ruby
Vagrant.configure("2") do |config|
  # ...

  config.vm.hostname = "server1.example.com"
end
```

For more details on this setting please read the [config.vm.hostname](https://developer.hashicorp.com/vagrant/docs/vagrantfile/machine_settings) section of the Vagrant documentation.

## Example **kitchen.yml**

```yaml
---
driver:
  name: vagrant

provisioner:
  name: chef_infra

verifier:
  name: inspec

platforms:
  - name: ubuntu-24.04
  - name: almalinux-10
  - name: windows-2022
    driver:
      box: my-custom-box
      box_url: https://example.com/my_custom_windows_2022_box.box

suites:
  - name: default
    attributes:
      cookbook:
        attribute: 'value'
    run_list:
      - recipe[cookbook::default]
```

[bento]:                    https://github.com/chef/bento
[bento_org]:                https://portal.cloud.hashicorp.com/vagrant/discover/bento
[fusion_dl]:                https://www.vmware.com/products/desktop-hypervisor/workstation-and-fusion
[hyperv_about]:             https://learn.microsoft.com/virtualization/hyper-v-on-windows/about/
[parallels_dl]:             https://www.parallels.com/products/desktop/download/
[parallels_plugin]:         https://parallels.github.io/vagrant-parallels/docs/installation/
[vagrant_cachier]:          https://github.com/fgrehm/vagrant-cachier
[vagrant_cloud]:            https://app.vagrantup.com/boxes/search
[vagrant_config_vbox]:      https://developer.hashicorp.com/vagrant/docs/providers/virtualbox/configuration
[vagrant_config_vmware]:    https://developer.hashicorp.com/vagrant/docs/providers/vmware/configuration
[vagrant_default_provider]: https://developer.hashicorp.com/vagrant/docs/providers/default
[vagrant_machine_settings]: https://developer.hashicorp.com/vagrant/docs/vagrantfile/machine_settings
[vagrant_networking]:       https://developer.hashicorp.com/vagrant/docs/networking/basic_usage
[vagrant_providers]:        https://developer.hashicorp.com/vagrant/docs/providers
[vagrant_versioning]:       https://developer.hashicorp.com/vagrant/docs/boxes/versioning
[vbox_ide_boot]:            https://www.virtualbox.org/ticket/6979
[virtualbox_dl]:            https://www.virtualbox.org/wiki/Downloads
[vmware_plugin]:            https://developer.hashicorp.com/vagrant/docs/providers/vmware
[ws_dl]:                    https://www.vmware.com/products/desktop-hypervisor/workstation-and-fusion
