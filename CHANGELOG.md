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
[#178]: https://github.com/opscode/test-kitchen/issues/178
[#179]: https://github.com/opscode/test-kitchen/issues/179
[#187]: https://github.com/opscode/test-kitchen/issues/187
[#188]: https://github.com/opscode/test-kitchen/issues/188
[@ChrisLundquist]: https://github.com/ChrisLundquist
[@adamhjk]: https://github.com/adamhjk
[@arangamani]: https://github.com/arangamani
[@arunthampi]: https://github.com/arunthampi
[@bryanwb]: https://github.com/bryanwb
[@calavera]: https://github.com/calavera
[@fnichol]: https://github.com/fnichol
[@gondoi]: https://github.com/gondoi
[@grahamc]: https://github.com/grahamc
[@jasonroelofs]: https://github.com/jasonroelofs
[@jonsmorrow]: https://github.com/jonsmorrow
[@josephholsten]: https://github.com/josephholsten
[@jrwesolo]: https://github.com/jrwesolo
[@jtimberman]: https://github.com/jtimberman
[@juliandunn]: https://github.com/juliandunn
[@manul]: https://github.com/manul
[@mattray]: https://github.com/mattray
[@mconigliaro]: https://github.com/mconigliaro
[@patcon]: https://github.com/patcon
[@portertech]: https://github.com/portertech
[@reset]: https://github.com/reset
[@rteabeault]: https://github.com/rteabeault
[@ryansouza]: https://github.com/ryansouza
[@saketoba]: https://github.com/saketoba
[@sethvargo]: https://github.com/sethvargo
[@smith]: https://github.com/smith
[@stevendanna]: https://github.com/stevendanna
[@thommay]: https://github.com/thommay
