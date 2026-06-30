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
| [kitchen-cloudstack](https://github.com/test-kitchen/kitchen-cloudstack) | Apache CloudStack |
| [kitchen-digitalocean](https://github.com/test-kitchen/kitchen-digitalocean) | DigitalOcean |
| [kitchen-docker](https://github.com/test-kitchen/kitchen-docker) | Docker |
| [kitchen-dokken](https://github.com/test-kitchen/kitchen-dokken) | Docker or Podman for Chef Infra cookbook testing |
| [kitchen-ec2](https://github.com/test-kitchen/kitchen-ec2) | Amazon EC2 |
| [kitchen-google](https://github.com/test-kitchen/kitchen-google) | Google Compute Engine |
| [kitchen-habitat](https://github.com/test-kitchen/kitchen-habitat) | Chef Habitat |
| [kitchen-hyperv](https://github.com/test-kitchen/kitchen-hyperv) | Microsoft Hyper-V |
| [kitchen-opennebula](https://github.com/test-kitchen/kitchen-opennebula) | OpenNebula |
| [kitchen-openstack](https://github.com/test-kitchen/kitchen-openstack) | OpenStack |
| [kitchen-rackspace](https://github.com/test-kitchen/kitchen-rackspace) | Rackspace Cloud |
| [kitchen-vagrant](https://github.com/test-kitchen/kitchen-vagrant) | HashiCorp Vagrant |
| [kitchen-vcair](https://github.com/test-kitchen/kitchen-vcair) | VMware vCloud Air |
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
| [kitchen-salt](https://github.com/kitchen-salt/kitchen-salt) | Salt |

## Verifiers

Verifiers test the instance after convergence.

| Plugin | Target |
| ------ | ------ |
| [busser-bash](https://github.com/test-kitchen/busser-bash) | Bash tests through the legacy busser verifier |
| [busser-bats](https://github.com/test-kitchen/busser-bats) | BATS tests through the legacy busser verifier |
| [busser-cucumber](https://github.com/test-kitchen/busser-cucumber) | Cucumber tests through the legacy busser verifier |
| [busser-minitest](https://github.com/test-kitchen/busser-minitest) | Minitest tests through the legacy busser verifier |
| [busser-rspec](https://github.com/test-kitchen/busser-rspec) | RSpec tests through the legacy busser verifier |
| [busser-serverspec](https://github.com/test-kitchen/busser-serverspec) | ServerSpec tests through the legacy busser verifier |
| [kitchen-cinc-auditor](https://github.com/test-kitchen/kitchen-cinc-auditor) | Cinc Auditor |
| [kitchen-inspec](https://github.com/inspec/kitchen-inspec) | Chef InSpec |
| [kitchen-pester](https://github.com/test-kitchen/kitchen-pester) | Pester |

## Transports and helpers

| Plugin | Purpose |
| ------ | ------- |
| [kitchen-sync](https://github.com/test-kitchen/kitchen-sync) | Transport plugin for faster file synchronization |
| [guard-kitchen](https://github.com/test-kitchen/guard-kitchen) | Guard integration |

## Historical plugins

Some plugins that existed over Test Kitchen's lifetime may be obsolete,
archived, or superseded by newer drivers. Prefer the plugin's repository,
RubyGems page, and your selected Workstation package metadata when deciding
whether a plugin is still suitable for new work.
