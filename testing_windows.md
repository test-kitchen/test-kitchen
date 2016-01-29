## Testing test-kitchen contributions against windows test instances

### Choose a windows based cookbook
The [windows cookbook](https://github.com/chef-cookbooks/windows) is a grand choice.

### Edit the `Gemfile` 
Ensure that the cookbook's root directory includes a `Gemfile` that includes your local test-kitchen repo as well as required windows-only needed gems:
```
gem 'test-kitchen', path: '../test-kitchen'
gem 'winrm', '~> 1.6'
gem 'winrm-fs', '~> 0.3'
```

### Finding a windows image
Make sure you have a windows test image handy. You can use your favorite cloud or hypervisor. An easy vagrant option is `mwrock/Windows2012R2` which is publicly available on atlas. To use that, edit your cookbook's `.kitchen.yml` to include:
```
platforms:
  - name: win2012r2-standard
    driver_config:
      box: mwrock/Windows2012R2
```

### `bundle install`

From the root of your cookbook directory run `bundle install`

### Converge and test!

Now run `bundle exec kitchen verify`.

If your cookbook has multiple suites (like the windows cookbook), you likely just want to run one:
```
bundle exec kitchen verify feature
```
