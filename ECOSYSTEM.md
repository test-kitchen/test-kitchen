# Community and ecosystem plugins

Test Kitchen discovers plugins from the Ruby environment that runs `kitchen`.
That environment might be system Ruby, Bundler, Cinc Workstation, Chef
Workstation, or another packaged distribution. Check that environment before
assuming a plugin is available:

```bash
gem list kitchen-vagrant
chef gem list kitchen-vagrant
```

Install missing plugins into the same environment that runs `kitchen`.

This page lists common Test Kitchen ecosystem plugins. It is not an exhaustive
registry of every historical plugin.

## Drivers

Drivers create and manage test instances.

| Plugin | Target |
| ------ | ------ |
| [kitchen-azurerm](https://github.com/test-kitchen/kitchen-azurerm) | Microsoft Azure |
| [kitchen-digitalocean](https://github.com/test-kitchen/kitchen-digitalocean) | DigitalOcean |
| [kitchen-docker](https://github.com/test-kitchen/kitchen-docker) | Docker |
| [kitchen-dokken](https://github.com/test-kitchen/kitchen-dokken) | Docker or Podman for Chef Infra cookbook testing |
| [kitchen-ec2](https://github.com/test-kitchen/kitchen-ec2) | Amazon EC2 |
| [kitchen-google](https://github.com/test-kitchen/kitchen-google) | Google Compute Engine |
| [kitchen-hyperv](https://github.com/test-kitchen/kitchen-hyperv) | Microsoft Hyper-V |
| [kitchen-openstack](https://github.com/test-kitchen/kitchen-openstack) | OpenStack |
| [kitchen-rackspace](https://github.com/test-kitchen/kitchen-rackspace) | Rackspace Cloud |
| [kitchen-vagrant](https://github.com/test-kitchen/kitchen-vagrant) | HashiCorp Vagrant |
| [kitchen-vcenter](https://github.com/chef/kitchen-vcenter) | VMware vCenter |
| [kitchen-vra](https://github.com/test-kitchen/kitchen-vra) | VMware vRealize Automation |
| [kitchen-vro](https://github.com/test-kitchen/kitchen-vro) | VMware vRealize Orchestrator |

## Provisioners

Provisioners configure an instance after the driver creates it.

| Plugin | Target |
| ------ | ------ |
| [kitchen-ansible](https://github.com/neillturner/kitchen-ansible) | Ansible |
| [kitchen-cinc](https://github.com/test-kitchen/kitchen-cinc) | Cinc Client |
| [kitchen-dsc](https://github.com/test-kitchen/kitchen-dsc) | PowerShell DSC |
| [kitchen-omnibus-chef](https://github.com/test-kitchen/kitchen-omnibus-chef) | Chef Infra Client |
| [kitchen-puppet](https://github.com/neillturner/kitchen-puppet) | Puppet |
| [kitchen-salt](https://github.com/saltstack/kitchen-salt) | Salt |

## Verifiers

Verifiers test the instance after convergence.

| Plugin | Target |
| ------ | ------ |
| [busser-bats](https://github.com/test-kitchen/busser-bats) | BATS tests through the legacy busser verifier |
| [busser-serverspec](https://github.com/test-kitchen/busser-serverspec) | ServerSpec tests through the legacy busser verifier |
| [kitchen-cinc-auditor](https://github.com/test-kitchen/kitchen-cinc-auditor) | Cinc Auditor |
| [kitchen-inspec](https://github.com/inspec/kitchen-inspec) | Chef InSpec |
| [kitchen-pester](https://github.com/test-kitchen/kitchen-pester) | Pester |

## Historical plugins

These plugins are still published, but none has had a release in five or more
years. They may not work with current Test Kitchen, current Ruby, or their
target platform, and some target services that no longer exist. Check the
plugin's repository and RubyGems page, along with your selected Workstation
package metadata, before using one for new work.

| Plugin | Target | Last release |
| ------ | ------ | ------------ |
| [busser-bash](https://github.com/test-kitchen/busser-bash) | Bash tests through the legacy busser verifier | 0.1.4 (2014-10-11) |
| [busser-cucumber](https://github.com/test-kitchen/busser-cucumber) | Cucumber tests through the legacy busser verifier | 0.2.0 (2014-10-08) |
| [busser-minitest](https://github.com/test-kitchen/busser-minitest) | Minitest tests through the legacy busser verifier | 0.3.0 (2014-10-11) |
| [busser-rspec](https://github.com/test-kitchen/busser-rspec) | RSpec tests through the legacy busser verifier | 0.7.6 (2015-09-28) |
| [guard-kitchen](https://github.com/test-kitchen/guard-kitchen) | Guard integration | 0.1.0 (2019-02-25) |
| [kitchen-cloudstack](https://github.com/test-kitchen/kitchen-cloudstack) | Apache CloudStack | 0.24.0 (2019-06-20) |
| [kitchen-habitat](https://github.com/test-kitchen/kitchen-habitat) | Chef Habitat | 0.12.1 (2020-07-29) |
| [kitchen-opennebula](https://github.com/test-kitchen/kitchen-opennebula) | OpenNebula | 0.2.3 (2017-11-23) |
| [kitchen-sync](https://github.com/test-kitchen/kitchen-sync) | Transport plugin for faster file synchronization | 2.2.1 (2018-02-13) |
| [kitchen-vcair](https://github.com/test-kitchen/kitchen-vcair) | VMware vCloud Air (service discontinued) | 1.1.0 (2015-12-17) |

Other plugins that existed over Test Kitchen's lifetime are not listed on this
page at all.
