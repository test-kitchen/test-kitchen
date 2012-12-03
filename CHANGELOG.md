# Release Notes - test-kitchen - Version 0.7.0

### Bug

* [KITCHEN-23] - Generated Kitchenfile should honor cookbook name from metadata.rb

### Improvement

* [KITCHEN-40] - If a cookbook project is included in the default Cheffile, librarian errors out

### New Feature

* [KITCHEN-5] - Create Openstack Runner for test-kitchen
* [KITCHEN-34] - add --version to kitchen command to show test-kitchen's version

### Task

* [KITCHEN-50] - don't exit with `1` if rcov is slipping, just warn
* [KITCHEN-51] - don't add runtimes [] line in cookbook scaffolding

# Release Notes - test-kitchen - Version 0.6.0

### Bug

* [KITCHEN-29] - --platform flag doesn't work for test command.
* [KITCHEN-37] - Let projects inherit runtimes from parents

### Improvement

* [KITCHEN-22] - Include Databags in Vagrant Configuration if present
* [KITCHEN-35] - use the minitest-handler in community.opscode.com
  rather than andew crump's fork

### New Feature

* [KITCHEN-4] - decouple rvm use for running integration/unit tests


# Release Notes - test-kitchen - Version 0.5.4

### Bug

* [KITCHEN-6] - document requirement that a valid "knife.rb" is
  present
* [KITCHEN-18] - scaffold generates Gemfile with private github
  repository for test-kitchen gem
* [KITCHEN-26] - Subsequent calls to `kitchen test` don't converge
  node anymore

### Improvement

* [KITCHEN-8] - Document Autmatic Dependency Resolution via Librarian
  in the README
* [KITCHEN-10] - Add Memory Option to Cookbook Section of the Readme
* [KITCHEN-19] - Constrain foodcritic to major (1.x)

### New Feature

* [KITCHEN-17] - Add lint[:ignore] to cookbook DSL for foodcritic tags
  or rules to ignore


# Release Notes - test-kitchen version 0.5.2

### Bug

* [KITCHEN-1] - remove "remove test-kitchen entry from Gemfile" from
  recipe
* [KITCHEN-2] - update foodcritic version


# Release Notes - test-kitchen version 0.5.0

* Initial Release
