## 1.2.1 / 2014-02-12

### Bug fixes

* Issue [#357][], pull request [#358][]: Load needed (dynamic) dependencies for provisioners at creation time to prevent any native or dynamic code being loaded in a non-main thread (an issue on Mac with MRI Ruby 1.9/2.0). ([@fnichol][])

### Improvements

* Pull request [#358][]: Output the loaded version of Berkshelf or Librarian-Chef when converging to better help troubleshooting issues. ([@fnichol][])


## 1.2.0 / 2014-02-11

### Upstream changes

* Pull request [#288][]: Update omnibus URL to getchef.com. ([@juliandunn][])

### Bug fixes

* Pull request [#353][]: Ensure that a chef-client failure returns non-zero exit code for chef-client-zero.rb shim script. ([@kamalim][])
* Pull request [#318][]: Upload chef clients data. ([@jtimberman][])
* Issue [#282][], issue [#316][]: [CLI] Match a specific instance before trying to find with a regexp. ([@fnichol][])
* Issue [#305][]: Ensure that `kitchen help` exits non-zero on failure. ([@fnichol][])
* Pull request [#296][]: Fixing error when using more than one helper. ([@jschneiderhan][])
* Pull request [#313][]: Allow files in subdirectories in "helpers" directory. ([@mthssdrbrg][])
* Pull request [#309][]: Add `/opt/local/bin` to instance path when installing Chef Omnibus package. Smartmachines need this otherwise curl can't find certificates. ([@someara][])
* Pull request [#283][], pull request [#287][], pull request [#310][]: Fix failing minitest test on Windows. ([@rarenerd][])
* Fix testing regressions for Ruby 1.9.2 around YAML parsing. ([@fnichol][])

### New features

* Pull request [#286][]: **Experimental** Basic shell provisioner, first non-Chef addition! Still considered experimental, that is subject to change between releases until APIs stabilize. ([@ChrisLundquist][])
* Pull request [#293][], pull request [#277][], issue [#176][]: Add `--concurrency` option to specify number of multiple actions to perform at a time. ([@ryotarai][], [@bkw][])
* Support `--concurrency` without value, defaulting to all instances and begin to deprecate `--parallel` flag. ([@fnichol][])
* Pull request [#306][], issue [#304][]: Add local & global file locations with environment variables (`KITCHEN_LOCAL_YAML` and `KITCHEN_GLOBAL_YAML`). ([@fnichol][])
* Pull request [#298][]: Base provisioner refactoring to start accommodating other provisioners. For more details, see [#298][]. ([@fnichol][])

### Improvements

* Pull request [#280][]: Add `json_attributes: true` config option to ChefZero provisioner. This option allows a user to invoke chef-client without passing the generated JSON file in the `--json-attributes` option. ([@fnichol][])
* Make `kitchen login` work without args if there is only one instance (thank goodness). ([@fnichol][])
* Issue [#285][]: Greatly improved error recovery & reporting in Kitchen::Loader::YAML. ([@fnichol][])
* Pull request [#303][]: Use SafeYAML.load to avoid YAML monkeypatch in safe_yaml. This will leave YAML loading in Test Kitchen as implementation detail and avoid polluting other Ruby objects. ([@fnichol][])
* Pull request [#302][]: CLI refactoring to remove logic from cli.rb. ([@fnichol][])
* Add Ruby 2.1.0 to TravisCI testing matrix. ([@fnichol][])


## 1.1.1 / 2013-12-08

### Bug fixes

* Normalize driver, provisioner, & busser blocks when merging raw YAML. ([@fnichol][])
* Issue [#276][], issue [#278][]: Ensure `Busser#local_suite_files` only rejects chef data dirs. ([@fnichol][])
* Pull request [#275][]: Fix SSH 'Too many authentication failures' error. ([@zts][])
* When copying `./cookbooks`, conditionally check for `./site-cookbooks`. ([@fnichol][])

### Improvements

* Improve `kitchen diagnose` when loader data merging fails. ([@fnichol][])


## 1.1.0 / 2013-12-04

### Default updates

* Set `Busser[:sudo]` to `true` by default (formerly set to `false` by default). ([@fnichol][])

### Improvements

* Pull request [#272][]: Drive by typo fix. ([@kisoku][])


## 1.0.0 / 2013-12-01

### Bug fixes

* Ensure Kitchen::Busser can stream multiple files (split with ;). ([@fnichol][])


## 1.0.0.rc.2 / 2013-11-30

### Changes

* Generate a more explict form for driver & provisioner in `kitchen init`. ([@fnichol][])
* Set `Busser[:sudo]` to `false` by default. ([@fnichol][])

### Bug fixes

* Properly handle `encrypted_data_bag_secret_key_path` under a suite. ([@fnichol][])
* Pull request [#265][]: Busser Fixes for Greybeard UNIX. ([@schisamo][])
* Pull request [#265][]: Busser config key name is `sudo` not `use_sudo`. ([@schisamo][])

### New features

* Add diagnostic facility to Test Kitchen, usable with `kitchen diagnose`. ([@fnichol][])

### Improvements

* Pull request [#266][]: Generate more a helpful error when supplying an invalid Regexp with CLI. ([@fnichol][])
* Improve logging of file transfers to instances in converge action. ([@fnichol][])
* Add feature test coverage for `kitchen list` subcommand. ([@fnichol][])


## 1.0.0.rc.1 / 2013-11-28

### Changes

* Busser now installs into /tmp/busser by default on instances. ([@fnichol][])
* Test Kitchen now works out of /tmp/kitchen for all providers by default. ([@fnichol][])
* Remove Chef Omnibus `GEM_PATH` inclusion in Busser `GEM_PATH`. This fully isolates Busser and its runner plugins to a `GEM_HOME` and `GEM_PATH` in `<busser_root_path>/gems`. ([@fnichol][])
* Add --provisioner to `kitchen init` to override default, chef\_solo. ([@fnichol][])

### Bug fixes

* Issue [#240][], issue [#242][], pull request [#258][]: Fix Busser and Chef Zero sandboxing so that each tool is completely isolated from the Omnibus packages gems and each other. ([@fnichol][], [@schisamo][])

### New features

* Beef up Provisioners so that they resemble Drivers with user, default, inherited, and computed configuration..
* Use `chef-client -z` (local mode) with ChefZero Provisioner for Chef versions >= 11.8.0. Support older versions of Chef with a best-effort fallback shim to use chef-zero. ([@fnichol][])
* `kitchen list --debug` mode greatly improved showing rendered configuration for each Instance's Driver, Provisioner, and Busser configuration. ([@fnichol][])
* Pull request [#249][]: Add a data\_path which will be sync'd to the instance in the same manner as roles and data bags. ([@oferrigni][])
* Test Kitchen no longer requires a cookbook to run; kitchen init anywhere! ([@fnichol][])
* All settings in solo.rb (for ChefSolo) and client.rb (for ChefZero) can be modified or added with a `solo_rb:` or `client_rb:` block inside a `provisioner:` block. ([@fnichol][])
* Add :ruby_bindr in a busser config block to set Busser's alternative remote path to Ruby. ([@fnichol][])
* Busser install root can be configured and is relocatable, defaults to /tmp/busser. ([@fnichol][])
* Test Kitchen root can be configured and is relocatable, defaults to /tmp/kitchen. ([@fnichol][])
* Support installing a specific version of Busser. ([@fnichol][])

### Improvements

* Greatly simplify default .kitchen.yml. ([@fnichol][], [@sethvargo][])
* Massive internal refactoring data manipulation logic. Data code now lives in Kitchen::DataMunger and was properly TDD'ed from the ground up with a full test suite. ([@fnichol][])
* `require_chef_ommnibus` will default to `true` for all Chef provisioners and so can be omitted from .kitchen.yml files in most cases. ([@fnichol][])
* Pull request [#262][]: Use a configurable glob pattern to select Chef cookbook files. ([@fnichol][])
* Pull request [#141][]: Do not create a gitignore if there is no git repo. ([@sethvargo][])
* Improve `kitchen init` smarts for detecting gems already in Gemfile. ([@fnichol][])
* Expand all Chef-related local paths in Provisioner::ChefBase. ([@fnichol][])
* Issue [#227][]: Handle absolute paths. ([@sethvargo][])
* Cope with nil values for run\_list and attributes entries in .kitchen.yml. ([@fnichol][])
* Allow for nil values for `provisioner:`, `driver:`, & `busser:`. ([@fnichol][])
* Pull request [#253][]: Fix TravisCI badges. ([@arangamani][])
* Pull request [#254][]: Update references to test-kitchen org. ([@josephholsten][])
* Pull request [#256][]: Changed 'passed' to 'passing' in the Destroy options documentation. ([@scarolan][])
* Pull request [#259][]: Fix inconsistent date in CHANGELOG. ([@ryansouza][])
* Extract Berkshelf & Librarian-Chef resolver code to classes. ([@fnichol][])
* Full spec coverage for Suite. ([@fnichol][])
* Full spec coverage for Platform. ([@fnichol][])
* Full spec coverage for Instance. ([@fnichol][])
* Full spec coverage for Kitchen::Provisioner.for\_plugin ([@fnichol][])


## 1.0.0.beta.4 / 2013-11-01

### Bug fixes

* Change permissions on the Chef sandbox to world readable and writable (0755) ([@fnichol][])
* Minor typographical and documentation errors ([@gmiranda23][])
* Improve error message when Berkshelf/Librarian is not present ([@fnichol][])
* Ensure busser respects the `sudo` driver configuration ([@schisamo][])

### Improvements

* Pull request [#235][]: Add Chef Solo environment support ([@ekrupnik][])
* Pull request [#231][]: Use chefignore to determine which files to copy ([@rteabeault][])
* Pull request [#222][]: Remove dependency on Celluloid and use pure Ruby threads ([@sethvargo][])
* Pull request [#218][]: Add support for `site-cookbooks` ([@hollow][])
* Pull request [#217][]: Add support for specific driver configs ([@hollow][])
* Pull request [#206][]: Add pessismestic locks on all gem requirements ([@sethvargo][])
* Pull request [#193][]: Allow users to configure ssh forwarding ([@fnordfish][])
* Pull request [#192][]: Add chef config has and proxy information ([@scotthain][])
* Pull request [#94][]: Support passing multiple instance names ([@sethvargo][])
* Drop hard dependency on `pry` gem for `kitchen console` ([@fnichol][])
* Remove bash-specific code in favor of pure sh for non-standard Unix devices ([@schisamo][])
* Make remote RUBY_BIN configurable ([@schisamo][])
* Ensure busser and Chef Zero are executed in their own the sandboxes ([@schisamo][])


## 1.0.0.beta.3 / 2013-08-29

### Bug fixes

* Pull request [#157][]: Include definitions directory when uploading the cookbooks. ([@jasonroelofs][])
* Pull request [#178][]: Fix SSH#wait's logger call to #info. ([@ryansouza][])
* Pull request [#188][]: Truthy default_configs can now be overridden. ([@thommay][])

### Improvements

* Allow Test Kitchen to be used as a library; CWD is not enough. ([@portertech][])
* Add `kitchen list --debug` to display all merged & calculated config. ([@fnichol][])
* Add retry logic to Kitchen:SSH when initiating a connection. ([@fnichol][])
* Pull request [#147][]: Allow chef omnibus install.sh url to be configurable. ([@jrwesolo][])
* Pull request [#187][]: Add support for log file in chef solo. ([@arangamani][])
* Pull request [#179][]: Remove bundler references from README. ([@juliandunn][])
* Compute default test_base_path in Config based on kitchen_root. ([@fnichol][])


## 1.0.0.beta.2 / 2013-07-24

### Bug fixes

* Fix backwards compatability regression in `SSHBase#wait_for_sshd`. ([@fnichol][])


## 1.0.0.beta.1 / 2013-07-23

### New features

* Pull request [#128][]: [Breaking] Introduce Provisioners to support chef-client (chef-zero), puppet-apply, and puppet-agent. ([@fnichol][])
* Pull request [#128][]: Add `chef_zero` provisioner type as an alternative to the iplicit default `chef_solo` provisioner. ([@fnichol][])
* Pull request [#171][]: Support computed default values for Driver authors (see pull request for light documentation). ([@fnichol][])
* Pull request [#161][], issue [#129][]: Allow custom paths for roles, data\_bags, and nodes by setting `roles_path`, `data_bags_path`, and `nodes_path`. ([@gondoi][])
* Pull request [#134][]: Add cross suite helpers. ([@rteabeault][])

### Bug fixes

* Pull request [#122][]: Adding missing sudo calls to busser. ([@adamhjk][])
* Pull request [#154][], issue [#163][]: Set a more sane default PATH for installing Chef. ([@jtimberman][])
* Issue [#153][]: Assign Celluloid.logger to Kitchen.logger which won't open a file. ([@fnichol][])
* Pull request [#155][], issue [#154][]: Setting :on_black when your default terminal text color is black results in unreadable (black on black) text. Or: The NSA censors your VM names when using a terminal with a light background. ([@mconigliaro][])
* Pull request [#140][]: Make `kitchen init` generator safe to run when given an explicit `:destination_root`. ([@reset][])
* Pull request [#170][]: Add asterisk to wait_for_sshd argument. ([@saketoba][])
* Pull request [#136][]: Fixes bundler ref for 1.0. ([@patcon][])
* Pull request [#142][], issue [#137][]: Require a safe\_yaml release with correct permissions. ([@josephholsten][])

### Improvements

* Pull request [#128][]: Add Driver and Provisioner columns to `kitchen list` output. ([@fnichol][])
* Pull request [#124][], issue [#132][]: Aggressively filter "non-cookbook" files before uploading to instances. ([@fnichol][])
* Pull request [#128][]: Suite run_list is no longer required. ([@fnichol][])
* Pull request [#123][]: Swap cookbook resolution strategy from shell outs to using Ruby APIs. ([@fnichol][])
* Pull request [#128][]: SSH and SCP commands share a single connection when transfering Chef artifacts to an instance (via the new `Kitchen::SSH` class). ([@fnichol][])
* Pull request [#128][]: Add more helpful output logging (info and debug) when creating and uploading the sandbox directory of Chef artifacts. ([@fnichol][])
* Issue [#97][]: Remove red as a candidate instance color. ([@fnichol][])
* Fix ANSI color codes for bright colors. ([@fnichol][])
* Pull request [#172][]: [Breaking] Update signature of Driver.required_config block. ([@fnichol][])
* Pull request [#152][], issue [#151][]: Update the bucket name for Opscode's Bento Boxes. ([@jtimberman][])
* Pull request [#131][]: Use ssh_args for test_ssh. ([@jonsmorrow][])


## 1.0.0.alpha.7 / 2013-05-23

### New features

* Pull request [#90][], issue [#31][]: Add a global user-level config file, located at `~/.kitchen/config.yml`. ([@thommay][])
* Pull request [#102][]: Allow a way to override remote sudo. ([@calavera][])
* Propagate default\_config from base driver classes into subclasses. ([@fnichol][])
* Pull request [#120][]: Add http and https_proxy support. ([@adamhjk][])
* Pull request [#111][]: Sink. Yeah, that one. ([@sethvargo][])

### Bug fixes

* Pull request [#99][], issue [#98][]: Ensure that destroy option is respected when --parallel is used. ([@stevendanna][])
* Pull request [#116][]: Require the 'name' attribute is present in `metadata.rb`. ([@sethvargo][])
* Pull request [#113][]: Handle case where YAML parses as nil. ([@smith][])
* Pass original exception's backtrace to InstanceFailure and ActionFailed. ([@fnichol][])
* Pull request [#112][]: Fix bug where action failures are swallowed with a nil inside an ensure. ([@manul][])

### Improvements

* Pull request [#104][]: Set the default ssh port in Driver::SSHBase. ([@calavera][])
* Pull request [#114][]: Update kitchen.yml template with provisionerless baseboxes. ([@jtimberman][])
* Pull request [#119][]: Test Kitchen works on Windows with Vagrant. ([@adamhjk][])
* Pull request [#108][]: Add version string to "Starting Kitchen" logging output. ([@fnichol][])
* Pull request [#105][]: Expand documentation around run-time switches in README. ([@grahamc][])


## 1.0.0.alpha.6 / 2013-05-08

### New features

* Pull request [#77][]: Support encrypted data bag secrets ([@arunthampi][])
* Issue [#92][]: Support single cookbook with no dependencies and no Berksfile. ([@fnichol][])

### Bug fixes

* Fix Omnibus installation on nodes using plain sh (vs. bash). ([@fnichol][])

### Improvements

* Issue [#84][]: Fix `kitchen list` heading alignment. ([@fnichol][])


## 1.0.0.alpha.5 / 2013-04-23

### Improvements

* Pull request [#81][]: Clean up error reporting in CLI output. ([@fnichol][])
* Pull request [#76][]: Swap out shell-based kb for Ruby-based Busser gem. ([@fnichol][])
* Pull request [#82][], issue [#61][]: Install Omnibus package via either wget or curl. ([@fnichol][])
* Catch YAML data merging errors as user errors. ([@fnichol][])
* Issue [#80][]: Add a more helpful error message when a driver could not be loaded. ([@fnichol][])


## 1.0.0.alpha.4 / 2013-04-10

### Bug fixes

* #get_all_instances must return actors in parallel mode in CLI. ([@fnichol][], [@bryanwb][]).

### Improvements

* Refactor `kitchen plugin create` to drop Bundler dependency completely. ([@fnichol][])


## 1.0.0.alpha.3 / 2013-04-05

### Bug fixes

* Fix :require_chef_omnibus driver_config option to eliminate re-installation ([@fnichol][])
* Remove implicit Bundler dependency in `kitchen init`. ([@fnichol][])

### New features

* Add --auto-init flag to `kitchen test` (default: false) ([@fnichol][])

### Improvements

* Update base box URLs. ([@fnichol][])
* Extract .kitchen.yml to an ERB template & update box URLs. ([@fnichol][])
* Add more spec coverage. ([@fnichol][])


## 1.0.0.alpha.2 / 2013-03-28

### Bug fixes

* Remove catch-all rescue in Driver.for_plugin (reason provided in commit message). ([@fnichol][])

### New features

* Add --log-level flag to CLI for test, create, converge, setup, verify, destroy, and login actions. The environment variable `KITCHEN_LOG` may still be used to also set the logging level. ([@fnichol][])
* Driver::SSHBase and subclass drivers now support setting a :port number in .kitchen.yml or in instance state. ([@fnichol][])

### Improvements

* Support thor 0.16.0 and 0.17.0+. ([@fnichol][])
* Support SSH config from #state & #config in Driver::SSHBase, helping drivers such as kitchen-vagrant. ([@fnichol][])


## 1.0.0.alpha.1 / 2013-03-22

### Bug fixes

* Support (and test) for Rubygems 2.0.x and 1.8.x. ([@fnichol][])

### New features

* Pull request [#71][]: Updates to `kitchen init` to be non-interactive (add `--driver` flag), add subcommand support, and introduce `kitchen driver discover`. ([@fnichol][])
* Add `Driver#verify_dependencies` to be invoked once when Driver is loaded. ([@fnichol][])

### Improvements

* Pull request [#73][]: [Breaking] Modify `ShellOut#run_command` to take an options Hash. ([@fnichol][])
* Add :quiet option on `ShellOut#run_command`. ([@fnichol][])
* [Breaking] `Driver#login_command` returns a Driver::LoginCommand object. ([@fnichol][])
* Pull request [#74][]: Switch driver alias (-d) to (-D) in Init generator ([@reset][])
* Pull request [#64][]: Make `require_chef_omnibus: true` safe. ([@mattray][])
* Pull request [#65][]: Fix for line length and style (tailor). ([@ChrisLundquist][])


## 1.0.0.alpha.0 / 2013-03-02

The initial release.

<!--- The following link definition list is generated by PimpMyChangelog --->
[#31]: https://github.com/opscode/test-kitchen/issues/31
[#61]: https://github.com/opscode/test-kitchen/issues/61
[#64]: https://github.com/opscode/test-kitchen/issues/64
[#65]: https://github.com/opscode/test-kitchen/issues/65
[#71]: https://github.com/opscode/test-kitchen/issues/71
[#73]: https://github.com/opscode/test-kitchen/issues/73
[#74]: https://github.com/opscode/test-kitchen/issues/74
[#76]: https://github.com/opscode/test-kitchen/issues/76
[#77]: https://github.com/opscode/test-kitchen/issues/77
[#80]: https://github.com/opscode/test-kitchen/issues/80
[#81]: https://github.com/opscode/test-kitchen/issues/81
[#82]: https://github.com/opscode/test-kitchen/issues/82
[#84]: https://github.com/opscode/test-kitchen/issues/84
[#90]: https://github.com/opscode/test-kitchen/issues/90
[#92]: https://github.com/opscode/test-kitchen/issues/92
[#94]: https://github.com/opscode/test-kitchen/issues/94
[#97]: https://github.com/opscode/test-kitchen/issues/97
[#98]: https://github.com/opscode/test-kitchen/issues/98
[#99]: https://github.com/opscode/test-kitchen/issues/99
[#102]: https://github.com/opscode/test-kitchen/issues/102
[#104]: https://github.com/opscode/test-kitchen/issues/104
[#105]: https://github.com/opscode/test-kitchen/issues/105
[#108]: https://github.com/opscode/test-kitchen/issues/108
[#111]: https://github.com/opscode/test-kitchen/issues/111
[#112]: https://github.com/opscode/test-kitchen/issues/112
[#113]: https://github.com/opscode/test-kitchen/issues/113
[#114]: https://github.com/opscode/test-kitchen/issues/114
[#116]: https://github.com/opscode/test-kitchen/issues/116
[#119]: https://github.com/opscode/test-kitchen/issues/119
[#120]: https://github.com/opscode/test-kitchen/issues/120
[#122]: https://github.com/opscode/test-kitchen/issues/122
[#123]: https://github.com/opscode/test-kitchen/issues/123
[#124]: https://github.com/opscode/test-kitchen/issues/124
[#128]: https://github.com/opscode/test-kitchen/issues/128
[#129]: https://github.com/opscode/test-kitchen/issues/129
[#131]: https://github.com/opscode/test-kitchen/issues/131
[#132]: https://github.com/opscode/test-kitchen/issues/132
[#134]: https://github.com/opscode/test-kitchen/issues/134
[#136]: https://github.com/opscode/test-kitchen/issues/136
[#137]: https://github.com/opscode/test-kitchen/issues/137
[#140]: https://github.com/opscode/test-kitchen/issues/140
[#141]: https://github.com/opscode/test-kitchen/issues/141
[#142]: https://github.com/opscode/test-kitchen/issues/142
[#147]: https://github.com/opscode/test-kitchen/issues/147
[#151]: https://github.com/opscode/test-kitchen/issues/151
[#152]: https://github.com/opscode/test-kitchen/issues/152
[#153]: https://github.com/opscode/test-kitchen/issues/153
[#154]: https://github.com/opscode/test-kitchen/issues/154
[#155]: https://github.com/opscode/test-kitchen/issues/155
[#157]: https://github.com/opscode/test-kitchen/issues/157
[#161]: https://github.com/opscode/test-kitchen/issues/161
[#163]: https://github.com/opscode/test-kitchen/issues/163
[#170]: https://github.com/opscode/test-kitchen/issues/170
[#171]: https://github.com/opscode/test-kitchen/issues/171
[#172]: https://github.com/opscode/test-kitchen/issues/172
[#176]: https://github.com/opscode/test-kitchen/issues/176
[#178]: https://github.com/opscode/test-kitchen/issues/178
[#179]: https://github.com/opscode/test-kitchen/issues/179
[#187]: https://github.com/opscode/test-kitchen/issues/187
[#188]: https://github.com/opscode/test-kitchen/issues/188
[#192]: https://github.com/opscode/test-kitchen/issues/192
[#193]: https://github.com/opscode/test-kitchen/issues/193
[#206]: https://github.com/opscode/test-kitchen/issues/206
[#217]: https://github.com/opscode/test-kitchen/issues/217
[#218]: https://github.com/opscode/test-kitchen/issues/218
[#222]: https://github.com/opscode/test-kitchen/issues/222
[#227]: https://github.com/opscode/test-kitchen/issues/227
[#231]: https://github.com/opscode/test-kitchen/issues/231
[#235]: https://github.com/opscode/test-kitchen/issues/235
[#240]: https://github.com/opscode/test-kitchen/issues/240
[#242]: https://github.com/opscode/test-kitchen/issues/242
[#249]: https://github.com/opscode/test-kitchen/issues/249
[#253]: https://github.com/opscode/test-kitchen/issues/253
[#254]: https://github.com/opscode/test-kitchen/issues/254
[#256]: https://github.com/opscode/test-kitchen/issues/256
[#258]: https://github.com/opscode/test-kitchen/issues/258
[#259]: https://github.com/opscode/test-kitchen/issues/259
[#262]: https://github.com/opscode/test-kitchen/issues/262
[#265]: https://github.com/opscode/test-kitchen/issues/265
[#266]: https://github.com/opscode/test-kitchen/issues/266
[#272]: https://github.com/opscode/test-kitchen/issues/272
[#275]: https://github.com/opscode/test-kitchen/issues/275
[#276]: https://github.com/opscode/test-kitchen/issues/276
[#277]: https://github.com/opscode/test-kitchen/issues/277
[#278]: https://github.com/opscode/test-kitchen/issues/278
[#280]: https://github.com/opscode/test-kitchen/issues/280
[#282]: https://github.com/opscode/test-kitchen/issues/282
[#283]: https://github.com/opscode/test-kitchen/issues/283
[#285]: https://github.com/opscode/test-kitchen/issues/285
[#286]: https://github.com/opscode/test-kitchen/issues/286
[#287]: https://github.com/opscode/test-kitchen/issues/287
[#288]: https://github.com/opscode/test-kitchen/issues/288
[#293]: https://github.com/opscode/test-kitchen/issues/293
[#296]: https://github.com/opscode/test-kitchen/issues/296
[#298]: https://github.com/opscode/test-kitchen/issues/298
[#302]: https://github.com/opscode/test-kitchen/issues/302
[#303]: https://github.com/opscode/test-kitchen/issues/303
[#304]: https://github.com/opscode/test-kitchen/issues/304
[#305]: https://github.com/opscode/test-kitchen/issues/305
[#306]: https://github.com/opscode/test-kitchen/issues/306
[#309]: https://github.com/opscode/test-kitchen/issues/309
[#310]: https://github.com/opscode/test-kitchen/issues/310
[#313]: https://github.com/opscode/test-kitchen/issues/313
[#316]: https://github.com/opscode/test-kitchen/issues/316
[#318]: https://github.com/opscode/test-kitchen/issues/318
[#353]: https://github.com/opscode/test-kitchen/issues/353
[#357]: https://github.com/opscode/test-kitchen/issues/357
[#358]: https://github.com/opscode/test-kitchen/issues/358
[@ChrisLundquist]: https://github.com/ChrisLundquist
[@adamhjk]: https://github.com/adamhjk
[@arangamani]: https://github.com/arangamani
[@arunthampi]: https://github.com/arunthampi
[@bkw]: https://github.com/bkw
[@bryanwb]: https://github.com/bryanwb
[@calavera]: https://github.com/calavera
[@ekrupnik]: https://github.com/ekrupnik
[@fnichol]: https://github.com/fnichol
[@fnordfish]: https://github.com/fnordfish
[@gmiranda23]: https://github.com/gmiranda23
[@gondoi]: https://github.com/gondoi
[@grahamc]: https://github.com/grahamc
[@hollow]: https://github.com/hollow
[@jasonroelofs]: https://github.com/jasonroelofs
[@jonsmorrow]: https://github.com/jonsmorrow
[@josephholsten]: https://github.com/josephholsten
[@jrwesolo]: https://github.com/jrwesolo
[@jschneiderhan]: https://github.com/jschneiderhan
[@jtimberman]: https://github.com/jtimberman
[@juliandunn]: https://github.com/juliandunn
[@kamalim]: https://github.com/kamalim
[@kisoku]: https://github.com/kisoku
[@manul]: https://github.com/manul
[@mattray]: https://github.com/mattray
[@mconigliaro]: https://github.com/mconigliaro
[@mthssdrbrg]: https://github.com/mthssdrbrg
[@oferrigni]: https://github.com/oferrigni
[@patcon]: https://github.com/patcon
[@portertech]: https://github.com/portertech
[@rarenerd]: https://github.com/rarenerd
[@reset]: https://github.com/reset
[@rteabeault]: https://github.com/rteabeault
[@ryansouza]: https://github.com/ryansouza
[@ryotarai]: https://github.com/ryotarai
[@saketoba]: https://github.com/saketoba
[@scarolan]: https://github.com/scarolan
[@schisamo]: https://github.com/schisamo
[@scotthain]: https://github.com/scotthain
[@sethvargo]: https://github.com/sethvargo
[@smith]: https://github.com/smith
[@someara]: https://github.com/someara
[@stevendanna]: https://github.com/stevendanna
[@thommay]: https://github.com/thommay
[@zts]: https://github.com/zts