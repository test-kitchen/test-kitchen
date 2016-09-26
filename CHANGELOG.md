# Change Log

## [v1.13.2](https://github.com/test-kitchen/test-kitchen/tree/v1.13.2) (2016-09-26)
[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v1.13.1...v1.13.2)

**Fixed bugs:**

- fix broken path on nano so shell out works [\#1129](https://github.com/test-kitchen/test-kitchen/pull/1129) ([mwrock](https://github.com/mwrock))

## [v1.13.1](https://github.com/test-kitchen/test-kitchen/tree/v1.13.1) (2016-09-22)
[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v1.13.0...v1.13.1)

**Implemented enhancements:**

- Allow mixlib-install 2.0 [\#1126](https://github.com/test-kitchen/test-kitchen/pull/1126) ([jkeis
er](https://github.com/jkeiser))

## [v1.13.0](https://github.com/test-kitchen/test-kitchen/tree/v1.13.0) (2016-09-16)
[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v1.12.0...v1.13.0)

**Implemented enhancements:**

- Add `kitchen status` command [\#87](https://github.com/test-kitchen/test-kitchen/issues/87)
- Add support for Windows Nano installs via chef provisioners [\#1119](https://github.com/test-kitchen/test-kitchen/pull/1119) ([mwrock](https://github.com/mwrock))
- Add package driver command [\#1074](https://github.com/test-kitchen/test-kitchen/pull/1074) ([neillturner](https://github.com/neillturner))

**Fixed bugs:**

- SSH Transport: Bastion proxy results in broken pipe error [\#1079](https://github.com/test-kitchen/test-kitchen/issues/1079)

## [v1.12.0](https://github.com/test-kitchen/test-kitchen/tree/v1.12.0) (2016-09-02)
[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v1.11.1...v1.12.0)

**Implemented enhancements:**

- Use winrm v2 release gems [\#1061](https://github.com/test-kitchen/test-kitchen/pull/1061) ([mwrock](https://github.com/mwrock))
- Add a new config option always\_update\_cookbooks [\#1107](https://github.com/test-kitchen/test-kitchen/pull/1107) ([coderanger](https://github.com/coderanger))
- Always run `chef install` even if the lock file exists. [\#1103](https://github.com/test-kitchen/test-kitchen/pull/1103) ([coderanger](https://github.com/coderanger))
- support passing Kitchen::Config Hash keys to Kitchen::RakeTasks.new [\#1102](https://github.com/test-kitchen/test-kitchen/pull/1102) ([theckman](https://github.com/theckman))

## [v1.11.1](https://github.com/test-kitchen/test-kitchen/tree/v1.11.1) (2016-08-13)
[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v1.11.0...v1.11.1)

**Fixed bugs:**

- Check the actual value, because `password: nil` shouldn't disable sending the key [\#1098](https://github.com/test-kitchen/test-kitchen/pull/1098) ([coderanger](https://github.com/coderanger))

## [v1.11.0](https://github.com/test-kitchen/test-kitchen/tree/v1.11.0) (2016-08-11)
[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v1.10.2...v1.11.0)

**Implemented enhancements:**

- Provide some way for Chef to know it's running under test [\#458](https://github.com/test-kitchen/test-kitchen/issues/458)
- Dont set ssh key configuration if a password is specified [\#1095](https://github.com/test-kitchen/test-kitchen/pull/1095) ([mwrock](https://github.com/mwrock))
- Ability to work with Instances over SSH tunnel. [\#1091](https://github.com/test-kitchen/test-kitchen/pull/1091) ([EYurchenko](https://github.com/EYurchenko))
- Add environment variables $TEST\_KITCHEN and $CI [\#1081](https://github.com/test-kitchen/test-kitchen/pull/1081) ([coderanger](https://github.com/coderanger))
- Adding test\_base\_path CLI arg to the diagnose command [\#1076](https://github.com/test-kitchen/test-kitchen/pull/1076) ([tyler-ball](https://github.com/tyler-ball))
- Add legacy\_mode argument for chef\_solo provisioner [\#1073](https://github.com/test-kitchen/test-kitchen/pull/1073) ([SaltwaterC](https://github.com/SaltwaterC))
- Added support for Chef 10 [\#1072](https://github.com/test-kitchen/test-kitchen/pull/1072) ([acondrat](https://github.com/acondrat))

**Fixed bugs:**

- Escape paths before running policyfile commands [\#1085](https://github.com/test-kitchen/test-kitchen/pull/1085) ([coderanger](https://github.com/coderanger))

## [v1.10.2](https://github.com/test-kitchen/test-kitchen/tree/v1.10.2) (2016-06-23)
[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v1.10.1...v1.10.2)

**Fixed bugs:**

- Mainly just a gem repackage against a clean repo on a linux machine

## [v1.10.1](https://github.com/test-kitchen/test-kitchen/tree/v1.10.1) (2016-06-23)
[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v1.10.0...v1.10.1)

**Fixed bugs:**

- Reboot resource with new 'reboot and try again' feature [\#1062](https://github.com/test-kitchen/test-kitchen/issues/1062)
- Fix WinRM Upload Failures After Reboot [\#1064](https://github.com/test-kitchen/test-kitchen/pull/1064) ([smurawski](https://github.com/smurawski))

## [v1.10.0](https://github.com/test-kitchen/test-kitchen/tree/v1.10.0) (2016-06-16)
[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v1.9.2...v1.10.0)

**Implemented enhancements:**

- Retry `Kitchen::Provisioner\#run\_command` after allowed exit codes [\#1055](https://github.com/test-kitchen/test-kitchen/pull/1055) ([smurawski](https://github.com/smurawski))
- Add fallback support for `policyfile` for compat with the older policyfile\_zero [\#1053](https://github.com/test-kitchen/test-kitchen/pull/1053) ([coderanger](https://github.com/coderanger))

## [v1.9.2](https://github.com/test-kitchen/test-kitchen/tree/v1.9.2) (2016-06-09)
[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v1.9.1...v1.9.2)

**Implemented enhancements:**

- add max scp session handling [\#1047](https://github.com/test-kitchen/test-kitchen/pull/1047) ([lamont-granquist](https://github.com/lamont-granquist))

**Fixed bugs:**

- Message: SCP upload failed \(open failed \(1\)\) [\#1035](https://github.com/test-kitchen/test-kitchen/issues/1035)

## [v1.9.1](https://github.com/test-kitchen/test-kitchen/tree/v1.9.1) (2016-06-02)
[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v1.9.0...v1.9.1)

**Implemented enhancements:**

- Allow rake task to use env var [\#1046](https://github.com/test-kitchen/test-kitchen/pull/1046) ([smurawski](https://github.com/smurawski))
- Add color options [\#1032](https://github.com/test-kitchen/test-kitchen/pull/1032) ([jorhett](https://github.com/jorhett))
- Add support for SSH connection debugging. [\#990](https://github.com/test-kitchen/test-kitchen/pull/990) ([rhass](https://github.com/rhass))

## [1.9.0](https://github.com/test-kitchen/test-kitchen/tree/v1.9.0) (2016-05-26)
[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v1.8.0...v1.9.0)

**Implemented enhancements:**

- Buffer errors until the end of an action [\#1034](https://github.com/test-kitchen/test-kitchen/pull/1034) ([smurawski](https://github.com/smurawski))
- Added ECOSYSTEM doc highlight all the core Test-Kitchen and community plugins. [\#1015](https://github.com/test-kitchen/test-kitchen/pull/1015) ([jjasghar](https://github.com/jjasghar))
- Add kitchen-azurerm to list of community-provided drivers [\#1024](https://github.com/test-kitchen/test-kitchen/pull/1024) ([stuartpreston](https://github.com/stuartpreston))
- uploads: reuse connections+disable compression [\#1023](https://github.com/test-kitchen/test-kitchen/pull/1023) ([lamont-granquist](https://github.com/lamont-granquist))

**Fixed bugs:**

- Use command\_prefix provided by Kitchen::Provisioner::Base in shell provisioner [\#1033](https://github.com/test-kitchen/test-kitchen/pull/1033) ([pstengel](https://github.com/pstengel))
- Empty string for the config setting for proxies did not really work [\#1027](https://github.com/test-kitchen/test-kitchen/pull/1027) ([smurawski](https://github.com/smurawski))
- Update `chef\_omnbius\_url` default value [\#1028](https://github.com/test-kitchen/test-kitchen/pull/1028) ([schisamo](https://github.com/schisamo))
- Fix grammar in common\_sandbox warning message [\#1031](https://github.com/test-kitchen/test-kitchen/pull/1031) ([emachnic](https://github.com/emachnic))

## [1.8.0](https://github.com/test-kitchen/test-kitchen/tree/v1.8.0) (2016-05-05)
[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v1.7.3...v1.8.0)

**Implemented enhancements:**

- Add native policyfile resolution support [\#1014](https://github.com/test-kitchen/test-kitchen/pull/1014) ([danielsdeleo](https://github.com/danielsdeleo))
- Provide the option to run all winrm commands through a scheduled task [\#1012](https://github.com/test-kitchen/test-kitchen/pull/1012) ([mwrock](https://github.com/mwrock))

## [1.7.3](https://github.com/test-kitchen/test-kitchen/tree/v1.7.3) (2016-04-13)
[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v1.7.2...v1.7.3)

**Fixed bugs:**

- Test Kitchen on windows fails to upload data bags [\#1006](https://github.com/test-kitchen/test-kitchen/issues/1006)
- Fixes busser install for older omnibus windows installs [\#1003](https://github.com/test-kitchen/test-kitchen/pull/1003) ([mwrock](https://github.com/mwrock))

## [1.7.2](https://github.com/test-kitchen/test-kitchen/tree/v1.7.2) (2016-04-07)
[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v1.7.1...v1.7.2)

**Merged pull requests:**

- Don't require dev dependencies to build [\#1000](https://github.com/test-kitchen/test-kitchen/pull/1000) ([jkeiser](https://github.com/jkeiser))
- update to win2k8 friendly dependencies [\#999](https://github.com/test-kitchen/test-kitchen/pull/999) ([mwrock](https://github.com/mwrock))
- Fix Berkshelf load test [\#998](https://github.com/test-kitchen/test-kitchen/pull/998) ([chefsalim](https://github.com/chefsalim))

## [v1.7.1](https://github.com/test-kitchen/test-kitchen/tree/v1.7.1) (2016-04-02)
[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v1.7.1.dev...v1.7.1)

**Fixed bugs:**

- Adding gitattributes file for managing line ending conversions [\#991](https://github.com/test-kitchen/test-kitchen/pull/991) ([mwrock](https://github.com/mwrock))

## [v1.7.0](https://github.com/test-kitchen/test-kitchen/tree/v1.7.0) (2016-04-01)
[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v1.6.0...v1.7.0)

**Implemented enhancements:**

- Travis and Appveyor should do actual kitchen create/converge/verify against PRs [\#980](https://github.com/test-kitchen/test-kitchen/pull/980) ([mwrock](https://github.com/mwrock))
- Use latest mixlib-install 1.0.2 [\#976](https://github.com/test-kitchen/test-kitchen/pull/976) ([mwrock](https://github.com/mwrock))
- Nominate Seth Thomas as lieutenant of Test Kitchen [\#975](https://github.com/test-kitchen/test-kitchen/pull/975) ([tyler-ball](https://github.com/tyler-ball))
- Create template for github issues [\#963](https://github.com/test-kitchen/test-kitchen/pull/963) ([smurawski](https://github.com/smurawski))
- Stop log\_level being copied from base config into provisioner config [\#950](https://github.com/test-kitchen/test-kitchen/pull/950) ([drrk](https://github.com/drrk))

**Fixed bugs:**

- Fix encrypted data bag uploads on windows [\#981](https://github.com/test-kitchen/test-kitchen/pull/981) ([mwrock](https://github.com/mwrock))
- Shell verifier should ensure env vars are strings [\#973](https://github.com/test-kitchen/test-kitchen/pull/973) ([jsok](https://github.com/jsok))
- Support Empty Proxy Settings [\#936](https://github.com/test-kitchen/test-kitchen/pull/936) ([tacchino](https://github.com/tacchino))

## [v1.6.0](https://github.com/test-kitchen/test-kitchen/tree/v1.6.0) (2016-02-29)
[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v1.5.0...v1.6.0)

**Implemented enhancements:**

- Publicly expose winrm session [\#670](https://github.com/test-kitchen/test-kitchen/issues/670)
- Support Chef-DK [\#443](https://github.com/test-kitchen/test-kitchen/issues/443)
- allow non-busser verifier to work with legacy drivers [\#944](https://github.com/test-kitchen/test-kitchen/pull/944) ([chris-rock](https://github.com/chris-rock))
- use winrm transport as alternative detection method [\#928](https://github.com/test-kitchen/test-kitchen/pull/928) ([chris-rock](https://github.com/chris-rock))
- Make chef-config an optional dependency. [\#924](https://github.com/test-kitchen/test-kitchen/pull/924) ([coderanger](https://github.com/coderanger))
- Deprecating winrm-tansport and winrm-s gems [\#902](https://github.com/test-kitchen/test-kitchen/pull/902) ([mwrock](https://github.com/mwrock))
- Add Provisioner chef\_apply [\#623](https://github.com/test-kitchen/test-kitchen/pull/623) ([sawanoboly](https://github.com/sawanoboly))

**Fixed bugs:**

- encrypted\_data\_bag\_secret\_key\_path does not fully work with Chef 12.x [\#751](https://github.com/test-kitchen/test-kitchen/issues/751)
- Permission denied for Busser [\#749](https://github.com/test-kitchen/test-kitchen/issues/749)
- --force-formatter is passed to a version of chef-client that does not support it. [\#593](https://github.com/test-kitchen/test-kitchen/issues/593)
- http\(s\)\_proxy in test [\#533](https://github.com/test-kitchen/test-kitchen/issues/533)
- make rubocop glücklich [\#956](https://github.com/test-kitchen/test-kitchen/pull/956) ([chris-rock](https://github.com/chris-rock))
- properly initialize attributes for new negotiate [\#937](https://github.com/test-kitchen/test-kitchen/pull/937) ([chris-rock](https://github.com/chris-rock))
- Fix sudo dependency [\#932](https://github.com/test-kitchen/test-kitchen/pull/932) ([alexpop](https://github.com/alexpop))

**Closed issues:**

- key not found: "src\_md5" on kitchen converge [\#954](https://github.com/test-kitchen/test-kitchen/issues/954)
- Kitchen Converge Argument Error [\#940](https://github.com/test-kitchen/test-kitchen/issues/940)
- Intermittent key not found: "src\_md5" failures on windows nodes [\#926](https://github.com/test-kitchen/test-kitchen/issues/926)
- Chef Omnibus Windows Issues \(mixlib-install \#22 related\) [\#847](https://github.com/test-kitchen/test-kitchen/issues/847)
- Invoking Rake tasks with concurrency? [\#799](https://github.com/test-kitchen/test-kitchen/issues/799)
- msiexec was not successful [\#742](https://github.com/test-kitchen/test-kitchen/issues/742)
- not able to force chef-client in local model even my .kitchen.yml said so. [\#739](https://github.com/test-kitchen/test-kitchen/issues/739)
- TK attempts to download install.sh every converge [\#714](https://github.com/test-kitchen/test-kitchen/issues/714)
- kitchen not detecting vagrant plugin `kitchen-vagrant` [\#622](https://github.com/test-kitchen/test-kitchen/issues/622)
- Not correct URL for opensuse-13.1 platform [\#599](https://github.com/test-kitchen/test-kitchen/issues/599)
- Error 404 if if chef-solo-search is anywhere in the dep-tree [\#591](https://github.com/test-kitchen/test-kitchen/issues/591)
- Difference in tty behaviour between verify and converge [\#563](https://github.com/test-kitchen/test-kitchen/issues/563)
- recipe idempotence checking [\#561](https://github.com/test-kitchen/test-kitchen/issues/561)
- chefzero integration test with several docker containers [\#560](https://github.com/test-kitchen/test-kitchen/issues/560)
- AWS is not a class \(TypeError\) [\#552](https://github.com/test-kitchen/test-kitchen/issues/552)
- Test Kitchen setup issue [\#546](https://github.com/test-kitchen/test-kitchen/issues/546)
- Run serverspec tests in 'ssh mode' instead of 'inside the machine' [\#539](https://github.com/test-kitchen/test-kitchen/issues/539)
- Auto creating nodes [\#528](https://github.com/test-kitchen/test-kitchen/issues/528)
- enable multi YAML configuration support [\#514](https://github.com/test-kitchen/test-kitchen/issues/514)
- Allow for site-cookbooks when using Librarian [\#511](https://github.com/test-kitchen/test-kitchen/issues/511)
- Support for running \*\_spec.rb according to the hostname or private ipaddress of a node [\#494](https://github.com/test-kitchen/test-kitchen/issues/494)
- Local platform exclusions [\#493](https://github.com/test-kitchen/test-kitchen/issues/493)
- Don't reset locale in Kitchen::Driver::Base run\_command\(\) [\#485](https://github.com/test-kitchen/test-kitchen/issues/485)
- Intermittent 'kitchen test' failures [\#449](https://github.com/test-kitchen/test-kitchen/issues/449)
- shell-provisioner: lots of trouble with a noexec /tmp, failing workaround. [\#444](https://github.com/test-kitchen/test-kitchen/issues/444)
- Message: Failed to complete \#converge action: \[Permission denied [\#441](https://github.com/test-kitchen/test-kitchen/issues/441)
- Idea: enable chef-zero to run on another server than the converged node. [\#437](https://github.com/test-kitchen/test-kitchen/issues/437)
- Test Artifact Fetch Feature [\#434](https://github.com/test-kitchen/test-kitchen/issues/434)
- Loading installed gem dependencies with busser plugins [\#406](https://github.com/test-kitchen/test-kitchen/issues/406)
- Wrap mkdir in sudo\(\) for init\_command of chef\_base provisioner? [\#382](https://github.com/test-kitchen/test-kitchen/issues/382)
- Unable to override `test\_base\_path` in test-kitchen v1.2.1 [\#377](https://github.com/test-kitchen/test-kitchen/issues/377)
- Busser depends on Ruby \(ChefDK\) being available on target VM [\#347](https://github.com/test-kitchen/test-kitchen/issues/347)
- Option to turn off ssh forwarding x11? [\#338](https://github.com/test-kitchen/test-kitchen/issues/338)

**Merged pull requests:**

- Update release process to use github changelog generator [\#952](https://github.com/test-kitchen/test-kitchen/pull/952) ([jkeiser](https://github.com/jkeiser))
- The Net::SSH::Extensions were overwriting IO.select agressively, so we scaled this down some [\#935](https://github.com/test-kitchen/test-kitchen/pull/935) ([tyler-ball](https://github.com/tyler-ball))
- bypass execution policy when running powershell script files [\#925](https://github.com/test-kitchen/test-kitchen/pull/925) ([mwrock](https://github.com/mwrock))

## [v1.5.0](https://github.com/test-kitchen/test-kitchen/tree/v1.5.0) (2016-01-21)
[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v1.5.0.rc.1...v1.5.0)

**Implemented enhancements:**

- Cluster support with Kitchen [\#905](https://github.com/test-kitchen/test-kitchen/issues/905)
- toggling attributes in kitchen.yml [\#884](https://github.com/test-kitchen/test-kitchen/issues/884)
- Allow for "double-converges" on specific test suites [\#162](https://github.com/test-kitchen/test-kitchen/issues/162)
- Added try/catch around main and set error action to stop [\#872](https://github.com/test-kitchen/test-kitchen/pull/872) ([mcallb](https://github.com/mcallb))
- Add hooks for instance cleanup before exit. [\#825](https://github.com/test-kitchen/test-kitchen/pull/825) ([coderanger](https://github.com/coderanger))
- add tests for empty or missing files [\#753](https://github.com/test-kitchen/test-kitchen/pull/753) ([miketheman](https://github.com/miketheman))

**Fixed bugs:**

- kitchen init will modify Rakefile and cause RuboCop issues [\#915](https://github.com/test-kitchen/test-kitchen/issues/915)
- \(Win2012r2\) Chef-client version to install seems to be ignored [\#882](https://github.com/test-kitchen/test-kitchen/issues/882)
- No Proxy Settings in Setup Phase [\#821](https://github.com/test-kitchen/test-kitchen/issues/821)
- It seems dna.json is being repeated [\#606](https://github.com/test-kitchen/test-kitchen/issues/606)
- The netssh 3.0 update returns a different error on connection timeout than 2.9.2 did, adding it to the retry list [\#912](https://github.com/test-kitchen/test-kitchen/pull/912) ([tyler-ball](https://github.com/tyler-ball))
- Fix handling of chunked ssh output. [\#824](https://github.com/test-kitchen/test-kitchen/pull/824) ([kingpong](https://github.com/kingpong))
- Set default log level even if you forget to add it to command line arg [\#697](https://github.com/test-kitchen/test-kitchen/pull/697) ([scotthain](https://github.com/scotthain))
- Use single quotes in Rake/Thorfile templates [\#499](https://github.com/test-kitchen/test-kitchen/pull/499) ([chr4](https://github.com/chr4))

**Closed issues:**

- Kubernetes driver [\#920](https://github.com/test-kitchen/test-kitchen/issues/920)
- Latest build in chef-dk failing in travis [\#918](https://github.com/test-kitchen/test-kitchen/issues/918)
- Unable to test Chef11 due to net-ssh  [\#914](https://github.com/test-kitchen/test-kitchen/issues/914)
- kitchen driver help message incorrect [\#903](https://github.com/test-kitchen/test-kitchen/issues/903)
- No arg for -v option \(install.sh missing version number\) [\#900](https://github.com/test-kitchen/test-kitchen/issues/900)
- n help converge [\#890](https://github.com/test-kitchen/test-kitchen/issues/890)
- Chef Zero should be the default provisioner with init [\#889](https://github.com/test-kitchen/test-kitchen/issues/889)
- Windows tests broken - mkdir -p [\#886](https://github.com/test-kitchen/test-kitchen/issues/886)
- Berkshelf not managing dependencies [\#869](https://github.com/test-kitchen/test-kitchen/issues/869)
- Errno::ETIMEDOUT needed in winrm transport [\#855](https://github.com/test-kitchen/test-kitchen/issues/855)
- Appears to freeze on second converge. [\#850](https://github.com/test-kitchen/test-kitchen/issues/850)
- How to specify RubyGem source in .kitchen.yml for serverspec gems? [\#844](https://github.com/test-kitchen/test-kitchen/issues/844)
- f using serch to find self node [\#842](https://github.com/test-kitchen/test-kitchen/issues/842)
- Kitchen : reconverge with another user [\#840](https://github.com/test-kitchen/test-kitchen/issues/840)
- Can't transfer cookbook to Windows node using Chef Kitchen [\#818](https://github.com/test-kitchen/test-kitchen/issues/818)
- ability to change location of test/integration/default/ [\#814](https://github.com/test-kitchen/test-kitchen/issues/814)
- Kitchen destroy fails if VM manually removed [\#796](https://github.com/test-kitchen/test-kitchen/issues/796)
- reconverge with test-kitchen [\#780](https://github.com/test-kitchen/test-kitchen/issues/780)
- ssh breaks if vm restarts [\#769](https://github.com/test-kitchen/test-kitchen/issues/769)
- Transfer files more efficiently. [\#657](https://github.com/test-kitchen/test-kitchen/issues/657)
- Possibility to lock down versions of gems [\#515](https://github.com/test-kitchen/test-kitchen/issues/515)
- Missing vagrant-wrapper gem, update test-kitchen gem dependencies? [\#488](https://github.com/test-kitchen/test-kitchen/issues/488)
- : Message: SSH exited \(1\) for command: \[sh -c 'BUSSER\_ROOT="/tmp/busser" GEM\_HOME="/tmp/busser/gems" GEM\_PATH="/tmp/busser/gems" GEM\_CACHE="/tmp/busser/gems/cache" ; export BUSSER\_ROOT GEM\_HOME GEM\_PATH GEM\_CACHE; sudo -E /tmp/busser/bin/busser test'\] [\#411](https://github.com/test-kitchen/test-kitchen/issues/411)
- TestKitchen isn't using VAGRANT\_HOME path [\#398](https://github.com/test-kitchen/test-kitchen/issues/398)
- deal with travis [\#369](https://github.com/test-kitchen/test-kitchen/issues/369)
- use a default path rubygems, ruby and busser [\#362](https://github.com/test-kitchen/test-kitchen/issues/362)
- Bats tests are being executed even missing specification [\#360](https://github.com/test-kitchen/test-kitchen/issues/360)
- shell provisioner: Add a KITCHEN\_DIR environment variable [\#349](https://github.com/test-kitchen/test-kitchen/issues/349)
- Don't use generic descriptions for create, converge, setup, verify, and destroy [\#344](https://github.com/test-kitchen/test-kitchen/issues/344)
- Exception Handler does not always print out anything to stdout [\#281](https://github.com/test-kitchen/test-kitchen/issues/281)

**Merged pull requests:**

- 150 release prep [\#921](https://github.com/test-kitchen/test-kitchen/pull/921) ([tyler-ball](https://github.com/tyler-ball))
- Because net/ssh is no longer including timeout.rb, we need to so that Ruby doesn't think Timeout belongs to the TK class [\#919](https://github.com/test-kitchen/test-kitchen/pull/919) ([tyler-ball](https://github.com/tyler-ball))
- Diet travis [\#911](https://github.com/test-kitchen/test-kitchen/pull/911) ([cheeseplus](https://github.com/cheeseplus))
- Revert "fix driver help output" [\#910](https://github.com/test-kitchen/test-kitchen/pull/910) ([cheeseplus](https://github.com/cheeseplus))
- Updating to the latest release of net-ssh to consume https://github.com/net-ssh/net-ssh/pull/280 [\#908](https://github.com/test-kitchen/test-kitchen/pull/908) ([tyler-ball](https://github.com/tyler-ball))
- Set version to 1.5.0 [\#907](https://github.com/test-kitchen/test-kitchen/pull/907) ([jkeiser](https://github.com/jkeiser))
- Adding Maintainers file [\#906](https://github.com/test-kitchen/test-kitchen/pull/906) ([cheeseplus](https://github.com/cheeseplus))
- fix driver help output [\#904](https://github.com/test-kitchen/test-kitchen/pull/904) ([akissa](https://github.com/akissa))
- Add support for --profile-ruby [\#901](https://github.com/test-kitchen/test-kitchen/pull/901) ([martinb3](https://github.com/martinb3))
- fix chef install on non-windows [\#899](https://github.com/test-kitchen/test-kitchen/pull/899) ([mwrock](https://github.com/mwrock))
- typo: on != no [\#897](https://github.com/test-kitchen/test-kitchen/pull/897) ([miketheman](https://github.com/miketheman))
- Fix Windows Omnibus Install \#811 [\#864](https://github.com/test-kitchen/test-kitchen/pull/864) ([dissonanz](https://github.com/dissonanz))
- add cli option to set the test path [\#857](https://github.com/test-kitchen/test-kitchen/pull/857) ([chris-rock](https://github.com/chris-rock))
- WinRM connect \(with retry\) is failing on Windows [\#835](https://github.com/test-kitchen/test-kitchen/pull/835) ([Stift](https://github.com/Stift))
- update omnibus url to chef.io [\#827](https://github.com/test-kitchen/test-kitchen/pull/827) ([andrewelizondo](https://github.com/andrewelizondo))
- Add more options for WinRM [\#776](https://github.com/test-kitchen/test-kitchen/pull/776) ([smurawski](https://github.com/smurawski))

## [v1.5.0.rc.1](https://github.com/test-kitchen/test-kitchen/tree/v1.5.0.rc.1) (2015-12-29)
[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v1.4.2...v1.5.0.rc.1)

**Implemented enhancements:**

- Drop Ruby 1.9 support [\#806](https://github.com/test-kitchen/test-kitchen/issues/806)
- fixed SuSe OS busser install [\#816](https://github.com/test-kitchen/test-kitchen/pull/816) ([Peuserik](https://github.com/Peuserik))
- Honor proxy env vars. [\#813](https://github.com/test-kitchen/test-kitchen/pull/813) ([mcquin](https://github.com/mcquin))
- Drop Ruby 1.9.3 from TravisCI build matrix [\#804](https://github.com/test-kitchen/test-kitchen/pull/804) ([thommay](https://github.com/thommay))
- Use mixlib-install [\#782](https://github.com/test-kitchen/test-kitchen/pull/782) ([thommay](https://github.com/thommay))

**Fixed bugs:**

- Make lazyhash enumerable [\#752](https://github.com/test-kitchen/test-kitchen/pull/752) ([caboteria](https://github.com/caboteria))

**Closed issues:**

- WinrRM "The device is not ready" [\#891](https://github.com/test-kitchen/test-kitchen/issues/891)
- kitchen starts linux machine with run level 2 by default [\#881](https://github.com/test-kitchen/test-kitchen/issues/881)
- Failing to parse .kitchen.yml with ChefDK 0.9.0 on Windows 7 [\#877](https://github.com/test-kitchen/test-kitchen/issues/877)
- policyfile\_zero doesn't use attributes in .kitchen.yml [\#870](https://github.com/test-kitchen/test-kitchen/issues/870)
- http proxy for "Installing Chef Omnibus" part? [\#867](https://github.com/test-kitchen/test-kitchen/issues/867)
- data\_munger, NoMethodError [\#865](https://github.com/test-kitchen/test-kitchen/issues/865)
- Waiting for SSH service on 127.0.0.1:2222, retrying in 3 seconds [\#862](https://github.com/test-kitchen/test-kitchen/issues/862)
- test-kitchen winrm w/proxies "The command line is too long." [\#854](https://github.com/test-kitchen/test-kitchen/issues/854)
- kitchen converge error [\#853](https://github.com/test-kitchen/test-kitchen/issues/853)
- /opt/chef/version-manifest.txt doesn't have proper version on line one, causing extra installations via Omnibus [\#846](https://github.com/test-kitchen/test-kitchen/issues/846)
- SSL read error when attempting to download Ubuntu 12.04 box for simple converge [\#834](https://github.com/test-kitchen/test-kitchen/issues/834)
- chefdk install issues [\#830](https://github.com/test-kitchen/test-kitchen/issues/830)
- Test Kitchen does not detect ports listening to localhost on Windows [\#828](https://github.com/test-kitchen/test-kitchen/issues/828)
- serverspec tests fail on windows [\#823](https://github.com/test-kitchen/test-kitchen/issues/823)
- Error in test kitchen exits shell [\#822](https://github.com/test-kitchen/test-kitchen/issues/822)
- Cannot use an http/https url pointing to a vagrant metadata json file for box\_url [\#819](https://github.com/test-kitchen/test-kitchen/issues/819)
- kitchen converge does not execute sleep command [\#812](https://github.com/test-kitchen/test-kitchen/issues/812)
- Serverspec `command` does not seem to be working...  [\#773](https://github.com/test-kitchen/test-kitchen/issues/773)
- Chef-Solo cache deleted by WinRM transport [\#680](https://github.com/test-kitchen/test-kitchen/issues/680)
- Feature: 'vagrant reload' for kitchen [\#678](https://github.com/test-kitchen/test-kitchen/issues/678)

**Merged pull requests:**

- Adding the CHANGELOG and version.rb update for 1.5.0.rc.1 [\#898](https://github.com/test-kitchen/test-kitchen/pull/898) ([tyler-ball](https://github.com/tyler-ball))
- Fixing garbled output for chef\_zero provisioner [\#896](https://github.com/test-kitchen/test-kitchen/pull/896) ([someara](https://github.com/someara))
- Adding in ChefConfig support to enable loading proxy config from chef config files [\#895](https://github.com/test-kitchen/test-kitchen/pull/895) ([tyler-ball](https://github.com/tyler-ball))
- Adding the Travis config necessary to run the proxy\_tests [\#894](https://github.com/test-kitchen/test-kitchen/pull/894) ([tyler-ball](https://github.com/tyler-ball))
- Adding proxy tests to the Travis.yml [\#892](https://github.com/test-kitchen/test-kitchen/pull/892) ([tyler-ball](https://github.com/tyler-ball))
- Test suite maintenance, a.k.a. "Just Dots And Only Dots" [\#887](https://github.com/test-kitchen/test-kitchen/pull/887) ([fnichol](https://github.com/fnichol))
- Running the chef\_base provisioner install\_command via sudo, and command\_prefix support [\#885](https://github.com/test-kitchen/test-kitchen/pull/885) ([adamleff](https://github.com/adamleff))
- write install\_command to file and invoke on the instance to avoid command too long on windows [\#878](https://github.com/test-kitchen/test-kitchen/pull/878) ([mwrock](https://github.com/mwrock))
- Updates the gem path to install everything in /tmp/verifier [\#833](https://github.com/test-kitchen/test-kitchen/pull/833) ([scotthain](https://github.com/scotthain))

## [v1.4.2](https://github.com/test-kitchen/test-kitchen/tree/v1.4.2) (2015-08-03)
[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v1.4.1...v1.4.2)

**Implemented enhancements:**

- silence some aruba warnings [\#770](https://github.com/test-kitchen/test-kitchen/pull/770) ([thommay](https://github.com/thommay))
- Fix monkey patching of IO.read [\#768](https://github.com/test-kitchen/test-kitchen/pull/768) ([375gnu](https://github.com/375gnu))
- Style/Lint Updates \(finstyle 1.5.0\) [\#762](https://github.com/test-kitchen/test-kitchen/pull/762) ([fnichol](https://github.com/fnichol))
- Adding appveyor config [\#689](https://github.com/test-kitchen/test-kitchen/pull/689) ([tyler-ball](https://github.com/tyler-ball))

**Fixed bugs:**

- Appveyor CI not configured correctly [\#803](https://github.com/test-kitchen/test-kitchen/issues/803)
- uninitialized constant Kitchen::Transport::Ssh::Connection::Timeout with net-ssh 2.10 [\#800](https://github.com/test-kitchen/test-kitchen/issues/800)
- Possible bug in Getting Started Guide: 'could not settle on compression\_client algorithm' [\#729](https://github.com/test-kitchen/test-kitchen/issues/729)
- Pinning net-ssh to 2.9 [\#805](https://github.com/test-kitchen/test-kitchen/pull/805) ([tyler-ball](https://github.com/tyler-ball))
- Rescue Errno::ETIMEDOUT instead of Timeout::Error on Establish [\#802](https://github.com/test-kitchen/test-kitchen/pull/802) ([Annih](https://github.com/Annih))
- Fix for net-ssh 2.10.0. [\#801](https://github.com/test-kitchen/test-kitchen/pull/801) ([coderanger](https://github.com/coderanger))

**Closed issues:**

- kitchen exec -c "ipconfig" fails on winrm \(any other command too\) with Winrm authorization error.  [\#795](https://github.com/test-kitchen/test-kitchen/issues/795)
- Specifying Config File on CLI [\#792](https://github.com/test-kitchen/test-kitchen/issues/792)
- Converge fails on "Configuring netowrk adapters within the VM..." [\#789](https://github.com/test-kitchen/test-kitchen/issues/789)
- Converge only works on second try [\#785](https://github.com/test-kitchen/test-kitchen/issues/785)
- is\_running shows failing upstart process on Redhat [\#784](https://github.com/test-kitchen/test-kitchen/issues/784)
- Uninitialized constant Kitchen::Transport::Ssh::Connection::Timeout [\#775](https://github.com/test-kitchen/test-kitchen/issues/775)
- attempting to copy file from /var/folders that does not exist [\#774](https://github.com/test-kitchen/test-kitchen/issues/774)
- Can we copy .kitchen.yml into vagrant box? [\#763](https://github.com/test-kitchen/test-kitchen/issues/763)
- Ruby regular expression doesn't work in z-shell [\#760](https://github.com/test-kitchen/test-kitchen/issues/760)
- how to use a puppet apply shell script with test kitchen [\#719](https://github.com/test-kitchen/test-kitchen/issues/719)
- server.rb:283:in `block in start\_background': undefined method `start' for nil:NilClass \(NoMethodError\) [\#710](https://github.com/test-kitchen/test-kitchen/issues/710)
- Windows guests cannot use Gemfile with serverspec tests [\#616](https://github.com/test-kitchen/test-kitchen/issues/616)
- ssl\_ca\_path cannot be set in kitchen client.rb [\#594](https://github.com/test-kitchen/test-kitchen/issues/594)
- Test kitchen setup fails during busser serverspec plugin post install [\#461](https://github.com/test-kitchen/test-kitchen/issues/461)

**Merged pull requests:**

- Support specifying exact nightly/build [\#788](https://github.com/test-kitchen/test-kitchen/pull/788) ([jaym](https://github.com/jaym))

## [v1.4.1](https://github.com/test-kitchen/test-kitchen/tree/v1.4.1) (2015-06-18)
[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v0.9.1...v1.4.1)

**Implemented enhancements:**

- 'kitchen init' should create a chefignore file [\#732](https://github.com/test-kitchen/test-kitchen/issues/732)
- generate a chefignore during init, fixes \#732 [\#737](https://github.com/test-kitchen/test-kitchen/pull/737) ([metadave](https://github.com/metadave))
- Fixing issues to support windows in kitchen-ec2, fixes \#688, fixes \#733 [\#736](https://github.com/test-kitchen/test-kitchen/pull/736) ([tyler-ball](https://github.com/tyler-ball))

**Fixed bugs:**

- Discovering more than 50 drivers fails a Cucumber scenario [\#733](https://github.com/test-kitchen/test-kitchen/issues/733)
- Transport defaults windows username to ./administrator [\#688](https://github.com/test-kitchen/test-kitchen/issues/688)
- Fixing issues to support windows in kitchen-ec2, fixes \\#688, fixes \\#733 [\#736](https://github.com/test-kitchen/test-kitchen/pull/736) ([tyler-ball](https://github.com/tyler-ball))
- Fix failing feature in `kitchen drvier discover` due to too many gems. [\#734](https://github.com/test-kitchen/test-kitchen/pull/734) ([fnichol](https://github.com/fnichol))

**Closed issues:**

- SSH race condition with RHEL/CentOS instances in EC2 [\#735](https://github.com/test-kitchen/test-kitchen/issues/735)
- Nested upload folders [\#725](https://github.com/test-kitchen/test-kitchen/issues/725)
- Intermittent "No such file or directory" on Windows converge [\#699](https://github.com/test-kitchen/test-kitchen/issues/699)
- "kitchen verify" output on windows is getting butchered [\#486](https://github.com/test-kitchen/test-kitchen/issues/486)

**Merged pull requests:**

- Updating CHANGELOG and version for 1.4.1 release [\#748](https://github.com/test-kitchen/test-kitchen/pull/748) ([tyler-ball](https://github.com/tyler-ball))
- Revert "Use a relative name for the connection class." [\#731](https://github.com/test-kitchen/test-kitchen/pull/731) ([metadave](https://github.com/metadave))
- Use a relative name for the connection class. [\#726](https://github.com/test-kitchen/test-kitchen/pull/726) ([coderanger](https://github.com/coderanger))

## [v0.9.1](https://github.com/test-kitchen/test-kitchen/tree/v0.9.1) (2015-05-21)
[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v0.9.0...v0.9.1)

**Closed issues:**

- kitchen exec fails to show text content without linebreak [\#717](https://github.com/test-kitchen/test-kitchen/issues/717)
- How to copy files from box to host machine? [\#716](https://github.com/test-kitchen/test-kitchen/issues/716)

## [v0.9.0](https://github.com/test-kitchen/test-kitchen/tree/v0.9.0) (2015-05-19)
[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v1.4.0...v0.9.0)

**Implemented enhancements:**

- platform centos-6.4, centos-6.5 cannot be downloaded [\#663](https://github.com/test-kitchen/test-kitchen/issues/663)
- Update platform version defaults in `kitchen init` command. [\#711](https://github.com/test-kitchen/test-kitchen/pull/711) ([fnichol](https://github.com/fnichol))
- don't prompt for passwords when using public keys [\#704](https://github.com/test-kitchen/test-kitchen/pull/704) ([caboteria](https://github.com/caboteria))

**Fixed bugs:**

- default-centos-64 is not available [\#707](https://github.com/test-kitchen/test-kitchen/issues/707)

**Closed issues:**

- Exception on kitchen create: Windows Server 2012 R2 box [\#696](https://github.com/test-kitchen/test-kitchen/issues/696)
- Unable to run kitchen converge: Server 2012 R2 - WinRM [\#695](https://github.com/test-kitchen/test-kitchen/issues/695)
- Windows guest doesn't update serverspec files [\#693](https://github.com/test-kitchen/test-kitchen/issues/693)
- Busser sync is a bit slow [\#639](https://github.com/test-kitchen/test-kitchen/issues/639)
- client key is invalid or not found at: 'C:/chef/client.pem' [\#636](https://github.com/test-kitchen/test-kitchen/issues/636)
- Don't print extraneous equals signs to logs "================" [\#586](https://github.com/test-kitchen/test-kitchen/issues/586)

**Merged pull requests:**

- Bump to centos-6.6, fix \#663. [\#665](https://github.com/test-kitchen/test-kitchen/pull/665) ([lloydde](https://github.com/lloydde))

## [v1.4.0](https://github.com/test-kitchen/test-kitchen/tree/v1.4.0) (2015-04-28)
[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v1.4.0.rc.1...v1.4.0)

**Implemented enhancements:**

- Add Multi-provisioner support [\#36](https://github.com/test-kitchen/test-kitchen/issues/36)

**Fixed bugs:**

- kitchen verify not updating tests on Windows guests [\#684](https://github.com/test-kitchen/test-kitchen/issues/684)

**Closed issues:**

- includes and excludes directives not working in 1.4.0.rc.1 [\#690](https://github.com/test-kitchen/test-kitchen/issues/690)
- avoid forwarding port 22 if a Windows guest? [\#676](https://github.com/test-kitchen/test-kitchen/issues/676)
- kitchen verify fails on opscode centos-6.6 vagrant box [\#664](https://github.com/test-kitchen/test-kitchen/issues/664)
- test-kitchen/lib/kitchen/provisioner/chef/powershell\_shell.rb expand\_version fails if behind proxy and http\_proxy is set [\#638](https://github.com/test-kitchen/test-kitchen/issues/638)
- kitchen hangs on converge [\#624](https://github.com/test-kitchen/test-kitchen/issues/624)
- help info for "kitchen driver incorrect" [\#613](https://github.com/test-kitchen/test-kitchen/issues/613)
- Detect and warn users about Powershell bug KB2842230 that causes Out of Memory Errors [\#604](https://github.com/test-kitchen/test-kitchen/issues/604)
- Need solution/best practice for installing gem in VM chef-client [\#495](https://github.com/test-kitchen/test-kitchen/issues/495)
- Multi-project chaining of shared CLI subcommands [\#47](https://github.com/test-kitchen/test-kitchen/issues/47)
- Create kitchen driver for Razor [\#45](https://github.com/test-kitchen/test-kitchen/issues/45)

## [v1.4.0.rc.1](https://github.com/test-kitchen/test-kitchen/tree/v1.4.0.rc.1) (2015-03-29)
[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v1.4.0.beta.2...v1.4.0.rc.1)

**Fixed bugs:**

- Windows 7 fails with 'maximum number of 15 concurrent operations' on second converge [\#656](https://github.com/test-kitchen/test-kitchen/issues/656)
- second converge fails with encrypted data bags [\#611](https://github.com/test-kitchen/test-kitchen/issues/611)
- Support relative paths to SSH keys [\#389](https://github.com/test-kitchen/test-kitchen/issues/389)
- Use of sudo -E breaks compatibility with CentOS 5 [\#307](https://github.com/test-kitchen/test-kitchen/issues/307)
- re-adds PATH [\#666](https://github.com/test-kitchen/test-kitchen/pull/666) ([curiositycasualty](https://github.com/curiositycasualty))

**Closed issues:**

- Wrong permissions in /tmp/verifier/gems/\[bin/cache/gems\] \(?\) / broken caching with 1.4.0.beta.2 [\#671](https://github.com/test-kitchen/test-kitchen/issues/671)
- ChefZero,ChefSolo \#install\_command should bomb out when no downloaders are found [\#654](https://github.com/test-kitchen/test-kitchen/issues/654)
- Files not available in temp/kitchen - Windows Guest [\#642](https://github.com/test-kitchen/test-kitchen/issues/642)
- winrm: Use the rdp\_uri instead of trying to call specific application [\#595](https://github.com/test-kitchen/test-kitchen/issues/595)
- How to pass a symbol instead of string in .kitchen.yml [\#556](https://github.com/test-kitchen/test-kitchen/issues/556)
- Converge fails deleting non-cookbook files on Windows synced folder due to max path length [\#522](https://github.com/test-kitchen/test-kitchen/issues/522)
- Create kitchen driver for Solaris/illumos Zones [\#44](https://github.com/test-kitchen/test-kitchen/issues/44)

**Merged pull requests:**

- \[Transport::Ssh\] Add default :compression & :compression\_level attrs. [\#675](https://github.com/test-kitchen/test-kitchen/pull/675) ([fnichol](https://github.com/fnichol))
- \[Transport::SSH\] Expand path for `:ssh\_key` if provided in kitchen.yml. [\#674](https://github.com/test-kitchen/test-kitchen/pull/674) ([fnichol](https://github.com/fnichol))
- \[ChefSolo,ChefZero\] Ensure that secret key is deleted before converge. [\#673](https://github.com/test-kitchen/test-kitchen/pull/673) ([fnichol](https://github.com/fnichol))
- \[Transport::Winrm\] Extract dependant code to winrm-transport gem. [\#672](https://github.com/test-kitchen/test-kitchen/pull/672) ([fnichol](https://github.com/fnichol))
- \[CommandExecutor\] Move ObjectSpace finalizer logic into executor. [\#669](https://github.com/test-kitchen/test-kitchen/pull/669) ([fnichol](https://github.com/fnichol))
- Add `plugin\_version` support for all plugin types. [\#668](https://github.com/test-kitchen/test-kitchen/pull/668) ([fnichol](https://github.com/fnichol))
- Add plugin diagnostics, exposed via `kitchen diagnose`. [\#667](https://github.com/test-kitchen/test-kitchen/pull/667) ([fnichol](https://github.com/fnichol))
- Updated for sh compatibility based on install.sh code [\#658](https://github.com/test-kitchen/test-kitchen/pull/658) ([scotthain](https://github.com/scotthain))
- \[ChefZero\] Consider `:require\_chef\_omnibus = 11` to be modern version. [\#653](https://github.com/test-kitchen/test-kitchen/pull/653) ([fnichol](https://github.com/fnichol))
- \[ChefZero,ChefSolo\] Support symbol values in solo.rb & client.rb. [\#652](https://github.com/test-kitchen/test-kitchen/pull/652) ([fnichol](https://github.com/fnichol))
- Add :sudo\_command to Provisioners, Verifiers, & ShellOut. [\#651](https://github.com/test-kitchen/test-kitchen/pull/651) ([fnichol](https://github.com/fnichol))

## [v1.4.0.beta.2](https://github.com/test-kitchen/test-kitchen/tree/v1.4.0.beta.2) (2015-03-25)
[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v1.4.0.beta.1...v1.4.0.beta.2)

**Merged pull requests:**

- \[Provisioner::Shell\] Add HTTP proxy support to commands. [\#649](https://github.com/test-kitchen/test-kitchen/pull/649) ([fnichol](https://github.com/fnichol))
- \[Transport::Winrm\] Truncate destination file for overwriting. [\#648](https://github.com/test-kitchen/test-kitchen/pull/648) ([fnichol](https://github.com/fnichol))

## [v1.4.0.beta.1](https://github.com/test-kitchen/test-kitchen/tree/v1.4.0.beta.1) (2015-03-24)
[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v1.3.1...v1.4.0.beta.1)

**Closed issues:**

- RubyZip is corrupting zip files on windows hosts [\#643](https://github.com/test-kitchen/test-kitchen/issues/643)
- windows guest support broke recntly  [\#641](https://github.com/test-kitchen/test-kitchen/issues/641)
- Unable to parse WinRM response, missing attribute quote [\#635](https://github.com/test-kitchen/test-kitchen/issues/635)
- Chef DownloadFile fails on Powershell 2.0/win 2003 [\#631](https://github.com/test-kitchen/test-kitchen/issues/631)
- how can i pull the data from chef server policy environment override attributes [\#630](https://github.com/test-kitchen/test-kitchen/issues/630)
- windows-guest-support branch does not download chef client rc version [\#626](https://github.com/test-kitchen/test-kitchen/issues/626)
- Zip Transport fails on Windows Server Core [\#625](https://github.com/test-kitchen/test-kitchen/issues/625)
- call capistrano deployment? [\#617](https://github.com/test-kitchen/test-kitchen/issues/617)
- PR\#589 Causes chef-client installations to report as failed when they have actually succeeded [\#601](https://github.com/test-kitchen/test-kitchen/issues/601)
- Kitchen converge on Windows guests takes two tries [\#596](https://github.com/test-kitchen/test-kitchen/issues/596)
- Need support for keepalive for ssh connections [\#585](https://github.com/test-kitchen/test-kitchen/issues/585)
- windows-guest-support: wrong path for chef-client [\#565](https://github.com/test-kitchen/test-kitchen/issues/565)
- How to setup hostname of vm with .kitchen.yml ? [\#465](https://github.com/test-kitchen/test-kitchen/issues/465)
- Can test-kitchen work with mingw32  [\#435](https://github.com/test-kitchen/test-kitchen/issues/435)
- Filtering non-cookbook files leave empty directories that are still scp-ed [\#429](https://github.com/test-kitchen/test-kitchen/issues/429)
- prepare\_chef\_home doesn't work on Windows guests [\#158](https://github.com/test-kitchen/test-kitchen/issues/158)
- Add an option to clean up log files generated [\#85](https://github.com/test-kitchen/test-kitchen/issues/85)

**Merged pull requests:**

- Further backwards compatibility effort [\#646](https://github.com/test-kitchen/test-kitchen/pull/646) ([fnichol](https://github.com/fnichol))
- open zip file in binary mode to avoid corrupting zip files on  windows [\#644](https://github.com/test-kitchen/test-kitchen/pull/644) ([mwrock](https://github.com/mwrock))
- Test Kitchen 1.4 Refactoring \(SSH/WinRM Transports, Windows Support, etc\) [\#640](https://github.com/test-kitchen/test-kitchen/pull/640) ([fnichol](https://github.com/fnichol))
- \[WIP\] Test Kitchen 1.4 Refactoring \(SSH/WinRM Transports, Windows Support, etc\) [\#637](https://github.com/test-kitchen/test-kitchen/pull/637) ([fnichol](https://github.com/fnichol))
- Fixing bad default setting - if ENV is not set we are accidently setting log\_level to nil for whole run [\#633](https://github.com/test-kitchen/test-kitchen/pull/633) ([tyler-ball](https://github.com/tyler-ball))
- Fixes Chef Client installation on Windows Guests [\#615](https://github.com/test-kitchen/test-kitchen/pull/615) ([robcoward](https://github.com/robcoward))
- Pinning winrm to newer version to support latest httpclient [\#612](https://github.com/test-kitchen/test-kitchen/pull/612) ([tyler-ball](https://github.com/tyler-ball))
- Windows2003 guest fix [\#610](https://github.com/test-kitchen/test-kitchen/pull/610) ([GolubevV](https://github.com/GolubevV))
- Proxy Implementation for Windows Chef Omnibus [\#603](https://github.com/test-kitchen/test-kitchen/pull/603) ([afiune](https://github.com/afiune))
- Adding --log-overwrite CLI option [\#600](https://github.com/test-kitchen/test-kitchen/pull/600) ([tyler-ball](https://github.com/tyler-ball))
- Powershell no longer re-installs chef if version constraint is only major version [\#590](https://github.com/test-kitchen/test-kitchen/pull/590) ([tyler-ball](https://github.com/tyler-ball))
- Check the exit code of msiexec [\#589](https://github.com/test-kitchen/test-kitchen/pull/589) ([jaym](https://github.com/jaym))
- Change getchef.com chef.io in Powershell provisioner [\#588](https://github.com/test-kitchen/test-kitchen/pull/588) ([jaym](https://github.com/jaym))
- winrm transport should use a single \(or minimal\) shell when transferring files. transfer via a zip file to optimize round trips [\#562](https://github.com/test-kitchen/test-kitchen/pull/562) ([mwrock](https://github.com/mwrock))
- Stop uploading empty directories [\#530](https://github.com/test-kitchen/test-kitchen/pull/530) ([whiteley](https://github.com/whiteley))

## [v1.3.1](https://github.com/test-kitchen/test-kitchen/tree/v1.3.1) (2015-01-16)
[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v1.3.0...v1.3.1)

**Closed issues:**

- chef\_omnibus\_install\_options not appended properly [\#580](https://github.com/test-kitchen/test-kitchen/issues/580)
- 1.3.0 contains a breaking change but the major version was not incremented [\#578](https://github.com/test-kitchen/test-kitchen/issues/578)

**Merged pull requests:**

- Fix omnibus install argument passing bug with missing space character. [\#581](https://github.com/test-kitchen/test-kitchen/pull/581) ([fnichol](https://github.com/fnichol))
- update README.md badges to use SVG [\#579](https://github.com/test-kitchen/test-kitchen/pull/579) ([miketheman](https://github.com/miketheman))

## [v1.3.0](https://github.com/test-kitchen/test-kitchen/tree/v1.3.0) (2015-01-15)
[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v1.2.1...v1.3.0)

**Fixed bugs:**

- a way to override ~/.kitchen/config.yml [\#524](https://github.com/test-kitchen/test-kitchen/issues/524)

**Closed issues:**

- Bundler fails to install test-kitchen alongside chef 12.0.3 [\#577](https://github.com/test-kitchen/test-kitchen/issues/577)
- Conflicts with chef 12 [\#570](https://github.com/test-kitchen/test-kitchen/issues/570)
- Test Kitchen/Chef in non networked mode [\#569](https://github.com/test-kitchen/test-kitchen/issues/569)
- http://kitchen.ci is down [\#551](https://github.com/test-kitchen/test-kitchen/issues/551)
- chef-solo causes converge to fail after installation of rvm system wide [\#548](https://github.com/test-kitchen/test-kitchen/issues/548)
- Failed to complete \#converge action: \[Berkshelf::UnknownCompressionType\] [\#547](https://github.com/test-kitchen/test-kitchen/issues/547)
- busser not found [\#545](https://github.com/test-kitchen/test-kitchen/issues/545)
- DNS Lookups [\#542](https://github.com/test-kitchen/test-kitchen/issues/542)
- "ERROR: No such file or directory" on converge [\#537](https://github.com/test-kitchen/test-kitchen/issues/537)
- Kitchen fail if cookbook named certain way [\#536](https://github.com/test-kitchen/test-kitchen/issues/536)
- Integrate with Packer \(so passing 'builds' can be built into boxes, then saved\) [\#535](https://github.com/test-kitchen/test-kitchen/issues/535)
- kitchen command shows also the docker usage. [\#532](https://github.com/test-kitchen/test-kitchen/issues/532)
- Question: Chef install by default [\#523](https://github.com/test-kitchen/test-kitchen/issues/523)
- Test Kitchen not seeing cookbooks? [\#517](https://github.com/test-kitchen/test-kitchen/issues/517)
- Serverspec exit code 1 without error message [\#513](https://github.com/test-kitchen/test-kitchen/issues/513)
- kitchen-ssh : SSH EXITED error.  [\#509](https://github.com/test-kitchen/test-kitchen/issues/509)
- difference between /tmp/kitchen/cache/cookbooks and /tmp/kitchen/cookbooks? [\#508](https://github.com/test-kitchen/test-kitchen/issues/508)
- Running two kitchen converges parallely? [\#506](https://github.com/test-kitchen/test-kitchen/issues/506)
- Failed to complete \#create action: \[undefined local variable or method `default\_port' for \#\<Kitchen::Driver::Vagrant [\#505](https://github.com/test-kitchen/test-kitchen/issues/505)
- Environment problems again [\#502](https://github.com/test-kitchen/test-kitchen/issues/502)
- Test-kitchen 1.2.1 and Berkshelf version [\#492](https://github.com/test-kitchen/test-kitchen/issues/492)
- Putting a / in platform.version in .kitchen.yml has weird results [\#483](https://github.com/test-kitchen/test-kitchen/issues/483)
- Chef Runs fail at the end with chef-solo [\#472](https://github.com/test-kitchen/test-kitchen/issues/472)
- Berkshelf::NoSolutionError [\#471](https://github.com/test-kitchen/test-kitchen/issues/471)
- Warning: Connection timeout [\#464](https://github.com/test-kitchen/test-kitchen/issues/464)
- Add ability to run multiple drivers in .kitchen.yml [\#459](https://github.com/test-kitchen/test-kitchen/issues/459)
- Accidentally installed vagrant in Gemfile, now test-kitchen is broken [\#455](https://github.com/test-kitchen/test-kitchen/issues/455)
- During converge on Win 8.1 x64: Creation of file mapping failed with error: 998 [\#448](https://github.com/test-kitchen/test-kitchen/issues/448)
-  undefined method `full\_name' for nil:NilClass \(NoMethodError       \) [\#445](https://github.com/test-kitchen/test-kitchen/issues/445)
- Use vagrant-cachier, if available, for omnibus [\#440](https://github.com/test-kitchen/test-kitchen/issues/440)
- Documentation on kitchen functions [\#439](https://github.com/test-kitchen/test-kitchen/issues/439)
- Second converge run choses wrong chef version [\#436](https://github.com/test-kitchen/test-kitchen/issues/436)
- Duplicate output with chef-solo provisioner [\#433](https://github.com/test-kitchen/test-kitchen/issues/433)
- Vagrant 1.6 support [\#432](https://github.com/test-kitchen/test-kitchen/issues/432)
- Zero byte state files cause undefined method errors [\#430](https://github.com/test-kitchen/test-kitchen/issues/430)
- Make SSH retries and sleep times configurable [\#422](https://github.com/test-kitchen/test-kitchen/issues/422)
- Failed to complete \#converge action: \[Berkshelf::BerksfileReadError\] [\#419](https://github.com/test-kitchen/test-kitchen/issues/419)
- Add Vagrant share feature? [\#413](https://github.com/test-kitchen/test-kitchen/issues/413)
- Unable to run test kitchen with datadog agent [\#412](https://github.com/test-kitchen/test-kitchen/issues/412)
- not finding \*.rb roles [\#408](https://github.com/test-kitchen/test-kitchen/issues/408)
- "I cannot read /tmp/kitchen/client.pem, which you told me to use to sign requests!" [\#407](https://github.com/test-kitchen/test-kitchen/issues/407)
- Support multiple provisions to run in sequence [\#404](https://github.com/test-kitchen/test-kitchen/issues/404)
- Step 1 in create fails on Ubuntu 12.04, trying to run "yum" [\#403](https://github.com/test-kitchen/test-kitchen/issues/403)
- Bats tests failing when they shouldn't [\#402](https://github.com/test-kitchen/test-kitchen/issues/402)
- Kitchen ShellOut to Vagrant with Bundler 1.6.0 install fails [\#401](https://github.com/test-kitchen/test-kitchen/issues/401)
-  \[undefined method `each' for nil:NilClass\] [\#395](https://github.com/test-kitchen/test-kitchen/issues/395)
- provide requirements to create a linux box with test-kitchen support [\#392](https://github.com/test-kitchen/test-kitchen/issues/392)
- kitchen-puppet gem [\#391](https://github.com/test-kitchen/test-kitchen/issues/391)
- Verify hits wrong instance [\#390](https://github.com/test-kitchen/test-kitchen/issues/390)
- Test Kitchen Gotchas [\#388](https://github.com/test-kitchen/test-kitchen/issues/388)
- require\_chef\_omnibus: latest reinstalls chef on each converge [\#387](https://github.com/test-kitchen/test-kitchen/issues/387)
- Cookbooks missing when run from one host, but not another [\#386](https://github.com/test-kitchen/test-kitchen/issues/386)
- kitchen init throws cannot load win32/process & windows/handle on Windows 8.1 x64 [\#385](https://github.com/test-kitchen/test-kitchen/issues/385)
- Getting a Berkshelf::BerksfileReadError error when trying to converge [\#383](https://github.com/test-kitchen/test-kitchen/issues/383)
- `kitchen list` failing [\#379](https://github.com/test-kitchen/test-kitchen/issues/379)
- Allow the use of instance index as well as name for commands [\#378](https://github.com/test-kitchen/test-kitchen/issues/378)
- Attributes not changing between Test Suites [\#376](https://github.com/test-kitchen/test-kitchen/issues/376)
- "kitchen login" to an uncreated box throws 'ssh' help [\#375](https://github.com/test-kitchen/test-kitchen/issues/375)
- kitchen list slow when Berksfile in chef repo [\#371](https://github.com/test-kitchen/test-kitchen/issues/371)
- include vagrant-box requirements on README [\#365](https://github.com/test-kitchen/test-kitchen/issues/365)
- Address in use issue with Chef Zero support doesn't allow repeated converges [\#361](https://github.com/test-kitchen/test-kitchen/issues/361)
- Weird logging output/colors [\#352](https://github.com/test-kitchen/test-kitchen/issues/352)
- Create a driver for opennebula... [\#351](https://github.com/test-kitchen/test-kitchen/issues/351)
- Test-Kitchen with Berks failing [\#348](https://github.com/test-kitchen/test-kitchen/issues/348)
- Need to fix .kitchen.local.yml behavior [\#343](https://github.com/test-kitchen/test-kitchen/issues/343)
- No way to disable colors [\#330](https://github.com/test-kitchen/test-kitchen/issues/330)
- Create busser for testing Window's machines with DSC [\#239](https://github.com/test-kitchen/test-kitchen/issues/239)
- Support the equivalent of 'halt' on providers that handle it [\#144](https://github.com/test-kitchen/test-kitchen/issues/144)
- SSH-based drivers: SCP a single cookbook tarball to test instance [\#35](https://github.com/test-kitchen/test-kitchen/issues/35)
- Support an option to add minitest-handler to run list [\#22](https://github.com/test-kitchen/test-kitchen/issues/22)

**Merged pull requests:**

- Pass the template filename down to Erb for \_\_FILE\_\_ et al [\#567](https://github.com/test-kitchen/test-kitchen/pull/567) ([coderanger](https://github.com/coderanger))
- \[Breaking\] Correct global YAML merge order to lowest \(from highest\). [\#555](https://github.com/test-kitchen/test-kitchen/pull/555) ([fnichol](https://github.com/fnichol))
- Replace `/` with `-` in Instance names. [\#554](https://github.com/test-kitchen/test-kitchen/pull/554) ([fnichol](https://github.com/fnichol))
- Merge Salim & Jay's transport work, plus Chris's spec fixes [\#553](https://github.com/test-kitchen/test-kitchen/pull/553) ([randomcamel](https://github.com/randomcamel))
- Allow to set chef-zero-host when using the Chef Zero provider [\#549](https://github.com/test-kitchen/test-kitchen/pull/549) ([jochenseeber](https://github.com/jochenseeber))
- bump mixlib-shellout deps [\#531](https://github.com/test-kitchen/test-kitchen/pull/531) ([lamont-granquist](https://github.com/lamont-granquist))
- Auth failure retry [\#527](https://github.com/test-kitchen/test-kitchen/pull/527) ([chrishenry](https://github.com/chrishenry))
- Die on `kitchen login` if instance is not created. [\#526](https://github.com/test-kitchen/test-kitchen/pull/526) ([fnichol](https://github.com/fnichol))
- chef-provisioner: add support for site-cookbooks when using Librarian [\#510](https://github.com/test-kitchen/test-kitchen/pull/510) ([jstriebel](https://github.com/jstriebel))
- Minor test fixes to SSHBase [\#504](https://github.com/test-kitchen/test-kitchen/pull/504) ([jgoldschrafe](https://github.com/jgoldschrafe))
- Typo [\#498](https://github.com/test-kitchen/test-kitchen/pull/498) ([jaimegildesagredo](https://github.com/jaimegildesagredo))
- Disable color output when no TTY is present. [\#481](https://github.com/test-kitchen/test-kitchen/pull/481) ([fnichol](https://github.com/fnichol))
- Buffer Logger output & fix Chef run output formatting [\#478](https://github.com/test-kitchen/test-kitchen/pull/478) ([fnichol](https://github.com/fnichol))
- Bump 'kitchen help' into new Usage section and add how to use "-l". [\#477](https://github.com/test-kitchen/test-kitchen/pull/477) ([curiositycasualty](https://github.com/curiositycasualty))
- typeo confiuration -\> configuration [\#457](https://github.com/test-kitchen/test-kitchen/pull/457) ([michaelkirk](https://github.com/michaelkirk))
- Customize ssh\_timeout and ssh\_retries [\#454](https://github.com/test-kitchen/test-kitchen/pull/454) ([ekrupnik](https://github.com/ekrupnik))
- Help update [\#450](https://github.com/test-kitchen/test-kitchen/pull/450) ([MarkGibbons](https://github.com/MarkGibbons))
- Backfilling spec coverage and refactoring: technical debt edition [\#427](https://github.com/test-kitchen/test-kitchen/pull/427) ([fnichol](https://github.com/fnichol))
- Gem runner install driver [\#416](https://github.com/test-kitchen/test-kitchen/pull/416) ([mcquin](https://github.com/mcquin))
- Sleep before retrying SSH\#establish\_connection. [\#399](https://github.com/test-kitchen/test-kitchen/pull/399) ([fnichol](https://github.com/fnichol))
- make chef\_zero port configurable [\#397](https://github.com/test-kitchen/test-kitchen/pull/397) ([jtgiri](https://github.com/jtgiri))
- Use the full path to `chef-solo` and `chef-client` [\#381](https://github.com/test-kitchen/test-kitchen/pull/381) ([sethvargo](https://github.com/sethvargo))
- Add new subcommand 'exec' [\#373](https://github.com/test-kitchen/test-kitchen/pull/373) ([sawanoboly](https://github.com/sawanoboly))
- Use Ruby 2.1 instead of 2.1.0 for CI [\#370](https://github.com/test-kitchen/test-kitchen/pull/370) ([justincampbell](https://github.com/justincampbell))
- Nitpick spelling [\#366](https://github.com/test-kitchen/test-kitchen/pull/366) ([srenatus](https://github.com/srenatus))
- Ensure that integer chef config attributes get placed in solo.rb/client.rb properly [\#363](https://github.com/test-kitchen/test-kitchen/pull/363) ([benlangfeld](https://github.com/benlangfeld))

## [v1.2.1](https://github.com/test-kitchen/test-kitchen/tree/v1.2.1) (2014-02-12)
[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v1.2.0...v1.2.1)

**Fixed bugs:**

- Test Kitchen 1.2.0 breaks Berkshelf 2.0 on \(OS X\) [\#357](https://github.com/test-kitchen/test-kitchen/issues/357)

**Merged pull requests:**

- Load needed \(dynamic\) dependencies for provisioners at creation time. [\#358](https://github.com/test-kitchen/test-kitchen/pull/358) ([fnichol](https://github.com/fnichol))

## [v1.2.0](https://github.com/test-kitchen/test-kitchen/tree/v1.2.0) (2014-02-12)
[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v0.8.0...v1.2.0)

**Fixed bugs:**

- kitchen converge does not fail when chef run fails [\#346](https://github.com/test-kitchen/test-kitchen/issues/346)

**Merged pull requests:**

- Kamalika | added exit status check in chef-zero support for chef 10 [\#353](https://github.com/test-kitchen/test-kitchen/pull/353) ([kamalim](https://github.com/kamalim))

## [v0.8.0](https://github.com/test-kitchen/test-kitchen/tree/v0.8.0) (2014-02-12)
[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v1.1.1...v0.8.0)

**Fixed bugs:**

- Failed to complete \#converge action: \[no implicit conversion of nil into String\]  [\#335](https://github.com/test-kitchen/test-kitchen/issues/335)
- SSH connection failed, connection closed by remote host [\#323](https://github.com/test-kitchen/test-kitchen/issues/323)
- Command line errors don't set exit status [\#305](https://github.com/test-kitchen/test-kitchen/issues/305)
- Commented out .kitchen.local.yml causes failure of test-kitchen [\#285](https://github.com/test-kitchen/test-kitchen/issues/285)
- not proper response when part of node name same [\#282](https://github.com/test-kitchen/test-kitchen/issues/282)

**Closed issues:**

- support for command-line option to select driver \(fast local TDD vs. remote ci testing\) [\#345](https://github.com/test-kitchen/test-kitchen/issues/345)
-  Message: SSH exited \(1\) for command: \[sudo -E /tmp/kitchen/bootstrap.sh\] [\#342](https://github.com/test-kitchen/test-kitchen/issues/342)
- Can't login to machine due to ambiguous name. [\#341](https://github.com/test-kitchen/test-kitchen/issues/341)
- Unable to set a chef environment for a node [\#340](https://github.com/test-kitchen/test-kitchen/issues/340)
- Multiple run on the same box [\#339](https://github.com/test-kitchen/test-kitchen/issues/339)
- Using search functions. [\#337](https://github.com/test-kitchen/test-kitchen/issues/337)
- Could not load the 'shell' provisioner from the load path [\#334](https://github.com/test-kitchen/test-kitchen/issues/334)
- Shell Provisioner [\#331](https://github.com/test-kitchen/test-kitchen/issues/331)
- cookbook files not copied to vagrant box [\#328](https://github.com/test-kitchen/test-kitchen/issues/328)
- The SciFi Future of Provisioner Install Commands. [\#326](https://github.com/test-kitchen/test-kitchen/issues/326)
- Reboot during Test Kitchen run? [\#324](https://github.com/test-kitchen/test-kitchen/issues/324)
- Node attributes do not seem to prevail between converge operations. [\#320](https://github.com/test-kitchen/test-kitchen/issues/320)
- Can't load data bags [\#317](https://github.com/test-kitchen/test-kitchen/issues/317)
- wiki bats example on Getting Started is overcomplex/bad pattern [\#314](https://github.com/test-kitchen/test-kitchen/issues/314)
- Subdirectories in "helpers" directory [\#312](https://github.com/test-kitchen/test-kitchen/issues/312)
- Override config file location via environment variables [\#304](https://github.com/test-kitchen/test-kitchen/issues/304)
- kitchen converge reinstalls chef using the omnibus installer even if its installed [\#299](https://github.com/test-kitchen/test-kitchen/issues/299)
- Chef environment support missing? [\#297](https://github.com/test-kitchen/test-kitchen/issues/297)
- Problem parsing metadata? [\#290](https://github.com/test-kitchen/test-kitchen/issues/290)
- serverspec failing [\#274](https://github.com/test-kitchen/test-kitchen/issues/274)
- I would like to execute some tasks before chef-client run at `kitchen converge`. [\#251](https://github.com/test-kitchen/test-kitchen/issues/251)
- Reduce internet downloading during test runs [\#196](https://github.com/test-kitchen/test-kitchen/issues/196)
- Allow to limit the number of parallel tests [\#176](https://github.com/test-kitchen/test-kitchen/issues/176)
- Implement `kitchen remodel` [\#150](https://github.com/test-kitchen/test-kitchen/issues/150)
- Make it possible \(or easier\) to run test-kitchen when off line [\#56](https://github.com/test-kitchen/test-kitchen/issues/56)
- Add project types to test-kitchen [\#46](https://github.com/test-kitchen/test-kitchen/issues/46)
- Create kitchen-fog driver that supports most Fog cloud providers [\#33](https://github.com/test-kitchen/test-kitchen/issues/33)
- support "preflight" commands [\#26](https://github.com/test-kitchen/test-kitchen/issues/26)
- If the project is a cookbook, attempt to use "test" cookbook in the default run list [\#24](https://github.com/test-kitchen/test-kitchen/issues/24)

**Merged pull requests:**

- Upload chef clients data [\#318](https://github.com/test-kitchen/test-kitchen/pull/318) ([jtimberman](https://github.com/jtimberman))
- Allow files in subdirectories in "helpers" directory [\#313](https://github.com/test-kitchen/test-kitchen/pull/313) ([mthssdrbrg](https://github.com/mthssdrbrg))
- Fix Windows path matching issues introduced by 1c924af2e9 [\#310](https://github.com/test-kitchen/test-kitchen/pull/310) ([rarenerd](https://github.com/rarenerd))
- adding /opt/local/bin to search path. smartmachines need this otherwise ... [\#309](https://github.com/test-kitchen/test-kitchen/pull/309) ([someara](https://github.com/someara))
- Add local & global file locations with environment variables. [\#306](https://github.com/test-kitchen/test-kitchen/pull/306) ([fnichol](https://github.com/fnichol))
- Use SafeYAML.load to avoid YAML monkeypatch in safe\_yaml. [\#303](https://github.com/test-kitchen/test-kitchen/pull/303) ([fnichol](https://github.com/fnichol))
- CLI refactoring to remove logic from cli.rb [\#302](https://github.com/test-kitchen/test-kitchen/pull/302) ([fnichol](https://github.com/fnichol))
- Base provisioner refactoring [\#298](https://github.com/test-kitchen/test-kitchen/pull/298) ([fnichol](https://github.com/fnichol))
- Fixing error when using more than one helper [\#296](https://github.com/test-kitchen/test-kitchen/pull/296) ([jschneiderhan](https://github.com/jschneiderhan))
- Add --concurrency option to specify number of multiple actions to perform at a time. [\#293](https://github.com/test-kitchen/test-kitchen/pull/293) ([ryotarai](https://github.com/ryotarai))
- Update omnibus URL to getchef.com. [\#288](https://github.com/test-kitchen/test-kitchen/pull/288) ([juliandunn](https://github.com/juliandunn))
- Fix Cucumber tests on Windows [\#287](https://github.com/test-kitchen/test-kitchen/pull/287) ([rarenerd](https://github.com/rarenerd))
- Fix failing minitest test on Windows [\#283](https://github.com/test-kitchen/test-kitchen/pull/283) ([rarenerd](https://github.com/rarenerd))
- Add `json\_attributes: true` config option to ChefZero provisioner. [\#280](https://github.com/test-kitchen/test-kitchen/pull/280) ([fnichol](https://github.com/fnichol))

## [v1.1.1](https://github.com/test-kitchen/test-kitchen/tree/v1.1.1) (2013-12-09)
[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v1.1.0...v1.1.1)

**Fixed bugs:**

- Calling a test "database\_spec.rb" make it impossible to be played ! [\#276](https://github.com/test-kitchen/test-kitchen/issues/276)

**Closed issues:**

- not uploading database\_spec.rb test file [\#278](https://github.com/test-kitchen/test-kitchen/issues/278)

**Merged pull requests:**

- Fix SSH 'Too many authentication failures' error. [\#275](https://github.com/test-kitchen/test-kitchen/pull/275) ([zts](https://github.com/zts))

## [v1.1.0](https://github.com/test-kitchen/test-kitchen/tree/v1.1.0) (2013-12-05)
[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v1.0.0...v1.1.0)

**Closed issues:**

- Website Down? [\#271](https://github.com/test-kitchen/test-kitchen/issues/271)
- test for service not work correctly [\#270](https://github.com/test-kitchen/test-kitchen/issues/270)
- Document the newly introduced need to specify 'sudo: true' [\#269](https://github.com/test-kitchen/test-kitchen/issues/269)

**Merged pull requests:**

- drive by typo fix [\#272](https://github.com/test-kitchen/test-kitchen/pull/272) ([kisoku](https://github.com/kisoku))

## [v1.0.0](https://github.com/test-kitchen/test-kitchen/tree/v1.0.0) (2013-12-02)
[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v1.0.0.rc.2...v1.0.0)

**Closed issues:**

- crash on mac os x [\#268](https://github.com/test-kitchen/test-kitchen/issues/268)
- kitchen list does not read state file when using --debug [\#267](https://github.com/test-kitchen/test-kitchen/issues/267)

## [v1.0.0.rc.2](https://github.com/test-kitchen/test-kitchen/tree/v1.0.0.rc.2) (2013-11-30)
[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v1.0.0.rc.1...v1.0.0.rc.2)

**Closed issues:**

- Does test-kitchen support aws provider ? [\#264](https://github.com/test-kitchen/test-kitchen/issues/264)
- Fog driver: ship with a sane set of image\_id/flavor\_id combinations for default platforms [\#34](https://github.com/test-kitchen/test-kitchen/issues/34)

**Merged pull requests:**

- Make a nicer error on regexp failure [\#266](https://github.com/test-kitchen/test-kitchen/pull/266) ([juliandunn](https://github.com/juliandunn))
- Busser Fixes for Greybeard UNIX [\#265](https://github.com/test-kitchen/test-kitchen/pull/265) ([schisamo](https://github.com/schisamo))

## [v1.0.0.rc.1](https://github.com/test-kitchen/test-kitchen/tree/v1.0.0.rc.1) (2013-11-28)
[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v1.0.0.beta.4...v1.0.0.rc.1)

**Fixed bugs:**

- "Destroy" flag does not behave consistently, and the docs appear to be wrong [\#255](https://github.com/test-kitchen/test-kitchen/issues/255)
- Chef Zero provisioner does not respect `require\_chef\_omnibus` config [\#243](https://github.com/test-kitchen/test-kitchen/issues/243)
- Gem path issues after test-kitchen beta 4 new sandbox. [\#242](https://github.com/test-kitchen/test-kitchen/issues/242)
- Absolute Paths for Suite Data Bags, Roles, and Nodes are Set to Nil [\#227](https://github.com/test-kitchen/test-kitchen/pull/227) ([ajmath](https://github.com/ajmath))
- add `skip\_git` option to Init Generator [\#141](https://github.com/test-kitchen/test-kitchen/pull/141) ([reset](https://github.com/reset))

**Closed issues:**

- is test-kitchen appropriate for running deploys? [\#252](https://github.com/test-kitchen/test-kitchen/issues/252)
- role run\_lists seems to be ignored [\#250](https://github.com/test-kitchen/test-kitchen/issues/250)
- Add default value for encrypted\_data\_bag\_secret\_key\_path [\#248](https://github.com/test-kitchen/test-kitchen/issues/248)
- `uninitialized constant Berkshelf::Chef::Config::Ohai\]` [\#244](https://github.com/test-kitchen/test-kitchen/issues/244)
- gem\_package using chef\_zero installing packages into /tmp/kitchen-chef-zero making binstubs unavailable to chef [\#240](https://github.com/test-kitchen/test-kitchen/issues/240)
- Error on ubuntu images only  [\#220](https://github.com/test-kitchen/test-kitchen/issues/220)
- Allow test-kitchen to use different configs \(e.g. --config option\)? [\#210](https://github.com/test-kitchen/test-kitchen/issues/210)
- solo.rb file content should be configurable [\#117](https://github.com/test-kitchen/test-kitchen/issues/117)
- Documentation [\#110](https://github.com/test-kitchen/test-kitchen/issues/110)
- Possible problems with parallel testing  [\#68](https://github.com/test-kitchen/test-kitchen/issues/68)

**Merged pull requests:**

- Use a configurable glob pattern to select Chef cookbook files. [\#262](https://github.com/test-kitchen/test-kitchen/pull/262) ([fnichol](https://github.com/fnichol))
- Fix inconsistent date in CHANGELOG [\#259](https://github.com/test-kitchen/test-kitchen/pull/259) ([ryansouza](https://github.com/ryansouza))
- Fix Busser and chef-client-zero.rb Gem Sandboxing [\#258](https://github.com/test-kitchen/test-kitchen/pull/258) ([fnichol](https://github.com/fnichol))
- Changed 'passed' to 'passing' in the Destroy options [\#256](https://github.com/test-kitchen/test-kitchen/pull/256) ([scarolan](https://github.com/scarolan))
- update references to test-kitchen org [\#254](https://github.com/test-kitchen/test-kitchen/pull/254) ([josephholsten](https://github.com/josephholsten))
- Fix travis-ci badge [\#253](https://github.com/test-kitchen/test-kitchen/pull/253) ([arangamani](https://github.com/arangamani))
- Add data path as optional configuration [\#249](https://github.com/test-kitchen/test-kitchen/pull/249) ([oferrigni](https://github.com/oferrigni))
- Fix init generator to simplify YAML [\#246](https://github.com/test-kitchen/test-kitchen/pull/246) ([sethvargo](https://github.com/sethvargo))
- Bust out of gem sandbox before chef-client run; Fixes \#240 [\#241](https://github.com/test-kitchen/test-kitchen/pull/241) ([schisamo](https://github.com/schisamo))
- Show less output [\#238](https://github.com/test-kitchen/test-kitchen/pull/238) ([sethvargo](https://github.com/sethvargo))
- Add option to run a stanza on a fixed set of platforms [\#165](https://github.com/test-kitchen/test-kitchen/pull/165) ([coderanger](https://github.com/coderanger))
- Read CLI options from kitchen.yml [\#121](https://github.com/test-kitchen/test-kitchen/pull/121) ([atomic-penguin](https://github.com/atomic-penguin))

## [v1.0.0.beta.4](https://github.com/test-kitchen/test-kitchen/tree/v1.0.0.beta.4) (2013-11-01)
[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v1.0.0.beta.3...v1.0.0.beta.4)

**Fixed bugs:**

- cannot load such file -- chef\_fs/chef\_fs\_data\_store \(LoadError\)  [\#230](https://github.com/test-kitchen/test-kitchen/issues/230)
- should\_update\_chef logic appears broken [\#191](https://github.com/test-kitchen/test-kitchen/issues/191)
- chef-zero fails to install without build-essential [\#190](https://github.com/test-kitchen/test-kitchen/issues/190)
- Pin dependency of safe\_yaml to 0.9.3 or wait on upstream to release and yank 0.9.4 [\#181](https://github.com/test-kitchen/test-kitchen/issues/181)
- kitchen test --parallel never times out, never errors out, despite an error [\#169](https://github.com/test-kitchen/test-kitchen/issues/169)
- Temporary files can be still uploaded [\#132](https://github.com/test-kitchen/test-kitchen/issues/132)
- Kitchen destroy leaves orphans behind [\#109](https://github.com/test-kitchen/test-kitchen/issues/109)
- kitchen uses 100% CPU after a failure with the --parallel flag [\#100](https://github.com/test-kitchen/test-kitchen/issues/100)

**Closed issues:**

- kitchen verify fails due to gem conflict [\#234](https://github.com/test-kitchen/test-kitchen/issues/234)
- kitchen-test outputs "can't convert Symbol into Integer" [\#223](https://github.com/test-kitchen/test-kitchen/issues/223)
- Failed require is not necessarily missing gem [\#215](https://github.com/test-kitchen/test-kitchen/issues/215)
- Certain platforms \(e.g., solaris, omnios\) may not have /usr/bin symlinks for chef [\#213](https://github.com/test-kitchen/test-kitchen/issues/213)
- Provide config option to add to the list of cookbook files. [\#211](https://github.com/test-kitchen/test-kitchen/issues/211)
- Since Sept 27 I'm no longer able to bundle test-kitchen master with berkshelf 2.0.10 [\#209](https://github.com/test-kitchen/test-kitchen/issues/209)
- 2.0 [\#207](https://github.com/test-kitchen/test-kitchen/issues/207)
- Are Vagrant environments supported in .kitchen.yml [\#205](https://github.com/test-kitchen/test-kitchen/issues/205)
- with OpenStack Driver, can not exec 'kitchen create' [\#204](https://github.com/test-kitchen/test-kitchen/issues/204)
- Test kitchen fails to install busser properly when system-level rvm installed ruby exists [\#200](https://github.com/test-kitchen/test-kitchen/issues/200)
- Environment support for Chef Solo [\#199](https://github.com/test-kitchen/test-kitchen/issues/199)
- Tests are not picked up when using chef-zero provisioner [\#189](https://github.com/test-kitchen/test-kitchen/issues/189)
- /tmp/kitchen-chef-solo permissions issue [\#186](https://github.com/test-kitchen/test-kitchen/issues/186)
- Idea: Kitchenfile config [\#182](https://github.com/test-kitchen/test-kitchen/issues/182)
- Automatically trigger berks install -o \<test suite\> group on test run [\#173](https://github.com/test-kitchen/test-kitchen/issues/173)
- Propose Switch to allow for only the test result output from each busser [\#168](https://github.com/test-kitchen/test-kitchen/issues/168)
- Allow for site-cookbooks [\#166](https://github.com/test-kitchen/test-kitchen/issues/166)
- Be more paranoid about dependencies [\#149](https://github.com/test-kitchen/test-kitchen/issues/149)
- New .kitchen.yml syntax? [\#138](https://github.com/test-kitchen/test-kitchen/issues/138)
- Could not find gem 'test-kitchen \(\>= 0\) ruby' [\#135](https://github.com/test-kitchen/test-kitchen/issues/135)
- It says Starting Kitchen when destroying your test vm's [\#133](https://github.com/test-kitchen/test-kitchen/issues/133)
- "sudo: unable to resolve host default-precise64-vmware-fusion.vagrantup.com" [\#127](https://github.com/test-kitchen/test-kitchen/issues/127)
- Create a kitchen driver for SmartOS [\#125](https://github.com/test-kitchen/test-kitchen/issues/125)
- Allow for enhanced Berksfile syntax within a given suite [\#93](https://github.com/test-kitchen/test-kitchen/issues/93)
- Passing the -h flag to a command starts the suite [\#86](https://github.com/test-kitchen/test-kitchen/issues/86)
- test-kitchen 1.0.0-alpha & chef-solo-search not working [\#70](https://github.com/test-kitchen/test-kitchen/issues/70)
- Consider adding `driver\_config` to a Suite. [\#69](https://github.com/test-kitchen/test-kitchen/issues/69)
- Don't remove code based configuration. [\#40](https://github.com/test-kitchen/test-kitchen/issues/40)

**Merged pull requests:**

- Added environments support for chef-solo [\#235](https://github.com/test-kitchen/test-kitchen/pull/235) ([ekrupnik](https://github.com/ekrupnik))
- Concurrent threads [\#226](https://github.com/test-kitchen/test-kitchen/pull/226) ([fnichol](https://github.com/fnichol))
- Improves Test Kitchen's support for older \(non-Linux\) Unixes [\#225](https://github.com/test-kitchen/test-kitchen/pull/225) ([schisamo](https://github.com/schisamo))
- Remove celluloid and use pure Ruby threads [\#222](https://github.com/test-kitchen/test-kitchen/pull/222) ([sethvargo](https://github.com/sethvargo))
- Add pessismestic locks to all gem requirements [\#206](https://github.com/test-kitchen/test-kitchen/pull/206) ([sethvargo](https://github.com/sethvargo))
- fixed berkself typo to berkshelf [\#203](https://github.com/test-kitchen/test-kitchen/pull/203) ([gmiranda23](https://github.com/gmiranda23))
- Multiple arguments to test \(verify, converge, etc\) [\#94](https://github.com/test-kitchen/test-kitchen/pull/94) ([miketheman](https://github.com/miketheman))

## [v1.0.0.beta.3](https://github.com/test-kitchen/test-kitchen/tree/v1.0.0.beta.3) (2013-08-29)
[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v1.0.0.beta.2...v1.0.0.beta.3)

**Closed issues:**

- Set hostname fails on openSUSE 11.x [\#185](https://github.com/test-kitchen/test-kitchen/issues/185)
- Ability to test recipes that require multiple VMs connected to a chef server [\#184](https://github.com/test-kitchen/test-kitchen/issues/184)
- Berkshelf Missing [\#183](https://github.com/test-kitchen/test-kitchen/issues/183)
- Invalid logger call? [\#175](https://github.com/test-kitchen/test-kitchen/issues/175)

**Merged pull requests:**

- truthy default\_configs can't be overridden [\#188](https://github.com/test-kitchen/test-kitchen/pull/188) ([thommay](https://github.com/thommay))
- \[KITCHEN-80\] added support for log file in chef solo [\#187](https://github.com/test-kitchen/test-kitchen/pull/187) ([arangamani](https://github.com/arangamani))
- Remove bundler references from README. [\#179](https://github.com/test-kitchen/test-kitchen/pull/179) ([juliandunn](https://github.com/juliandunn))
- Fix SSH\#wait's logger call to \#info [\#178](https://github.com/test-kitchen/test-kitchen/pull/178) ([ryansouza](https://github.com/ryansouza))

## [v1.0.0.beta.2](https://github.com/test-kitchen/test-kitchen/tree/v1.0.0.beta.2) (2013-07-25)
[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v1.0.0.beta.1...v1.0.0.beta.2)

## [v1.0.0.beta.1](https://github.com/test-kitchen/test-kitchen/tree/v1.0.0.beta.1) (2013-07-23)
[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v0.5.1...v1.0.0.beta.1)

**Fixed bugs:**

- Kitchen.celluloid\_file\_logger creates .kitchen when using knife [\#153](https://github.com/test-kitchen/test-kitchen/issues/153)
- Error during test hangs, steals CPU [\#89](https://github.com/test-kitchen/test-kitchen/issues/89)
- unintuitive error message when kitchen driver specified in .kitchen.yml isn't found [\#80](https://github.com/test-kitchen/test-kitchen/issues/80)
- and empty \(or commented out\) .kitchen.local.yml file causes failure. [\#42](https://github.com/test-kitchen/test-kitchen/issues/42)
- kitchen commands should respond properly to CTL-C [\#30](https://github.com/test-kitchen/test-kitchen/issues/30)
- File.exists? calls within init generator must include the destination root for portability purposes [\#140](https://github.com/test-kitchen/test-kitchen/pull/140) ([reset](https://github.com/reset))

**Closed issues:**

- Set a more sane default PATH for installing Chef [\#163](https://github.com/test-kitchen/test-kitchen/issues/163)
- Build is broken w/ RubyGems 1.8.25 + Ruby 2.0.0 [\#160](https://github.com/test-kitchen/test-kitchen/issues/160)
- Build is broken! [\#159](https://github.com/test-kitchen/test-kitchen/issues/159)
- `kitchen converge` not uploading definitions directory [\#156](https://github.com/test-kitchen/test-kitchen/issues/156)
- The NSA censors your VM names when using a terminal with a light background [\#154](https://github.com/test-kitchen/test-kitchen/issues/154)
- Update bucket name for Opscode's bento-built boxes [\#151](https://github.com/test-kitchen/test-kitchen/issues/151)
- kitchen test fails with undefined method `full\_name' [\#146](https://github.com/test-kitchen/test-kitchen/issues/146)
- safe\_yaml not found [\#137](https://github.com/test-kitchen/test-kitchen/issues/137)
- Support for data bags in Cookbooks under test [\#129](https://github.com/test-kitchen/test-kitchen/issues/129)
- Configuration management tools/provisioners should be pluggable [\#107](https://github.com/test-kitchen/test-kitchen/issues/107)
- Provide option for running chef-client instead of chef-solo [\#103](https://github.com/test-kitchen/test-kitchen/issues/103)
- Test-kitchen should not use the color red for non-error information [\#97](https://github.com/test-kitchen/test-kitchen/issues/97)
- More colors! [\#96](https://github.com/test-kitchen/test-kitchen/issues/96)
- Order of operations not clear. [\#88](https://github.com/test-kitchen/test-kitchen/issues/88)
- logging should be configured by the .kitchen.yml or .kitchen.local.yml [\#63](https://github.com/test-kitchen/test-kitchen/issues/63)
- Consider setting `driver\[:require\_chef\_omnibus\] = true` by default [\#62](https://github.com/test-kitchen/test-kitchen/issues/62)
- kitchen subcommands should error out gracefully if .kitchen.yml cannot be properly loaded [\#37](https://github.com/test-kitchen/test-kitchen/issues/37)
- init command should default to Berkshelf [\#28](https://github.com/test-kitchen/test-kitchen/issues/28)
- if cookbook metadata specifies platforms, only run tests against those platforms [\#27](https://github.com/test-kitchen/test-kitchen/issues/27)
- provide a converter for Kitchenfile -\> .kitchen.yml [\#19](https://github.com/test-kitchen/test-kitchen/issues/19)

**Merged pull requests:**

- \[Breaking\] Update signature of Driver.required\_config block. [\#172](https://github.com/test-kitchen/test-kitchen/pull/172) ([fnichol](https://github.com/fnichol))
- Support computed default values for Driver authors. [\#171](https://github.com/test-kitchen/test-kitchen/pull/171) ([fnichol](https://github.com/fnichol))
- add asterisk to  wait\_for\_sshd argument [\#170](https://github.com/test-kitchen/test-kitchen/pull/170) ([ainoya](https://github.com/ainoya))
- set a default $PATH [\#164](https://github.com/test-kitchen/test-kitchen/pull/164) ([jtimberman](https://github.com/jtimberman))
- \[KITCHEN-77\] Allow custom paths [\#161](https://github.com/test-kitchen/test-kitchen/pull/161) ([gondoi](https://github.com/gondoi))
- Setting :on\_black when your default terminal text color is black results in unreadable \(black on black\) text. [\#155](https://github.com/test-kitchen/test-kitchen/pull/155) ([mconigliaro](https://github.com/mconigliaro))
- Fixes \#151 - Update the bucket name for Opscode's Bento Boxes [\#152](https://github.com/test-kitchen/test-kitchen/pull/152) ([jtimberman](https://github.com/jtimberman))
- Allow chef omnibus install.sh url to be configurable [\#147](https://github.com/test-kitchen/test-kitchen/pull/147) ([jrwesolo](https://github.com/jrwesolo))
- require a safe\_yaml release with correct permissions. Fixes \#137 [\#142](https://github.com/test-kitchen/test-kitchen/pull/142) ([josephholsten](https://github.com/josephholsten))
- Fixes bundler ref for 1.0. [\#136](https://github.com/test-kitchen/test-kitchen/pull/136) ([patcon](https://github.com/patcon))
- KITCHEN-75 - support cross suite helpers. [\#134](https://github.com/test-kitchen/test-kitchen/pull/134) ([rteabeault](https://github.com/rteabeault))
- Use ssh\_args for test\_ssh. [\#131](https://github.com/test-kitchen/test-kitchen/pull/131) ([jonsmorrow](https://github.com/jonsmorrow))
- Introduce Provisioners to support chef-client, puppet-apply, and puppet-agent [\#128](https://github.com/test-kitchen/test-kitchen/pull/128) ([fnichol](https://github.com/fnichol))
- Aggressively filter "non-cookbook" files before uploading to instances. [\#124](https://github.com/test-kitchen/test-kitchen/pull/124) ([fnichol](https://github.com/fnichol))
- Swap cookbook resolution strategy from shell outs to using Ruby APIs. [\#123](https://github.com/test-kitchen/test-kitchen/pull/123) ([fnichol](https://github.com/fnichol))
- Adding missing sudo calls to busser [\#122](https://github.com/test-kitchen/test-kitchen/pull/122) ([adamhjk](https://github.com/adamhjk))

## [v0.5.1](https://github.com/test-kitchen/test-kitchen/tree/v0.5.1) (2013-05-23)
[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v1.0.0.alpha.7...v0.5.1)

**Closed issues:**

- berks install errors should not be swallowed [\#118](https://github.com/test-kitchen/test-kitchen/issues/118)

## [v1.0.0.alpha.7](https://github.com/test-kitchen/test-kitchen/tree/v1.0.0.alpha.7) (2013-05-23)
[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v1.0.0.alpha.6...v1.0.0.alpha.7)

**Closed issues:**

- Update kitchen.yml template with provisionerless baseboxes [\#114](https://github.com/test-kitchen/test-kitchen/issues/114)
- Windows experience a non-starter [\#101](https://github.com/test-kitchen/test-kitchen/issues/101)
- Destroy flag is ignored if parallel flag is given. [\#98](https://github.com/test-kitchen/test-kitchen/issues/98)
- In the absence of a Berksfile, sadness abounds [\#92](https://github.com/test-kitchen/test-kitchen/issues/92)
- support global user-level config files [\#31](https://github.com/test-kitchen/test-kitchen/issues/31)

**Merged pull requests:**

- Add http and https\_proxy support [\#120](https://github.com/test-kitchen/test-kitchen/pull/120) ([adamhjk](https://github.com/adamhjk))
- Test Kitchen works on Windows with Vagrant [\#119](https://github.com/test-kitchen/test-kitchen/pull/119) ([adamhjk](https://github.com/adamhjk))
- Require the 'name' attribute is present in `metadata.rb` [\#116](https://github.com/test-kitchen/test-kitchen/pull/116) ([sethvargo](https://github.com/sethvargo))
- Fixes \#114, use provisionerless baseboxes [\#115](https://github.com/test-kitchen/test-kitchen/pull/115) ([jtimberman](https://github.com/jtimberman))
- \[KITCHEN-74\] Handle case where YAML parses as nil [\#113](https://github.com/test-kitchen/test-kitchen/pull/113) ([smith](https://github.com/smith))
- Add the sink [\#111](https://github.com/test-kitchen/test-kitchen/pull/111) ([sethvargo](https://github.com/sethvargo))
- Add Kitchen::VERSION to `-----\> Starting Kitchen` output [\#108](https://github.com/test-kitchen/test-kitchen/pull/108) ([fnichol](https://github.com/fnichol))
- Expand documentation around run-time switches. [\#105](https://github.com/test-kitchen/test-kitchen/pull/105) ([grahamc](https://github.com/grahamc))
- Set the default ssh port. [\#104](https://github.com/test-kitchen/test-kitchen/pull/104) ([calavera](https://github.com/calavera))
- Allow to override sudo. [\#102](https://github.com/test-kitchen/test-kitchen/pull/102) ([calavera](https://github.com/calavera))
- Ensure that destroy option is respected when --parallel is used. [\#99](https://github.com/test-kitchen/test-kitchen/pull/99) ([stevendanna](https://github.com/stevendanna))
- Fix minitest test examples link. [\#91](https://github.com/test-kitchen/test-kitchen/pull/91) ([calavera](https://github.com/calavera))
- Add a global config file [\#90](https://github.com/test-kitchen/test-kitchen/pull/90) ([thommay](https://github.com/thommay))

## [v1.0.0.alpha.6](https://github.com/test-kitchen/test-kitchen/tree/v1.0.0.alpha.6) (2013-05-08)
[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v1.0.0.alpha.5...v1.0.0.alpha.6)

**Closed issues:**

- UI nitpick [\#84](https://github.com/test-kitchen/test-kitchen/issues/84)

**Merged pull requests:**

- Add attribute encrypted\_data\_bag\_secret\_key\_path to Kitchen::Suite [\#77](https://github.com/test-kitchen/test-kitchen/pull/77) ([arunthampi](https://github.com/arunthampi))

## [v1.0.0.alpha.5](https://github.com/test-kitchen/test-kitchen/tree/v1.0.0.alpha.5) (2013-04-23)
[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v1.0.0.alpha.4...v1.0.0.alpha.5)

**Closed issues:**

- Support wget and curl for omnibus installs \(in `Kitchen::Driver::SSHBase`\) [\#61](https://github.com/test-kitchen/test-kitchen/issues/61)

**Merged pull requests:**

- Install Omnibus package via either wget or curl. [\#82](https://github.com/test-kitchen/test-kitchen/pull/82) ([fnichol](https://github.com/fnichol))
- Error report formatting [\#81](https://github.com/test-kitchen/test-kitchen/pull/81) ([fnichol](https://github.com/fnichol))
- Swap out shell-based kb for Ruby-based Busser gem [\#76](https://github.com/test-kitchen/test-kitchen/pull/76) ([fnichol](https://github.com/fnichol))

## [v1.0.0.alpha.4](https://github.com/test-kitchen/test-kitchen/tree/v1.0.0.alpha.4) (2013-04-10)
[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v1.0.0.alpha.3...v1.0.0.alpha.4)

## [v1.0.0.alpha.3](https://github.com/test-kitchen/test-kitchen/tree/v1.0.0.alpha.3) (2013-04-05)
[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v1.0.0.alpha.2...v1.0.0.alpha.3)

**Closed issues:**

- Use baseboxes updated to Chef 10.18.2 [\#21](https://github.com/test-kitchen/test-kitchen/issues/21)
- init command should create Gemfile if it does not exist [\#20](https://github.com/test-kitchen/test-kitchen/issues/20)

## [v1.0.0.alpha.2](https://github.com/test-kitchen/test-kitchen/tree/v1.0.0.alpha.2) (2013-03-29)
[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v1.0.0.alpha.1...v1.0.0.alpha.2)

## [v1.0.0.alpha.1](https://github.com/test-kitchen/test-kitchen/tree/v1.0.0.alpha.1) (2013-03-23)
[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v0.4.0...v1.0.0.alpha.1)

**Merged pull requests:**

- Add Driver\#verify\_dependencies to be invoked once when Driver is loaded. [\#75](https://github.com/test-kitchen/test-kitchen/pull/75) ([fnichol](https://github.com/fnichol))
- switch driver alias \(-d\) to \(-D\) in Init generator [\#74](https://github.com/test-kitchen/test-kitchen/pull/74) ([reset](https://github.com/reset))
- \[Breaking\] Modify ShellOut\#run\_command to take an options Hash. [\#73](https://github.com/test-kitchen/test-kitchen/pull/73) ([fnichol](https://github.com/fnichol))
- Add flag to `kitchen init` to skip Gemfile creation by default. [\#72](https://github.com/test-kitchen/test-kitchen/pull/72) ([fnichol](https://github.com/fnichol))
- Updates to `kitchen init` to be non-interactive \(add `--driver` flag\), add subcommand support, and introduce `kitchen driver discover`. [\#71](https://github.com/test-kitchen/test-kitchen/pull/71) ([fnichol](https://github.com/fnichol))
- \[tailor\] fix for line length and style [\#65](https://github.com/test-kitchen/test-kitchen/pull/65) ([ChrisLundquist](https://github.com/ChrisLundquist))
- make "require\_chef\_omnibus: true" safe [\#64](https://github.com/test-kitchen/test-kitchen/pull/64) ([mattray](https://github.com/mattray))

## [v0.4.0](https://github.com/test-kitchen/test-kitchen/tree/v0.4.0) (2013-03-02)
[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v1.0.0.alpha.0...v0.4.0)

**Closed issues:**

- support "exclude" configuration directive after \#17 [\#29](https://github.com/test-kitchen/test-kitchen/issues/29)

## [v1.0.0.alpha.0](https://github.com/test-kitchen/test-kitchen/tree/v1.0.0.alpha.0) (2013-03-02)
[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v0.1.0.beta4...v1.0.0.alpha.0)

**Closed issues:**

- Gem dependency collision [\#59](https://github.com/test-kitchen/test-kitchen/issues/59)
- chef\_data\_uploader doesn't actually upload cookbooks w/ kitchen-vagrant [\#55](https://github.com/test-kitchen/test-kitchen/issues/55)
- When 'box' is specified without 'box\_url', just use existing Vagrant base box [\#53](https://github.com/test-kitchen/test-kitchen/issues/53)
- make "suites" stanza optional [\#48](https://github.com/test-kitchen/test-kitchen/issues/48)
- move JR \(Jamie Runner\) code into appropriate test-kitchen repositories [\#43](https://github.com/test-kitchen/test-kitchen/issues/43)
- add individual node definitions and global driver configuration to yaml format [\#41](https://github.com/test-kitchen/test-kitchen/issues/41)
- Split classes into separate files \(a.k.a. The Big Split\) [\#39](https://github.com/test-kitchen/test-kitchen/issues/39)
- Migrate the jamie-vagrant gem codebase to kitchen-vagrant [\#38](https://github.com/test-kitchen/test-kitchen/issues/38)
- support `require\_chef\_omnibus` config option value of "latest" [\#32](https://github.com/test-kitchen/test-kitchen/issues/32)
- create kitchen-openstack driver [\#25](https://github.com/test-kitchen/test-kitchen/issues/25)
- rename .jamie.yml to .kitchen.yml [\#18](https://github.com/test-kitchen/test-kitchen/issues/18)
- Merge "jamie" project with test-kitchen [\#17](https://github.com/test-kitchen/test-kitchen/issues/17)

**Merged pull requests:**

- YAML Serialization [\#58](https://github.com/test-kitchen/test-kitchen/pull/58) ([fnichol](https://github.com/fnichol))
- Suites should be able to exclude a platform \#29 [\#57](https://github.com/test-kitchen/test-kitchen/pull/57) ([sandfish8](https://github.com/sandfish8))
- add basic instructions [\#54](https://github.com/test-kitchen/test-kitchen/pull/54) ([bryanwb](https://github.com/bryanwb))

## [v0.1.0.beta4](https://github.com/test-kitchen/test-kitchen/tree/v0.1.0.beta4) (2013-01-24)
[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v0.1.0.beta3...v0.1.0.beta4)

## [v0.1.0.beta3](https://github.com/test-kitchen/test-kitchen/tree/v0.1.0.beta3) (2013-01-14)
[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v0.1.0.beta2...v0.1.0.beta3)

## [v0.1.0.beta2](https://github.com/test-kitchen/test-kitchen/tree/v0.1.0.beta2) (2013-01-13)
[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v0.1.0.beta1...v0.1.0.beta2)

## [v0.1.0.beta1](https://github.com/test-kitchen/test-kitchen/tree/v0.1.0.beta1) (2013-01-12)
[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v0.3.0...v0.1.0.beta1)

## [v0.3.0](https://github.com/test-kitchen/test-kitchen/tree/v0.3.0) (2013-01-09)
[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v0.1.0.alpha21...v0.3.0)

## [v0.1.0.alpha21](https://github.com/test-kitchen/test-kitchen/tree/v0.1.0.alpha21) (2013-01-09)
[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v0.1.0.alpha20...v0.1.0.alpha21)

## [v0.1.0.alpha20](https://github.com/test-kitchen/test-kitchen/tree/v0.1.0.alpha20) (2013-01-04)
[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v0.2.0...v0.1.0.alpha20)

## [v0.2.0](https://github.com/test-kitchen/test-kitchen/tree/v0.2.0) (2013-01-03)
[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v0.1.0.alpha19...v0.2.0)

## [v0.1.0.alpha19](https://github.com/test-kitchen/test-kitchen/tree/v0.1.0.alpha19) (2013-01-03)
[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v0.1.0.alpha18...v0.1.0.alpha19)

## [v0.1.0.alpha18](https://github.com/test-kitchen/test-kitchen/tree/v0.1.0.alpha18) (2012-12-30)
[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v0.1.0.alpha17...v0.1.0.alpha18)

## [v0.1.0.alpha17](https://github.com/test-kitchen/test-kitchen/tree/v0.1.0.alpha17) (2012-12-27)
[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v0.1.0...v0.1.0.alpha17)

## [v0.1.0](https://github.com/test-kitchen/test-kitchen/tree/v0.1.0) (2012-12-27)
[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v0.1.0.alpha16...v0.1.0)

## [v0.1.0.alpha16](https://github.com/test-kitchen/test-kitchen/tree/v0.1.0.alpha16) (2012-12-27)
[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v0.1.0.alpha15...v0.1.0.alpha16)

## [v0.1.0.alpha15](https://github.com/test-kitchen/test-kitchen/tree/v0.1.0.alpha15) (2012-12-24)
[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v0.1.0.alpha14...v0.1.0.alpha15)

## [v0.1.0.alpha14](https://github.com/test-kitchen/test-kitchen/tree/v0.1.0.alpha14) (2012-12-22)
[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v0.1.0.alpha13...v0.1.0.alpha14)

## [v0.1.0.alpha13](https://github.com/test-kitchen/test-kitchen/tree/v0.1.0.alpha13) (2012-12-20)
[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v0.1.0.alpha12...v0.1.0.alpha13)

## [v0.1.0.alpha12](https://github.com/test-kitchen/test-kitchen/tree/v0.1.0.alpha12) (2012-12-20)
[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v0.1.0.alpha11...v0.1.0.alpha12)

## [v0.1.0.alpha11](https://github.com/test-kitchen/test-kitchen/tree/v0.1.0.alpha11) (2012-12-20)
[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v0.1.0.alpha10...v0.1.0.alpha11)

## [v0.1.0.alpha10](https://github.com/test-kitchen/test-kitchen/tree/v0.1.0.alpha10) (2012-12-20)
[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v0.1.0.alpha9...v0.1.0.alpha10)

## [v0.1.0.alpha9](https://github.com/test-kitchen/test-kitchen/tree/v0.1.0.alpha9) (2012-12-18)
[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v0.1.0.alpha8...v0.1.0.alpha9)

## [v0.1.0.alpha8](https://github.com/test-kitchen/test-kitchen/tree/v0.1.0.alpha8) (2012-12-17)
[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v0.1.0.alpha7...v0.1.0.alpha8)

## [v0.1.0.alpha7](https://github.com/test-kitchen/test-kitchen/tree/v0.1.0.alpha7) (2012-12-14)
[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v0.1.0.alpha6...v0.1.0.alpha7)

## [v0.1.0.alpha6](https://github.com/test-kitchen/test-kitchen/tree/v0.1.0.alpha6) (2012-12-13)
[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v0.1.0.alpha5...v0.1.0.alpha6)

## [v0.1.0.alpha5](https://github.com/test-kitchen/test-kitchen/tree/v0.1.0.alpha5) (2012-12-13)
[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v0.1.0.alpha4...v0.1.0.alpha5)

## [v0.1.0.alpha4](https://github.com/test-kitchen/test-kitchen/tree/v0.1.0.alpha4) (2012-12-11)
[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v0.1.0.alpha3...v0.1.0.alpha4)

## [v0.1.0.alpha3](https://github.com/test-kitchen/test-kitchen/tree/v0.1.0.alpha3) (2012-12-10)
[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v0.1.0.alpha2...v0.1.0.alpha3)

## [v0.1.0.alpha2](https://github.com/test-kitchen/test-kitchen/tree/v0.1.0.alpha2) (2012-12-03)
[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v0.7.0...v0.1.0.alpha2)

## [v0.7.0](https://github.com/test-kitchen/test-kitchen/tree/v0.7.0) (2012-12-03)
[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v0.1.0.alpha1...v0.7.0)

## [v0.1.0.alpha1](https://github.com/test-kitchen/test-kitchen/tree/v0.1.0.alpha1) (2012-12-01)
[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v0.7.0.rc.1...v0.1.0.alpha1)

**Merged pull requests:**

- minor formatting and spelling corrections [\#11](https://github.com/test-kitchen/test-kitchen/pull/11) ([mattray](https://github.com/mattray))

## [v0.7.0.rc.1](https://github.com/test-kitchen/test-kitchen/tree/v0.7.0.rc.1) (2012-11-28)
[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v0.7.0.beta.1...v0.7.0.rc.1)

**Merged pull requests:**

- \[KITCHEN-23\] - load metadata.rb to get cookbook name [\#10](https://github.com/test-kitchen/test-kitchen/pull/10) ([jtimberman](https://github.com/jtimberman))

## [v0.7.0.beta.1](https://github.com/test-kitchen/test-kitchen/tree/v0.7.0.beta.1) (2012-11-21)
[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v0.6.0...v0.7.0.beta.1)

## [v0.6.0](https://github.com/test-kitchen/test-kitchen/tree/v0.6.0) (2012-10-02)
[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v0.5.4...v0.6.0)

**Merged pull requests:**

- \[KITCHEN-29\] - implement --platform to limit test [\#8](https://github.com/test-kitchen/test-kitchen/pull/8) ([jtimberman](https://github.com/jtimberman))
- KITCHEN-22 - Include Databags in Vagrant Configuration if present [\#5](https://github.com/test-kitchen/test-kitchen/pull/5) ([brendanhay](https://github.com/brendanhay))
- KITCHEN-35 use minitest-handler from community.opscode.com [\#4](https://github.com/test-kitchen/test-kitchen/pull/4) ([bryanwb](https://github.com/bryanwb))

## [v0.5.4](https://github.com/test-kitchen/test-kitchen/tree/v0.5.4) (2012-08-30)
[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v0.5.2...v0.5.4)

**Merged pull requests:**

- \[KITCHEN-17\] - support ignoring lint rules [\#3](https://github.com/test-kitchen/test-kitchen/pull/3) ([jtimberman](https://github.com/jtimberman))

## [v0.5.2](https://github.com/test-kitchen/test-kitchen/tree/v0.5.2) (2012-08-18)
[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v0.5.0...v0.5.2)

## [v0.5.0](https://github.com/test-kitchen/test-kitchen/tree/v0.5.0) (2012-08-16)
[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/0.5.0...v0.5.0)

## [0.5.0](https://github.com/test-kitchen/test-kitchen/tree/0.5.0) (2012-08-16)


\* *This Change Log was automatically generated by [github_changelog_generator](https://github.com/skywinder/Github-Changelog-Generator)*
