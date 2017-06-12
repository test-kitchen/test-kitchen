## Testing test-kitchen contributions against windows test instances

### Choose a windows based cookbook
The [windows cookbook](https://github.com/chef-cookbooks/windows) is a grand choice.

### Edit the `Gemfile` 
Ensure that the cookbook's root directory includes a `Gemfile` that includes your local test-kitchen repo on the branch you would like to test as well as required windows-only needed gems:
```
gem 'test-kitchen', git: 'https://github.com/mwrock/test-kitchen', branch: 'winrm-fs'
gem 'winrm', '~> 1.6'
gem 'winrm-fs', '~> 0.4.1'
gem 'winrm-elevated', '~> 0.4.0'
```
The above would target the `winrm-fs` branch in mwrock's test-kitchen repo.

### Finding a windows image
Make sure you have a windows test image handy. You can use your favorite cloud or hypervisor. An easy vagrant option is `mwrock/Windows2012R2` which is publicly available on atlas. To use that, edit your cookbook's `.kitchen.yml` to include:
```
platforms:
  - name: win2012r2-standard
    driver:
      box: mwrock/Windows2012R2
```

For other windows OS versions, you can spin up instances in your favorite cloud provider or create your own vagrant box. The windows packer templates found in the [boxcutter repo](https://github.com/boxcutter/windows) provide a good place to start here.

### `bundle install`

From the root of your cookbook directory run `bundle install`

### Converge and test!

Now run `bundle exec kitchen verify`.

If your cookbook has multiple suites (like the windows cookbook), you likely just want to run one:
```
bundle exec kitchen verify feature
```
