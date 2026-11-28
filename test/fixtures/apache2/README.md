# Apache smoke fixture

Parallels, VirtualBox and Scaleway use this fixture to exercise Cinc, Puppet
and Ansible. Each driver checks in the files from `shared/` under
`examples/apache2/` so the example runs from a standalone checkout.

Edit the canonical files here, then update the driver copies from the
Test Kitchen checkout. Pass the root of each driver checkout.

```sh
ruby test/fixtures/apache2/sync.rb ../kitchen-parallels ../kitchen-virtualbox ../kitchen-scaleway
ruby test/fixtures/apache2/sync.rb --check ../kitchen-parallels ../kitchen-virtualbox ../kitchen-scaleway
```

Each driver owns its `kitchen.yml` and `Policyfile.rb`. The driver selects
the VM source, sets up access and supplies the package bootstrap prefix.
The policy file keeps the provider's policy name.

Publish the Test Kitchen fixture commit before opening driver pull requests.
Update the fixture checkout ref in each driver's `lint.yml` to that commit.
The driver workflow compares the checked-in copies with the pinned files and
loads the example through Kitchen.
