# Test Kitchen Change Log

## [3.9.0](https://github.com/test-kitchen/test-kitchen/compare/v3.8.2...v3.9.0) (2025-09-05)


### Features

* Added custom proxy command support for AWS EC2 Instance Connect EC2 driver support ([#2019](https://github.com/test-kitchen/test-kitchen/issues/2019)) ([0529e66](https://github.com/test-kitchen/test-kitchen/commit/0529e66447e68b495ef710116420154008fa2238))

## [3.8.2](https://github.com/test-kitchen/test-kitchen/compare/v3.8.1...v3.8.2) (2025-09-05)


### Bug Fixes

* updates to fix tests ([#2022](https://github.com/test-kitchen/test-kitchen/issues/2022)) ([7552481](https://github.com/test-kitchen/test-kitchen/commit/7552481a5234fcf49f394ff848ce29a9a916940c))

## [3.8.1](https://github.com/test-kitchen/test-kitchen/compare/v3.8.0...v3.8.1) (2025-07-24)


### Bug Fixes

* Remove expired copyright ([#2017](https://github.com/test-kitchen/test-kitchen/issues/2017)) ([27ad560](https://github.com/test-kitchen/test-kitchen/commit/27ad560079ce2f21d384d207d6161c562ef3eda2))

## [3.8.0](https://github.com/test-kitchen/test-kitchen/compare/v3.7.2...v3.8.0) (2025-07-12)


### Features

* Support for SSH transport for windows platfoms ([#2007](https://github.com/test-kitchen/test-kitchen/issues/2007)) ([1c79066](https://github.com/test-kitchen/test-kitchen/commit/1c790661c7b81c917a4ea1eb0276296ade4b1f39))

## [3.7.2](https://github.com/test-kitchen/test-kitchen/compare/v3.7.1...v3.7.2) (2025-07-03)


### Bug Fixes

* Update the docs + init for modern platforms ([#2009](https://github.com/test-kitchen/test-kitchen/issues/2009)) ([2c8cca1](https://github.com/test-kitchen/test-kitchen/commit/2c8cca1f77d2b589ae0ed7a6e5cc971de7141f5c))

## [3.7.1](https://github.com/test-kitchen/test-kitchen/compare/v3.7.0...v3.7.1) (2024-12-02)


### Bug Fixes

* Prevent Test Kitchen from requiring Chef license acceptance when an alternative distribution (such as cinc) is used with a Policyfile. ([#1984](https://github.com/test-kitchen/test-kitchen/issues/1984)) ([332294e](https://github.com/test-kitchen/test-kitchen/commit/332294efc3ce27309afd49fa944448713b102070))

## [3.7.0](https://github.com/test-kitchen/test-kitchen/compare/v3.6.2...v3.7.0) (2024-08-27)


### Features

* Add chef_target provisioner ([#1976](https://github.com/test-kitchen/test-kitchen/issues/1976)) ([ef11823](https://github.com/test-kitchen/test-kitchen/commit/ef1182324310d1ad0156d2c97d9f3de7ce804146))
* add finally lifecycle hook to always run regardless of failure ([#1917](https://github.com/test-kitchen/test-kitchen/issues/1917)) ([9015ddc](https://github.com/test-kitchen/test-kitchen/commit/9015ddcbe63ee2fd9c46a736a88fe75a40984a4b))
* add KITCHEN_USERNAME to shell verifier ([b109057](https://github.com/test-kitchen/test-kitchen/commit/b109057016b43123559436acc97ef84f99f04376))
* Add publish workflow ([#1944](https://github.com/test-kitchen/test-kitchen/issues/1944)) ([22cae60](https://github.com/test-kitchen/test-kitchen/commit/22cae60b09bedca27ebea77e99ebc7dfa841dbca))


### Bug Fixes

* added the fix for deprecated config error ([#1979](https://github.com/test-kitchen/test-kitchen/issues/1979)) ([f44ef5c](https://github.com/test-kitchen/test-kitchen/commit/f44ef5c0f9859720e2a7b4732bf13591bcf5e2d6))
* always download files even if verifier fails ([#1916](https://github.com/test-kitchen/test-kitchen/issues/1916)) ([75bdd71](https://github.com/test-kitchen/test-kitchen/commit/75bdd71b965d0d39c78664f751a15be9f665391d))
* release please configs ([#1974](https://github.com/test-kitchen/test-kitchen/issues/1974)) ([c6ab966](https://github.com/test-kitchen/test-kitchen/commit/c6ab966a484a04cfbd5cd634da6f2268d9485cca))
* Remove Ruby 3.0 Testing ([#1948](https://github.com/test-kitchen/test-kitchen/issues/1948)) ([458261c](https://github.com/test-kitchen/test-kitchen/commit/458261c1a170e82b3b5d9f1a5fcad0e1542fabeb))
* replace 2&&gt;1 by 2>&1 ([#1932](https://github.com/test-kitchen/test-kitchen/issues/1932)) ([6468bac](https://github.com/test-kitchen/test-kitchen/commit/6468bac8990ee47da730e2abcc362170e387f6c6))
* Update .release-please-manifest.json ([e8dba21](https://github.com/test-kitchen/test-kitchen/commit/e8dba21d6666ffb1300e25cf1ded54bc85572cb3))
* Update .release-please-manifest.json ([#1980](https://github.com/test-kitchen/test-kitchen/issues/1980)) ([8f76939](https://github.com/test-kitchen/test-kitchen/commit/8f769397758370ae9e368b63cd3e0ba974ecd625))
* Update CHANGELOG.md ([e1b7e4d](https://github.com/test-kitchen/test-kitchen/commit/e1b7e4df4004af6e22f150b49774dae1f18ac1aa))
* update getting started link ([9660a4d](https://github.com/test-kitchen/test-kitchen/commit/9660a4dd3cf577e76decec53fca1bc7957a130ef))

## [3.6.0](https://github.com/test-kitchen/test-kitchen/compare/v3.5.1...v3.6.0) (2023-11-27)


### Features

* Add publish workflow ([#1944](https://github.com/test-kitchen/test-kitchen/issues/1944)) ([22cae60](https://github.com/test-kitchen/test-kitchen/commit/22cae60b09bedca27ebea77e99ebc7dfa841dbca))


### Bug Fixes

* Remove Ruby 3.0 Testing ([#1948](https://github.com/test-kitchen/test-kitchen/issues/1948)) ([458261c](https://github.com/test-kitchen/test-kitchen/commit/458261c1a170e82b3b5d9f1a5fcad0e1542fabeb))

## [3.5.0](https://github.com/test-kitchen/test-kitchen/tree/v3.4.1) (2022-12-18)

- Add `finally` lifecycle hook to always run regardless of failure ([@brycekahle](https://github.com/brycekahle))
- Always download files even if verifier fails ([@brycekahle](https://github.com/brycekahle))

## [3.4.0](https://github.com/test-kitchen/test-kitchen/tree/v3.4.0) (2022-10-20)

- Support modern SSH keys on test instances with newer net-ssh/net-scp ([@tas50](https://github.com/tas50))
- Require Ruby 2.7 or later since 2.6 is now EOL ([@tas50](https://github.com/tas50))

## [3.3.2](https://github.com/test-kitchen/test-kitchen/tree/v3.3.2) (2022-08-03)

[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v3.3.1...v3.3.2)

- Allow to use regexp in includes/excludes to filter platforms [#1828](https://github.com/test-kitchen/test-kitchen/pull/1828)([@Annih](https://github.com/Annih))

## [3.3.1](https://github.com/test-kitchen/test-kitchen/tree/v3.3.1) (2022-07-04)

[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v3.3.0...v3.3.1)

- Mask password in debug log [#1902](https://github.com/test-kitchen/test-kitchen/pull/1902)([@vkarve-chef](https://github.com/vkarve-chef))

## [3.3.0](https://github.com/test-kitchen/test-kitchen/tree/v3.3.0) (2022-06-10)

- Support for Ruby 3.1 [#1867](https://github.com/test-kitchen/test-kitchen/pull/1867)([@kasif-adnan](https://github.com/kasif-adnan))
- Gracefully handle winrm errors [#1872](https://github.com/test-kitchen/test-kitchen/pull/1872)([@jasonwbarnett](https://github.com/jasonwbarnett))
- Spec updates [#1876](https://github.com/test-kitchen/test-kitchen/pull/1876)([@damacus](https://github.com/damacus))
- Using chefstyle linting [#1847](https://github.com/test-kitchen/test-kitchen/pull/1847)([@sanjain-progress](https://github.com/sanjain-progress))
- Skip install chef-config  [#1863](https://github.com/test-kitchen/test-kitchen/pull/1863)([@tas50](https://github.com/tas50))
- Fixed failing azure pipelines [#1880](https://github.com/test-kitchen/test-kitchen/pull/1880)([@kasif-adnan](https://github.com/kasif-adnan))
- Fixed the chef provisioner spec deprecations [#1878](https://github.com/test-kitchen/test-kitchen/pull/1878)([@damacus](https://github.com/damacus))
- Fixed the minitest deprecation errors [#1887](https://github.com/test-kitchen/test-kitchen/pull/1887), [#1885](https://github.com/test-kitchen/test-kitchen/pull/1885)([@damacus](https://github.com/damacus))
- Fixed the issue with chef liscense when Policyfiles are used [#1859](https://github.com/test-kitchen/test-kitchen/pull/1859)([@sanjain-progress](https://github.com/sanjain-progress))
- Fixed the unit test failures [#1840](https://github.com/test-kitchen/test-kitchen/pull/1840)([@ashiqueps](https://github.com/ashiqueps))
- Github workflow updates
- Documentation updates

## [3.2.2](https://github.com/test-kitchen/test-kitchen/tree/v3.2.1) (2021-12-01)

- Moved the `kitchen diagnose` warnings to stderr to prevent YAML parsing errors - [@ashiqueps](https://github.com/ashiqueps)

## [3.2.1](https://github.com/test-kitchen/test-kitchen/tree/v3.2.1) (2021-11-29)

- Fix multiple converges on Windows platforms - [#1820](https://github.com/test-kitchen/test-kitchen/pull/1820)([@tecracer-theinen](https://github.com/tecracer-theinen))

## [3.2.0](https://github.com/test-kitchen/test-kitchen/tree/v3.2.0) (2021-11-17)

- Support the new `compliance` directory in the `chef_infra` (`chef_zero`) provisioner - [#1827](https://github.com/test-kitchen/test-kitchen/pull/1827)([@tas50](https://github.com/tas50))

## [3.1.1](https://github.com/test-kitchen/test-kitchen/tree/v3.1.1) (2021-10-26)

- Fix progress reporting in ssh transport - [#1796](https://github.com/test-kitchen/test-kitchen/pull/1796)([@karmix](https://github.com/karmix))

## [3.1.0](https://github.com/test-kitchen/test-kitchen/tree/v3.1.0) (2021-10-02)

- Removed support for EOL Ruby 2.5
- Add support for WinRM certificate authentication (@gholtiii)

## [3.0.0](https://github.com/test-kitchen/test-kitchen/tree/v3.0.0) (2021-07-02)

- The `chef_zero` provisioner has been renamed `chef_infra` to avoid confusion. Note: The existing name will continue to work going forward.
- The default provisioner for Test Kitchen has been changed from chef_solo to chef_infra (chef_zero)
- The `always_update_cookbooks` config for the `chef_infra` and `chef_solo` provisioners is now default so cookbook changes will automatically be picked up without the need to run `chef update` first. Set this value to false to maintain the existing behavior.
- A new `policy_group` config has been added to allow setting the Policy Group to test a node in. This can be set in the provisioner block or within individual suites. Note: This config option requires `chef-cli` 5.2 or later.

## [2.12.0](https://github.com/test-kitchen/test-kitchen/tree/v2.12.0) (2021-06-10)

- Update kitchen console to work with the newer releases of pry - [#1738](https://github.com/test-kitchen/test-kitchen/pull/1738)([@jayaddison-collabora](https://github.com/jayaddison-collabora))
- Upgrade usage of deprecated minitest global assertions in unit tests that capture stderr output - [#1734](https://github.com/test-kitchen/test-kitchen/pull/1734)([@jayaddison-collabora](https://github.com/jayaddison-collabora))
- Add a new slow_resource_report config for Chef Infra Client 17.2 - [#1759](https://github.com/test-kitchen/test-kitchen/pull/1759)([tas50](https://github.com/tas50))
- Squash SSH fails in the lifecycle_hooks if skipable is set to true - [#1579](https://github.com/test-kitchen/test-kitchen/pull/1579)([tarcinil](https://github.com/tarcinil))

## [2.11.2](https://github.com/test-kitchen/test-kitchen/tree/v2.11.1) (2021-03-24)

- Fixed frozen string errors that could occur in the logger - [#1731](https://github.com/test-kitchen/test-kitchen/pull/1731)([tas50](https://github.com/tas50))

## [2.11.1](https://github.com/test-kitchen/test-kitchen/tree/v2.11.1) (2021-03-02)

- Fix an incorrect require in the new `Kitchen::Which` module - [#1726](https://github.com/test-kitchen/test-kitchen/pull/1726)([lamont-granquist](https://github.com/lamont-granquist))

## [2.11.0](https://github.com/test-kitchen/test-kitchen/tree/v2.11.0) (2021-03-01)

- The `policyfile` provisioner can now use the `chef-cli` for policyfile depsolving allowing for the testing of Chef Infra cookbooks with Policyfiles when using a gem installed Test Kitchen. - [#1725](https://github.com/test-kitchen/test-kitchen/pull/1725)([lamont-granquist](https://github.com/lamont-granquist))

## [2.10.0](https://github.com/test-kitchen/test-kitchen/tree/v2.10.0) (2021-01-17)

- Add support for uploading files to the systems within the provisioners similar to the `download` feature - [@tecracer-theinen](https://github.com/tecracer-theinen)
- Allow using includes/excludes filters in the lifecycle hooks - [@jasonwbarnett](https://github.com/jasonwbarnett)
- Resolved `uninitialized constant Kitchen::Loader::YAML::Psych` error - [@dwmarshall](https://github.com/dwmarshall)

## [2.9.0](https://github.com/test-kitchen/test-kitchen/tree/v2.9.0) (2020-12-23)

- Policyfile error messages no longer mention EOL ChefDK
- When using winrm to login to a Windows guest from a Linux host we now use `xfreerdp` to avoid CredSSP error messages. If you're currently using `rdesktop` you'll need to install `xfreerdp`. This solution works out of the box without configuration, making it easier to test Windows guests on Linux hosts. Thanks [@ramereth](https://github.com/ramereth)

## [2.8.0](https://github.com/test-kitchen/test-kitchen/tree/v2.8.0) (2020-12-02)

- Better support Test Kitchen execution on Windows by running commands through a script file. This avoids failures when the command length becomes too long for Windows to handle.

## [2.7.2](https://github.com/test-kitchen/test-kitchen/tree/v2.7.2) (2020-09-29)

[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v2.7.1...v2.7.2)

- Various performance optimizations

## [2.7.1](https://github.com/test-kitchen/test-kitchen/tree/v2.7.1) (2020-09-15)

[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v2.7.0...v2.7.1)

- Mark chef_solo provisioner unsafe for concurrency

## [2.7.0](https://github.com/test-kitchen/test-kitchen/tree/v2.7.0) (2020-09-08)

[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v2.6.0...v2.7.0)

- Allow all plugins to toggle concurrency
- Optimize our requires

## [2.6.0](https://github.com/test-kitchen/test-kitchen/tree/v2.6.0) (2020-08-13)

[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v2.5.4...v2.6.0)

- Remove support for EOL Ruby 2.3
- Relax dependency on license-acceptance to allow for 2.x

## [2.5.4](https://github.com/test-kitchen/test-kitchen/tree/v2.5.4) (2020-07-29)

[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v2.5.3...v2.5.4)

- Revert root_path changes that caused failures installing Chef Infra Client on Windows

## [2.5.3](https://github.com/test-kitchen/test-kitchen/tree/v2.5.3) (2020-07-10)

[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v2.5.2...v2.5.3)

- Respect root_path when product_name is specified [#1662](https://github.com/test-kitchen/test-kitchen/pull/1662)([clintoncwolfe](https://github.com/clintoncwolfe))

## [2.5.2](https://github.com/test-kitchen/test-kitchen/tree/v2.5.2) (2020-06-11)

[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v2.5.1...v2.5.2)

- Update thor requirement from ~> 0.19 to >= 0.19, < 2.0 [#1608](https://github.com/test-kitchen/test-kitchen/pull/1608)([dependabot-preview](https://github.com/dependabot-preview))

## [2.5.1](https://github.com/test-kitchen/test-kitchen/tree/v2.5.1) (2020-05-16)

[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v2.5.0...v2.5.1)

- Pin the Aruba dev dep to prevent test failures [#1646](https://github.com/test-kitchen/test-kitchen/pull/1646)([Xorima](https://github.com/Xorima))
- Update install scripts messaging from Chef -> Chef Infra Client [#1644](https://github.com/test-kitchen/test-kitchen/pull/1644)([tas50](https://github.com/tas50))

## [2.5.0](https://github.com/test-kitchen/test-kitchen/tree/v2.5.0) (2020-05-06)

[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v2.4.0...v2.5.0)

- Allow copying Ohai plugins from the /ohai cookbook directory into the instance [#1634](https://github.com/test-kitchen/test-kitchen/pull/1634)([SAPDanJoe](https://github.com/SAPDanJoe))
- Fix failures using the PowerShell provisioner [#1639](https://github.com/test-kitchen/test-kitchen/pull/1639)([alanghartJC](https://github.com/alanghartJC))
- Update the net-ssh and net-scp deps to allow the latest versions to add support for sha2-{256,512}<-etm@openssh.com> MAC algorithms and to allow spaces / comment lines in the known_hosts file.

## [2.4.0](https://github.com/test-kitchen/test-kitchen/tree/v2.4.0) (2020-03-04)

[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v2.3.4...v2.4.0)

- The `CHEF_LICENSE` env var is now automatically exported from the workstation to the instance running in Test Kitchen [#1629](https://github.com/test-kitchen/test-kitchen/pull/1629)([Xorima](https://github.com/Xorima))
- All local Workstation env vars are now passed to the instance running in Test Kitchen with the `TKENV_` prefix. [#1623](https://github.com/test-kitchen/test-kitchen/pull/1623)([Xorima](https://github.com/Xorima))
- Add kitchen*.yml to the chefignore in kitchen init [#1627](https://github.com/test-kitchen/test-kitchen/pull/1627)([tas50](https://github.com/tas50))
- Use require_relative instead of require [#1613](https://github.com/test-kitchen/test-kitchen/pull/1613)([tas50](https://github.com/tas50))
- Add download capability to verifier base with a new `downloads` config option in verify [#1605](https://github.com/test-kitchen/test-kitchen/pull/1605) ([smurawski](https://github.com/smurawski))

## [2.3.4](https://github.com/test-kitchen/test-kitchen/tree/v2.3.4) (2019-10-31)

[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v2.3.3...v2.3.4)

- Updated several log events from "Kitchen" to "Test Kitchen" to be consistent [#1598](https://github.com/test-kitchen/test-kitchen/pull/1598)([tas50](https://github.com/tas50))
- Fixed a typo in a policyfile error message [#1599](https://github.com/test-kitchen/test-kitchen/pull/1599)([gep13](https://github.com/gep13))
- Updated the policyfile provisioner to search for multiple varients of the chef CLI [\#1601](https://github.com/test-kitchen/test-kitchen/pull/1601)([afiune](https://github.com/afiune))

## [2.3.3](https://github.com/test-kitchen/test-kitchen/tree/v2.3.3) (2019-09-18)

[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v2.3.2...v2.3.3)

- Make sure Policyfile.lock.json exists before calling chef update [\#1590](https://github.com/test-kitchen/test-kitchen/pull/1590)([teknofire](https://github.com/teknofire))

## [2.3.2](https://github.com/test-kitchen/test-kitchen/tree/v2.3.2) (2019-08-26)

[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v2.3.1...v2.3.2)

- allow mixlib-shellout 3.x [\#1583](https://github.com/test-kitchen/test-kitchen/pull/1583)([lamont-granquist](https://github.com/lamont-granquist))

## [2.3.1](https://github.com/test-kitchen/test-kitchen/tree/v2.3.1) (2019-08-26)

[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v2.3.0...v2.3.1)

- Add keepalive_maxcount config to ssh connections [\#1582](https://github.com/test-kitchen/test-kitchen/pull/1582) ([dwoz](https://github.com/dwoz))
- Add lifecycle to instance diagnose [\#1577](https://github.com/test-kitchen/test-kitchen/pull/1577) ([tarcinil](https://github.com/tarcinil))
- Fix Unknown lifecycle hook target {} error [\#1578](https://github.com/test-kitchen/test-kitchen/pull/1578) ([tarcinil](https://github.com/tarcinil))

## [2.3.0](https://github.com/test-kitchen/test-kitchen/tree/v2.3.0) (2019-08-26)

[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v2.2.5...v2.3.0)

- Add berkshelf_path config option [\#1562](https://github.com/test-kitchen/test-kitchen/pull/1562) ([lamont-granquist](https://github.com/lamont-granquist))
- Silence ruby-2.6.0/psych-3.0.0 warnings [\#1558](https://github.com/test-kitchen/test-kitchen/pull/1558) ([lamont-granquist](https://github.com/lamont-granquist))
- Accept Chef Workstation license when users have Policyfile [\#1573](https://github.com/test-kitchen/test-kitchen/pull/1573) ([tball](https://github.com/tball))
- Chefstyle updates [\#1572](https://github.com/test-kitchen/test-kitchen/pull/1572) ([smurawski](https://github.com/smurawski))
- Testing has been migrated from AppVeyor to Azure Devops Pipelines with expanded platform testing [\#1571](https://github.com/test-kitchen/test-kitchen/pull/1571) ([smurawski](https://github.com/smurawski))

## [2.2.5](https://github.com/test-kitchen/test-kitchen/tree/v2.2.5) (2019-05-15)

[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v2.2.4...v2.2.5)

**Merged pull requests:**

- Update some of the Chef error / info messages [\#1555](https://github.com/test-kitchen/test-kitchen/pull/1555) ([tas50](https://github.com/tas50))
- Net::SSH changed the response from their select mock [\#1554](https://github.com/test-kitchen/test-kitchen/pull/1554) ([tyler-ball](https://github.com/tyler-ball))
- Let license errors raise without trying to cleanup sandbox [\#1552](https://github.com/test-kitchen/test-kitchen/pull/1552) ([tyler-ball](https://github.com/tyler-ball))

## [2.2.4](https://github.com/test-kitchen/test-kitchen/tree/v2.2.4) (2019-05-13)

[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v2.2.3...v2.2.4)

**Merged pull requests:**

- Chef: Must read license acceptance before creating config.rb [\#1551](https://github.com/test-kitchen/test-kitchen/pull/1551) ([tyler-ball](https://github.com/tyler-ball))

## [2.2.3](https://github.com/test-kitchen/test-kitchen/tree/v2.2.3) (2019-05-08)

[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v2.2.2...v2.2.3)

**Merged pull requests:**

- Update license-acceptance API usage to new method name [\#1550](https://github.com/test-kitchen/test-kitchen/pull/1550) ([tyler-ball](https://github.com/tyler-ball))

## [2.2.2](https://github.com/test-kitchen/test-kitchen/tree/v2.2.2) (2019-05-02)

[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v2.2.1...v2.2.2)

**Merged pull requests:**

- Chef license checking should work with legacy require_chef_omnibus config [\#1546](https://github.com/test-kitchen/test-kitchen/pull/1546) ([tas50](https://github.com/tas50))
- Moving Chef license acceptance to Chef config instead of command line argument [\#1547](https://github.com/test-kitchen/test-kitchen/pull/1547) ([tyler-ball](https://github.com/tyler-ball))

## [2.2.1](https://github.com/test-kitchen/test-kitchen/tree/v2.2.1) (2019-05-01)

[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v2.2.0...v2.2.1)

**Merged pull requests:**

- If no product is passed check license of Chef [\#1545](https://github.com/test-kitchen/test-kitchen/pull/1545) ([tas50](https://github.com/tas50))

## [2.2.0](https://github.com/test-kitchen/test-kitchen/tree/v2.2.0) (2019-04-26)

[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v2.1.0...v2.2.0)

**Merged pull requests:**

- Chef provisioners should prompt for license acceptance [\#1544](https://github.com/test-kitchen/test-kitchen/pull/1544) ([tyler-ball](https://github.com/tyler-ball))

## [2.1.0](https://github.com/test-kitchen/test-kitchen/tree/v2.1.0) (2019-04-18)

[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v2.0.1...v2.1.0)

**Merged pull requests:**

- Require gems needed for ed25519 ssh key support [\#1542](https://github.com/test-kitchen/test-kitchen/pull/1542) ([tas50](https://github.com/tas50))

## [2.0.1](https://github.com/test-kitchen/test-kitchen/tree/v2.0.1) (2019-03-26)

[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v2.0.0...v2.0.1)

**Merged pull requests:**

- Switch to new gem install parameters to support Ruby 2.6 and Chef 15 [\#1536](https://github.com/test-kitchen/test-kitchen/pull/1536) ([WheresAlice](https://github.com/WheresAlice))
- Honor retries when ssh proxy returns an error [\#1534](https://github.com/test-kitchen/test-kitchen/pull/1534) ([vmiszczak-teads](https://github.com/vmiszczak-teads))

## [v2.0.0](https://github.com/test-kitchen/test-kitchen/tree/v2.0.0) (2019-03-20)

[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v1.24.0...v2.0.0)

**Merged pull requests:**

- Release Test Kitchen 2.0 [\#1532](https://github.com/test-kitchen/test-kitchen/pull/1532) ([tas50](https://github.com/tas50))
- Allow net-scp 2.0 [\#1531](https://github.com/test-kitchen/test-kitchen/pull/1531) ([tas50](https://github.com/tas50))
- Rename .kitchen.yml -\> kitchen.yml [\#1529](https://github.com/test-kitchen/test-kitchen/pull/1529) ([nqb](https://github.com/nqb))
- Pin net-ssh-gateway and net-ssh to prevent the next majors [\#1528](https://github.com/test-kitchen/test-kitchen/pull/1528) ([tas50](https://github.com/tas50))
- Test on Ruby 2.5 in Appveyor [\#1527](https://github.com/test-kitchen/test-kitchen/pull/1527) ([tas50](https://github.com/tas50))
- Improve chef logging / error messages [\#1526](https://github.com/test-kitchen/test-kitchen/pull/1526) ([tas50](https://github.com/tas50))
- Simplify the kitchen vagrant example config in the docs [\#1525](https://github.com/test-kitchen/test-kitchen/pull/1525) ([tas50](https://github.com/tas50))
- Mildy modernize the kitchen driver init templates [\#1524](https://github.com/test-kitchen/test-kitchen/pull/1524) ([tas50](https://github.com/tas50))
- Update kitchen init to use Ubuntu 18.04 [\#1523](https://github.com/test-kitchen/test-kitchen/pull/1523) ([tas50](https://github.com/tas50))
- Remove support for Chef 10 / 11 from chef-zero / chef-solo [\#1522](https://github.com/test-kitchen/test-kitchen/pull/1522) ([tas50](https://github.com/tas50))
- Remove support for Chef Librarian [\#1521](https://github.com/test-kitchen/test-kitchen/pull/1521) ([tas50](https://github.com/tas50))
- Chefstyle fixes for the latest chefstyle [\#1520](https://github.com/test-kitchen/test-kitchen/pull/1520) ([tas50](https://github.com/tas50))
- Getting started doc: fix minor typos [\#1517](https://github.com/test-kitchen/test-kitchen/pull/1517) ([nqb](https://github.com/nqb))
- support net-ssh \>= 5.0 [\#1476](https://github.com/test-kitchen/test-kitchen/pull/1476) ([Val](https://github.com/Val))
- using preferred config name for list output [\#1431](https://github.com/test-kitchen/test-kitchen/pull/1431) ([tarcinil](https://github.com/tarcinil))

## [v1.24.0](https://github.com/test-kitchen/test-kitchen/tree/v1.24.0) (2018-12-26)

[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v1.23.5...v1.24.0)

**Merged pull requests:**

- Fixing two issues with the ChefDK build [\#1507](https://github.com/test-kitchen/test-kitchen/pull/1507) ([tyler-ball](https://github.com/tyler-ball))
- Remove the Gemfile pin on train .22 [\#1505](https://github.com/test-kitchen/test-kitchen/pull/1505) ([tas50](https://github.com/tas50))
- include list of known plugins when one cannot be loaded [\#1368](https://github.com/test-kitchen/test-kitchen/pull/1368) ([robbkidd](https://github.com/robbkidd))

## [v1.23.5](https://github.com/test-kitchen/test-kitchen/tree/v1.23.5) (2018-12-11)

[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v1.23.4...v1.23.5)

**Merged pull requests:**

- Add back the gemspec and gemfile for appbundler [\#1504](https://github.com/test-kitchen/test-kitchen/pull/1504) ([tas50](https://github.com/tas50))

## [v1.23.4](https://github.com/test-kitchen/test-kitchen/tree/v1.23.4) (2018-12-10)

[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v1.23.3...v1.23.4)

**Merged pull requests:**

- Add ruby 2.6 travis testing [\#1503](https://github.com/test-kitchen/test-kitchen/pull/1503) ([tas50](https://github.com/tas50))
- Only ship the necessary files for Test Kitchen to run in the gem [\#1502](https://github.com/test-kitchen/test-kitchen/pull/1502) ([tas50](https://github.com/tas50))
- Misc updates to the docs [\#1501](https://github.com/test-kitchen/test-kitchen/pull/1501) ([tas50](https://github.com/tas50))

## [v1.23.3](https://github.com/test-kitchen/test-kitchen/tree/v1.23.3) (2018-11-30)

[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v1.23.2...v1.23.3)

**Fixed bugs:**

- Chef 13 Cookbook Root Aliases Not Found [\#1230](https://github.com/test-kitchen/test-kitchen/issues/1230)

**Closed issues:**

- WinRM transport leaves open connections [\#1495](https://github.com/test-kitchen/test-kitchen/issues/1495)
- Kitchen Login Fails on Windows [\#1485](https://github.com/test-kitchen/test-kitchen/issues/1485)
- Gems in metadata.rb not installing [\#1484](https://github.com/test-kitchen/test-kitchen/issues/1484)
- Chef::Config.from\_file in local workstation configuration breaks Kitchen [\#1483](https://github.com/test-kitchen/test-kitchen/issues/1483)
- winrm 2.3.0 potential issues [\#1481](https://github.com/test-kitchen/test-kitchen/issues/1481)
- Suites.Verifier.Inspec\_tests [\#1478](https://github.com/test-kitchen/test-kitchen/issues/1478)
- test-kitchen does not support net-ssh \> 5.0 [\#1474](https://github.com/test-kitchen/test-kitchen/issues/1474)
- Add Rake Tasks for doc gen and deployment [\#1467](https://github.com/test-kitchen/test-kitchen/issues/1467)
- TestKitchen refuses to destroy VMs that failed to finish the create step [\#1465](https://github.com/test-kitchen/test-kitchen/issues/1465)
- Tests involving multiple docker containers  [\#1463](https://github.com/test-kitchen/test-kitchen/issues/1463)
- Passing alternative configs to Kitchen::ThorTasks [\#1462](https://github.com/test-kitchen/test-kitchen/issues/1462)
- kitchen login, password prompt [\#1461](https://github.com/test-kitchen/test-kitchen/issues/1461)
- Vagrant ships with WinRM support builtin [\#1460](https://github.com/test-kitchen/test-kitchen/issues/1460)
- Docs - migrate to Hugo [\#1458](https://github.com/test-kitchen/test-kitchen/issues/1458)
- Docs for fixture cookbooks [\#1457](https://github.com/test-kitchen/test-kitchen/issues/1457)
- Docs for Setting Environment for Chef provisioner [\#1455](https://github.com/test-kitchen/test-kitchen/issues/1455)
- Docs for Reboot [\#1454](https://github.com/test-kitchen/test-kitchen/issues/1454)
- Docs for Silencing Chef Deprecation Warnings [\#1452](https://github.com/test-kitchen/test-kitchen/issues/1452)
- Docs for Shell Provisioner [\#1451](https://github.com/test-kitchen/test-kitchen/issues/1451)
- Feature request: run specific tests via kitchen verify / kitchen test [\#1449](https://github.com/test-kitchen/test-kitchen/issues/1449)
- CentOS Guest Chef Install Failures - Checksum Miss Match [\#1447](https://github.com/test-kitchen/test-kitchen/issues/1447)
- Running specific modules of puppet and testing for it [\#1445](https://github.com/test-kitchen/test-kitchen/issues/1445)
- Double logging when Chef is the provisioner [\#1444](https://github.com/test-kitchen/test-kitchen/issues/1444)
- winrm-fs can't transfer files with special characters like `+` [\#1391](https://github.com/test-kitchen/test-kitchen/issues/1391)
- Configurable updated resource limits for idempotency checks [\#1260](https://github.com/test-kitchen/test-kitchen/issues/1260)
- Add documentation for elevated transport [\#1054](https://github.com/test-kitchen/test-kitchen/issues/1054)
- Option to set delay between converge and verify on test [\#598](https://github.com/test-kitchen/test-kitchen/issues/598)

**Merged pull requests:**

- Fixing failing travis test from PR merge [\#1499](https://github.com/test-kitchen/test-kitchen/pull/1499) ([tyler-ball](https://github.com/tyler-ball))
- LT Tyler Ball [\#1497](https://github.com/test-kitchen/test-kitchen/pull/1497) ([robbkidd](https://github.com/robbkidd))
- Close underlying winrm connections gracefully [\#1496](https://github.com/test-kitchen/test-kitchen/pull/1496) ([dwoz](https://github.com/dwoz))
- Fixing code block formatting [\#1494](https://github.com/test-kitchen/test-kitchen/pull/1494) ([cheeseplus](https://github.com/cheeseplus))
- Add more WinRM timeout config options [\#1493](https://github.com/test-kitchen/test-kitchen/pull/1493) ([dwoz](https://github.com/dwoz))
- Adding rake task for doc deployment [\#1492](https://github.com/test-kitchen/test-kitchen/pull/1492) ([cheeseplus](https://github.com/cheeseplus))
- Rename page and minor formatting fixes [\#1491](https://github.com/test-kitchen/test-kitchen/pull/1491) ([cheeseplus](https://github.com/cheeseplus))
- Fixing the doc for chef provisioners [\#1490](https://github.com/test-kitchen/test-kitchen/pull/1490) ([cheeseplus](https://github.com/cheeseplus))
- Add docs for fixtures and lifecycle hooks [\#1489](https://github.com/test-kitchen/test-kitchen/pull/1489) ([cheeseplus](https://github.com/cheeseplus))
- Fix \#1454 - add reboot doc [\#1488](https://github.com/test-kitchen/test-kitchen/pull/1488) ([cheeseplus](https://github.com/cheeseplus))
- Updating for chefstyle 0.11 [\#1487](https://github.com/test-kitchen/test-kitchen/pull/1487) ([cheeseplus](https://github.com/cheeseplus))
- Add Docs for Shell Provisioner [\#1486](https://github.com/test-kitchen/test-kitchen/pull/1486) ([pwelch](https://github.com/pwelch))
- Add retry support for WinRM [\#1480](https://github.com/test-kitchen/test-kitchen/pull/1480) ([bdwyertech](https://github.com/bdwyertech))
- DOCS - improve documentation language [\#1479](https://github.com/test-kitchen/test-kitchen/pull/1479) ([JohnVonNeumann](https://github.com/JohnVonNeumann))
- Acknowledge the existence of kitchen-azurerm and add an example configuration [\#1466](https://github.com/test-kitchen/test-kitchen/pull/1466) ([stuartpreston](https://github.com/stuartpreston))
- Middleman -\> Hugo conversion [\#1459](https://github.com/test-kitchen/test-kitchen/pull/1459) ([cheeseplus](https://github.com/cheeseplus))
- Docs merge [\#1450](https://github.com/test-kitchen/test-kitchen/pull/1450) ([cheeseplus](https://github.com/cheeseplus))
- Support cookbook root aliases and VERSION file [\#1446](https://github.com/test-kitchen/test-kitchen/pull/1446) ([cheeseplus](https://github.com/cheeseplus))

## [v1.23.2](https://github.com/test-kitchen/test-kitchen/tree/v1.23.2) (2018-08-06)

[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v1.22.1...v1.23.2)

**Closed issues:**

- .kitchen.yml chef version is not honoerd for windows provisioner [\#1414](https://github.com/test-kitchen/test-kitchen/issues/1414)

**Merged pull requests:**

- Release 1.23.2 [\#1443](https://github.com/test-kitchen/test-kitchen/pull/1443) ([cheeseplus](https://github.com/cheeseplus))
- Release 1.23.1 [\#1442](https://github.com/test-kitchen/test-kitchen/pull/1442) ([cheeseplus](https://github.com/cheeseplus))
- Catch 'Operation already in progress' as seen on Ubuntu on WSL [\#1435](https://github.com/test-kitchen/test-kitchen/pull/1435) ([bdwyertech](https://github.com/bdwyertech))
- Fix \#1104 add supplemental kitchen commands [\#1105](https://github.com/test-kitchen/test-kitchen/pull/1105) ([4-20ma](https://github.com/4-20ma))

## [v1.22.1](https://github.com/test-kitchen/test-kitchen/tree/v1.22.1) (2018-08-03)

[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v1.23.0...v1.22.1)

**Closed issues:**

- Add ability to halt/start systems w/o destroy [\#1441](https://github.com/test-kitchen/test-kitchen/issues/1441)
- Documentation for Shell Provisioner [\#1440](https://github.com/test-kitchen/test-kitchen/issues/1440)
- syntax error kitchen-ssh-1.0.1/lib/kitchen/driver/ssh.rb line 13 [\#1438](https://github.com/test-kitchen/test-kitchen/issues/1438)
- Race condition: conflicting chdir during another chdir block [\#1416](https://github.com/test-kitchen/test-kitchen/issues/1416)

**Merged pull requests:**

- \[SHACK-295\] ChefDK 2.x uses an old version of net-ssh [\#1439](https://github.com/test-kitchen/test-kitchen/pull/1439) ([tyler-ball](https://github.com/tyler-ball))
- Synchronize calls to chdir to be thread safe [\#1430](https://github.com/test-kitchen/test-kitchen/pull/1430) ([s-bernard](https://github.com/s-bernard))

## [v1.23.0](https://github.com/test-kitchen/test-kitchen/tree/v1.23.0) (2018-07-31)

[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v1.22.0...v1.23.0)

**Closed issues:**

- Question: Skip the initial "destroy" phase in "kitchen test"? [\#1436](https://github.com/test-kitchen/test-kitchen/issues/1436)
- Operation already in progress - connect\(2\) [\#1434](https://github.com/test-kitchen/test-kitchen/issues/1434)
- Internal error when running kitchen EC2 [\#1433](https://github.com/test-kitchen/test-kitchen/issues/1433)
- Display download progress of VirtualBox images [\#1417](https://github.com/test-kitchen/test-kitchen/issues/1417)
- Error when converging "both URI are relative " [\#1407](https://github.com/test-kitchen/test-kitchen/issues/1407)
- Add lifecycle hooks to various phases \(including provisioners\) [\#329](https://github.com/test-kitchen/test-kitchen/issues/329)
- Support sync + converge [\#289](https://github.com/test-kitchen/test-kitchen/issues/289)

**Merged pull requests:**

- Release v1.23.0 [\#1437](https://github.com/test-kitchen/test-kitchen/pull/1437) ([cheeseplus](https://github.com/cheeseplus))
- Release 1.22.0 [\#1429](https://github.com/test-kitchen/test-kitchen/pull/1429) ([tas50](https://github.com/tas50))
- Lifecycle hooks [\#1428](https://github.com/test-kitchen/test-kitchen/pull/1428) ([coderanger](https://github.com/coderanger))
- Minor technical cleanup and unify behavior for files and directories. [\#1401](https://github.com/test-kitchen/test-kitchen/pull/1401) ([coderanger](https://github.com/coderanger))

## [v1.22.0](https://github.com/test-kitchen/test-kitchen/tree/v1.22.0) (2018-06-28)

[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v1.21.2...v1.22.0)

**Fixed bugs:**

- Shell provisioner fails on Windows host to Linux guest [\#931](https://github.com/test-kitchen/test-kitchen/issues/931)

**Closed issues:**

- kitchen vagrant won't work with a vagrant plugin [\#1422](https://github.com/test-kitchen/test-kitchen/issues/1422)
- Runtime arguments [\#1420](https://github.com/test-kitchen/test-kitchen/issues/1420)
- kitchen converge fails on Windows with Failed to complete \#converge action: \[invalid byte sequence in UTF-8\] on default-ubuntu-1604 [\#1415](https://github.com/test-kitchen/test-kitchen/issues/1415)
- Shell Provisoner Fails on Windows due to execute bit [\#1413](https://github.com/test-kitchen/test-kitchen/issues/1413)
- test-kitchen is incompatible with latest inspec [\#1409](https://github.com/test-kitchen/test-kitchen/issues/1409)

**Merged pull requests:**

- Minor testing updates [\#1426](https://github.com/test-kitchen/test-kitchen/pull/1426) ([tas50](https://github.com/tas50))
- Stop calling the Chef packages omnibus packages [\#1425](https://github.com/test-kitchen/test-kitchen/pull/1425) ([tas50](https://github.com/tas50))
- Test on the latest ruby releases [\#1424](https://github.com/test-kitchen/test-kitchen/pull/1424) ([tas50](https://github.com/tas50))
- Add the ssh\_gateway\_port config in ssh transport [\#1421](https://github.com/test-kitchen/test-kitchen/pull/1421) ([sjeandeaux](https://github.com/sjeandeaux))
- Shell Provisioner: make script executable [\#1381](https://github.com/test-kitchen/test-kitchen/pull/1381) ([thewyzard44](https://github.com/thewyzard44))

## [v1.21.2](https://github.com/test-kitchen/test-kitchen/tree/v1.21.2) (2018-05-07)

[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v1.21.1...v1.21.2)

**Fixed bugs:**

- 1.21.0 cannot install chef with new provisioner options [\#1402](https://github.com/test-kitchen/test-kitchen/issues/1402)

**Closed issues:**

- Net::SCP::Error [\#1408](https://github.com/test-kitchen/test-kitchen/issues/1408)
- Chef installer permissions issue when using test-kitchen vagrant/virtualbox 16.04 [\#1406](https://github.com/test-kitchen/test-kitchen/issues/1406)

**Merged pull requests:**

- Release 1.21.2 [\#1412](https://github.com/test-kitchen/test-kitchen/pull/1412) ([cheeseplus](https://github.com/cheeseplus))
- Removing thor upper bound in step with berks [\#1410](https://github.com/test-kitchen/test-kitchen/pull/1410) ([cheeseplus](https://github.com/cheeseplus))

## [v1.21.1](https://github.com/test-kitchen/test-kitchen/tree/v1.21.1) (2018-04-18)

[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v1.21.0...v1.21.1)

**Closed issues:**

- All files in gem has execute bit set [\#1388](https://github.com/test-kitchen/test-kitchen/issues/1388)
- Kitchen fails on multiple reboots of node during run.  [\#1376](https://github.com/test-kitchen/test-kitchen/issues/1376)
- Host machine proxy environment variables overriding Chef client.rb proxy configs [\#1366](https://github.com/test-kitchen/test-kitchen/issues/1366)
- Double logging when ChefDK is the provisioner [\#1365](https://github.com/test-kitchen/test-kitchen/issues/1365)
- Update Appveyor to support Cucumber [\#798](https://github.com/test-kitchen/test-kitchen/issues/798)
- Ability to specify an array of data bag locations [\#482](https://github.com/test-kitchen/test-kitchen/issues/482)

**Merged pull requests:**

- Release 1.21.1 hotfix [\#1404](https://github.com/test-kitchen/test-kitchen/pull/1404) ([cheeseplus](https://github.com/cheeseplus))
- Revert "honor root\_path for location of chef installer script" [\#1403](https://github.com/test-kitchen/test-kitchen/pull/1403) ([cheeseplus](https://github.com/cheeseplus))

## [v1.21.0](https://github.com/test-kitchen/test-kitchen/tree/v1.21.0) (2018-04-16)

[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v1.20.0...v1.21.0)

**Fixed bugs:**

- when adding an audit-mode recipe to a test-suite, the kitchen instance never converges [\#794](https://github.com/test-kitchen/test-kitchen/issues/794)

**Closed issues:**

- Website is down [\#1394](https://github.com/test-kitchen/test-kitchen/issues/1394)
- Attribute inclusion has an issue [\#1393](https://github.com/test-kitchen/test-kitchen/issues/1393)
- missing command : kitchen driver create \[name\] [\#1386](https://github.com/test-kitchen/test-kitchen/issues/1386)
- VBOX fails if generated instance name exceeds 64 characters [\#1383](https://github.com/test-kitchen/test-kitchen/issues/1383)
- kitchen init provides a kitchen-dokken friendly kitchen configuration [\#1374](https://github.com/test-kitchen/test-kitchen/issues/1374)
- ERROR and exit with message when both kitchen.yml and .kitchen.yml are present. [\#1372](https://github.com/test-kitchen/test-kitchen/issues/1372)
- Support IPv6 addresses for WinRM [\#1370](https://github.com/test-kitchen/test-kitchen/issues/1370)
- kitchen cannot find any OS image [\#1356](https://github.com/test-kitchen/test-kitchen/issues/1356)
- Kitchen attempts SSH for Windows box [\#1355](https://github.com/test-kitchen/test-kitchen/issues/1355)
- Query - Should passing the debug flag also set the debug of the chef-run? [\#1354](https://github.com/test-kitchen/test-kitchen/issues/1354)
- Unable to use aliases in kitchen.yml [\#1353](https://github.com/test-kitchen/test-kitchen/issues/1353)
- Parsing kitchen.yml in linux seems to fail [\#1352](https://github.com/test-kitchen/test-kitchen/issues/1352)
- Test Kitchen fails to converge on Windows 2008r2 [\#1351](https://github.com/test-kitchen/test-kitchen/issues/1351)
- .kitchen.yml suite-\>attributes are not accessible from chef templates [\#1350](https://github.com/test-kitchen/test-kitchen/issues/1350)
- Kitchen converge fails on Windows - No such file or directory @ rb\_sysope [\#1349](https://github.com/test-kitchen/test-kitchen/issues/1349)
- Class: Kitchen::Transport::SshFailed on kitchen converge every few runs  [\#1321](https://github.com/test-kitchen/test-kitchen/issues/1321)
- Failed to complete \#converge action: \[key{hostname} not found\] on default-windows-2012r2 [\#1246](https://github.com/test-kitchen/test-kitchen/issues/1246)
- test\_base\_path is weird [\#1077](https://github.com/test-kitchen/test-kitchen/issues/1077)
- Check for .kitchen.yml before creating .kitchen [\#1026](https://github.com/test-kitchen/test-kitchen/issues/1026)
- Multi Node / Cluster Support [\#873](https://github.com/test-kitchen/test-kitchen/issues/873)
- Ignore/blacklist files from transfer [\#852](https://github.com/test-kitchen/test-kitchen/issues/852)
- Windows guests ignore chef\_omnibus\_url, require override of chef\_metadata\_url [\#820](https://github.com/test-kitchen/test-kitchen/issues/820)
- Kitchen converge fails if symlink is pointing at a non-existent file. [\#723](https://github.com/test-kitchen/test-kitchen/issues/723)
- Support Special Characters in SSH Passwords [\#619](https://github.com/test-kitchen/test-kitchen/issues/619)
- kitchen init always installs kitchen-vagrant [\#584](https://github.com/test-kitchen/test-kitchen/issues/584)
- Provide ERB-variables in .kitchen.yml to get state of instances [\#525](https://github.com/test-kitchen/test-kitchen/issues/525)

**Merged pull requests:**

- Release 1.21.0 [\#1400](https://github.com/test-kitchen/test-kitchen/pull/1400) ([cheeseplus](https://github.com/cheeseplus))
- Support `\*\_YML` for env vars too, for better UX [\#1398](https://github.com/test-kitchen/test-kitchen/pull/1398) ([coderanger](https://github.com/coderanger))
- allow winrm-fs 1.2.0 [\#1396](https://github.com/test-kitchen/test-kitchen/pull/1396) ([gtmanfred](https://github.com/gtmanfred))
- added KITCHEN\_YML [\#1392](https://github.com/test-kitchen/test-kitchen/pull/1392) ([jjasghar](https://github.com/jjasghar))
- Rubocop appeasement [\#1379](https://github.com/test-kitchen/test-kitchen/pull/1379) ([robbkidd](https://github.com/robbkidd))
- don't add drivers to a project's Gemfile during init [\#1378](https://github.com/test-kitchen/test-kitchen/pull/1378) ([robbkidd](https://github.com/robbkidd))
- halt if visible & hidden default configs are both present [\#1377](https://github.com/test-kitchen/test-kitchen/pull/1377) ([robbkidd](https://github.com/robbkidd))
- Update and fix appveyor [\#1373](https://github.com/test-kitchen/test-kitchen/pull/1373) ([cheeseplus](https://github.com/cheeseplus))
- Support IPv6 addresses for WinRM [\#1371](https://github.com/test-kitchen/test-kitchen/pull/1371) ([jzinn](https://github.com/jzinn))
- honor root\_path for location of chef installer script [\#1369](https://github.com/test-kitchen/test-kitchen/pull/1369) ([robbkidd](https://github.com/robbkidd))
- Prefer kitchen.yml to .kitchen.yml [\#1363](https://github.com/test-kitchen/test-kitchen/pull/1363) ([thommay](https://github.com/thommay))
- Support yaml alias [\#1359](https://github.com/test-kitchen/test-kitchen/pull/1359) ([limitusus](https://github.com/limitusus))
- Adding Ruby 2.5, updating other versions [\#1348](https://github.com/test-kitchen/test-kitchen/pull/1348) ([cheeseplus](https://github.com/cheeseplus))
- Update CentOS 7 / Ubuntu to the latest versions [\#1289](https://github.com/test-kitchen/test-kitchen/pull/1289) ([tas50](https://github.com/tas50))

## [v1.20.0](https://github.com/test-kitchen/test-kitchen/tree/v1.20.0) (2018-01-19)

[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v1.19.2...v1.20.0)

**Fixed bugs:**

- WinRM commandline limits can break Windows bootstrapping [\#811](https://github.com/test-kitchen/test-kitchen/issues/811)

**Closed issues:**

- PR \#1328 broken the ability to specify symbols in kitchen configs [\#1345](https://github.com/test-kitchen/test-kitchen/issues/1345)
- converge fails rmdir /tmp [\#1341](https://github.com/test-kitchen/test-kitchen/issues/1341)
- Unable to download with winrm \(undefined local variable or method `session'\) [\#1337](https://github.com/test-kitchen/test-kitchen/issues/1337)
- kitchen "exec" transport: announce environment variables [\#1333](https://github.com/test-kitchen/test-kitchen/issues/1333)
- Omnibus fails to install on ubuntu-16.04 due to permissions error [\#1330](https://github.com/test-kitchen/test-kitchen/issues/1330)
- safe\_yaml is broken with newer psych [\#1327](https://github.com/test-kitchen/test-kitchen/issues/1327)
- No such cookbook error with kitchen 1.17.0 [\#1323](https://github.com/test-kitchen/test-kitchen/issues/1323)
- Support reverse port forwarding when connecting via SSH transport [\#1322](https://github.com/test-kitchen/test-kitchen/issues/1322)
- upload of sandbox directory fails with symlink in repo [\#1319](https://github.com/test-kitchen/test-kitchen/issues/1319)
- Rakefile is missing berkshelf gem [\#1316](https://github.com/test-kitchen/test-kitchen/issues/1316)
- Chef 13, CHefDK 2.3.4, Test-Kitchen 1.17.0 - Windows converge error with policyfile\_zero provisioner [\#1305](https://github.com/test-kitchen/test-kitchen/issues/1305)
- Retry chef run after receiving WSMAN ERROR CODE: 995 in test-kitchen [\#1272](https://github.com/test-kitchen/test-kitchen/issues/1272)
- kitchen has wrong exit code for chef-solo failure on windows \(winrm\) [\#1134](https://github.com/test-kitchen/test-kitchen/issues/1134)
- `chef-long\_script.ps1` giving error when trying to spin up windows box [\#1013](https://github.com/test-kitchen/test-kitchen/issues/1013)
- Support multiple paths for data bags [\#634](https://github.com/test-kitchen/test-kitchen/issues/634)

**Merged pull requests:**

- Re-allow symbols in the config file. [\#1347](https://github.com/test-kitchen/test-kitchen/pull/1347) ([coderanger](https://github.com/coderanger))
- Release 1.20.0 [\#1346](https://github.com/test-kitchen/test-kitchen/pull/1346) ([cheeseplus](https://github.com/cheeseplus))
- Only allow one deprecation message to print per config [\#1340](https://github.com/test-kitchen/test-kitchen/pull/1340) ([wrightp](https://github.com/wrightp))
- Pin minitest to fix build [\#1339](https://github.com/test-kitchen/test-kitchen/pull/1339) ([cheeseplus](https://github.com/cheeseplus))
- fix file\_manager [\#1338](https://github.com/test-kitchen/test-kitchen/pull/1338) ([gtmanfred](https://github.com/gtmanfred))
- \[MSYS-721\] Added KITCHEN\_SSH\_PROXY feature to connect via http proxy [\#1329](https://github.com/test-kitchen/test-kitchen/pull/1329) ([NAshwini](https://github.com/NAshwini))
- Remove safe\_yaml [\#1328](https://github.com/test-kitchen/test-kitchen/pull/1328) ([coderanger](https://github.com/coderanger))
- Support multiple paths for data bags [\#1313](https://github.com/test-kitchen/test-kitchen/pull/1313) ([thomasdziedzic](https://github.com/thomasdziedzic))
- \[MSYS-703\] Fix code to validate retry\_on\_exit\_code [\#1312](https://github.com/test-kitchen/test-kitchen/pull/1312) ([NAshwini](https://github.com/NAshwini))
- adding download support to the base transport and provisioner [\#1306](https://github.com/test-kitchen/test-kitchen/pull/1306) ([atheiman](https://github.com/atheiman))
- Configuration Deprecation warnings [\#1303](https://github.com/test-kitchen/test-kitchen/pull/1303) ([wrightp](https://github.com/wrightp))

## [v1.19.2](https://github.com/test-kitchen/test-kitchen/tree/v1.19.2) (2017-11-28)

[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v1.19.1...v1.19.2)

**Closed issues:**

- Test-kitchen converge fails with closed stream \(IOError\) [\#1320](https://github.com/test-kitchen/test-kitchen/issues/1320)

**Merged pull requests:**

- Release 1.19.2 [\#1325](https://github.com/test-kitchen/test-kitchen/pull/1325) ([tas50](https://github.com/tas50))
- Bump the winrm-fs dep from ~1.0.2 -\> ~1.1.0 [\#1324](https://github.com/test-kitchen/test-kitchen/pull/1324) ([tas50](https://github.com/tas50))

## [v1.19.1](https://github.com/test-kitchen/test-kitchen/tree/v1.19.1) (2017-11-17)

[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v1.19.0...v1.19.1)

**Fixed bugs:**

- product\_name/product\_version re-install chef client [\#1215](https://github.com/test-kitchen/test-kitchen/issues/1215)

**Closed issues:**

- After reboot, client.rb missing? [\#1315](https://github.com/test-kitchen/test-kitchen/issues/1315)
- Configuration data can't unzip to kitchen\configuration folder on target instance \(Windows\)  [\#1311](https://github.com/test-kitchen/test-kitchen/issues/1311)
- test-kitchen Windows 10 packages/un-packages cookbooks improperly on target VM [\#1302](https://github.com/test-kitchen/test-kitchen/issues/1302)
- Kitchen create is not able to create a VM with the below error [\#1292](https://github.com/test-kitchen/test-kitchen/issues/1292)
- Fails to continue with converge when reboot triggered \(Windows 2016\) [\#1227](https://github.com/test-kitchen/test-kitchen/issues/1227)
- Use of enforce\_idempotency Causes 'Failed to complete \#converge action' [\#1225](https://github.com/test-kitchen/test-kitchen/issues/1225)
- Rebooting Linux support broken by chef-client [\#1218](https://github.com/test-kitchen/test-kitchen/issues/1218)
- Option for bootstrap\_run\_list to run before the actual run\_list [\#1195](https://github.com/test-kitchen/test-kitchen/issues/1195)
- \[\[WinRM::FS::Core::FileTransporter\] Upload  failed \(exitcode: 1\) - In Windows 2012RTM only [\#1106](https://github.com/test-kitchen/test-kitchen/issues/1106)
- Provide CLI argument to set provisioner log\_level [\#995](https://github.com/test-kitchen/test-kitchen/issues/995)

**Merged pull requests:**

- Release 1.19.1 [\#1318](https://github.com/test-kitchen/test-kitchen/pull/1318) ([cheeseplus](https://github.com/cheeseplus))
- Remove extraneous bash shebang. [\#1317](https://github.com/test-kitchen/test-kitchen/pull/1317) ([rhass](https://github.com/rhass))
- Turn auto-retries on by default for Chef provisioners [\#1310](https://github.com/test-kitchen/test-kitchen/pull/1310) ([coderanger](https://github.com/coderanger))

## [v1.19.0](https://github.com/test-kitchen/test-kitchen/tree/v1.19.0) (2017-11-01)

[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v1.18.0...v1.19.0)

**Closed issues:**

- Kitchen Feedback & tracking of boxes [\#1308](https://github.com/test-kitchen/test-kitchen/issues/1308)
- Cookbook is not copying to instance [\#1299](https://github.com/test-kitchen/test-kitchen/issues/1299)
- Errors when passing encrypted\_data\_bag\_secret\_key\_path [\#1297](https://github.com/test-kitchen/test-kitchen/issues/1297)
- Question: Multiple Verifiers? [\#1288](https://github.com/test-kitchen/test-kitchen/issues/1288)
- Kitchen converge fails to copy cookbooks over winrm in certain cases [\#1275](https://github.com/test-kitchen/test-kitchen/issues/1275)
- Support for proxying SSH \(ProxyCommand\) [\#829](https://github.com/test-kitchen/test-kitchen/issues/829)

**Merged pull requests:**

- Release prep for 1.19 [\#1309](https://github.com/test-kitchen/test-kitchen/pull/1309) ([coderanger](https://github.com/coderanger))
- Basic framework for kitchen doctor [\#1301](https://github.com/test-kitchen/test-kitchen/pull/1301) ([coderanger](https://github.com/coderanger))
- add kitchen-sparkleformation driver to ECOSYSTEM.md [\#1300](https://github.com/test-kitchen/test-kitchen/pull/1300) ([pesimon](https://github.com/pesimon))
- Add a --debug command line option [\#1296](https://github.com/test-kitchen/test-kitchen/pull/1296) ([coderanger](https://github.com/coderanger))
- Exec driver [\#1295](https://github.com/test-kitchen/test-kitchen/pull/1295) ([coderanger](https://github.com/coderanger))
- Misc cleanups [\#1294](https://github.com/test-kitchen/test-kitchen/pull/1294) ([coderanger](https://github.com/coderanger))
- Upgrades to the shell provisioner [\#1293](https://github.com/test-kitchen/test-kitchen/pull/1293) ([coderanger](https://github.com/coderanger))
- Remove the `driver create` and `driver discover` commands [\#1290](https://github.com/test-kitchen/test-kitchen/pull/1290) ([coderanger](https://github.com/coderanger))
- Adds pre\_create\_command for running arbitrary commands [\#1243](https://github.com/test-kitchen/test-kitchen/pull/1243) ([sean797](https://github.com/sean797))
- Added better routine to install Busser+Plugins [\#1083](https://github.com/test-kitchen/test-kitchen/pull/1083) ([yeoldegrove](https://github.com/yeoldegrove))

## [v1.18.0](https://github.com/test-kitchen/test-kitchen/tree/v1.18.0) (2017-09-28)

[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v1.17.0...v1.18.0)

**Fixed bugs:**

- Omnibus script hangs if it can't get perms on /tmp/stderr  [\#744](https://github.com/test-kitchen/test-kitchen/issues/744)
- Shell verifier: Print instance name instead of object [\#1263](https://github.com/test-kitchen/test-kitchen/pull/1263) ([rbngzlv](https://github.com/rbngzlv))

**Closed issues:**

- Support for ENV varialbles in .kitchen.yml [\#1278](https://github.com/test-kitchen/test-kitchen/issues/1278)
- :paranoid is deprecated, please use :verify\_host\_key. Supported values are exactly the same, only the name of the option has changed. [\#1277](https://github.com/test-kitchen/test-kitchen/issues/1277)
- Kitchen fails to converge - disk space issue - centos 6.x \(verified against chef-provided centos 6.8, 6.9, etc\) [\#1271](https://github.com/test-kitchen/test-kitchen/issues/1271)
- kitchen destroy targets wrong vm [\#1264](https://github.com/test-kitchen/test-kitchen/issues/1264)
- Setting require\_chef\_omnibus to false results in an error [\#1261](https://github.com/test-kitchen/test-kitchen/issues/1261)
- test pass with `kitchen verify` but not with `kitchen test` [\#1244](https://github.com/test-kitchen/test-kitchen/issues/1244)
- Net::SSH::ChannelOpenFailed [\#1111](https://github.com/test-kitchen/test-kitchen/issues/1111)
- Readme: add instructions for updating test-kitchen inside ChefDK [\#1009](https://github.com/test-kitchen/test-kitchen/issues/1009)
- Add ability to pass arguments to shell provisioner [\#917](https://github.com/test-kitchen/test-kitchen/issues/917)
- Profiling kitchen runs [\#863](https://github.com/test-kitchen/test-kitchen/issues/863)
- kitchen close \(or stop\) \[INSTANCE|REGEXP|all\] [\#791](https://github.com/test-kitchen/test-kitchen/issues/791)
- Can we get log level of kitchen from test code? [\#766](https://github.com/test-kitchen/test-kitchen/issues/766)
- Berkshelf::OutdatedDependency swallowing detail [\#420](https://github.com/test-kitchen/test-kitchen/issues/420)

**Merged pull requests:**

- Release 1.18.0 [\#1287](https://github.com/test-kitchen/test-kitchen/pull/1287) ([cheeseplus](https://github.com/cheeseplus))
- reset\_command doesn't actually need to be required [\#1286](https://github.com/test-kitchen/test-kitchen/pull/1286) ([coderanger](https://github.com/coderanger))
- Continue to support older net-ssh while fixing 4.2 deprecation [\#1285](https://github.com/test-kitchen/test-kitchen/pull/1285) ([cheeseplus](https://github.com/cheeseplus))
- Update winrm-fs and make winrm\* gems proper deps [\#1284](https://github.com/test-kitchen/test-kitchen/pull/1284) ([cheeseplus](https://github.com/cheeseplus))
- Pin to net-ssh 4.1.0 for now [\#1283](https://github.com/test-kitchen/test-kitchen/pull/1283) ([cheeseplus](https://github.com/cheeseplus))
- idempotent\_check: Allow specificaton of enforce\_idempotency [\#1282](https://github.com/test-kitchen/test-kitchen/pull/1282) ([MarkGibbons](https://github.com/MarkGibbons))
- Support renamed net-ssh option `verify\_host\_key` [\#1281](https://github.com/test-kitchen/test-kitchen/pull/1281) ([cheeseplus](https://github.com/cheeseplus))
- Reorganized a section and added kitchen-vcenter [\#1279](https://github.com/test-kitchen/test-kitchen/pull/1279) ([jjasghar](https://github.com/jjasghar))
- Add proxy support when using product\_name [\#1276](https://github.com/test-kitchen/test-kitchen/pull/1276) ([wrightp](https://github.com/wrightp))
- Remove Ruby 1.8.7 compat code [\#1274](https://github.com/test-kitchen/test-kitchen/pull/1274) ([tas50](https://github.com/tas50))
- Move extra dev deps to the Gemfile [\#1273](https://github.com/test-kitchen/test-kitchen/pull/1273) ([tas50](https://github.com/tas50))
- Add myself as a maintainer [\#1270](https://github.com/test-kitchen/test-kitchen/pull/1270) ([tas50](https://github.com/tas50))
- Swap IRC for Slack in the readme [\#1269](https://github.com/test-kitchen/test-kitchen/pull/1269) ([tas50](https://github.com/tas50))
- Remove rack pin for Ruby 2.1 & move changelog gen to gemfile [\#1268](https://github.com/test-kitchen/test-kitchen/pull/1268) ([tas50](https://github.com/tas50))
- Add download\_url and checksum provisioner config options [\#1267](https://github.com/test-kitchen/test-kitchen/pull/1267) ([wrightp](https://github.com/wrightp))
- Add kitchen-terraform to the readme [\#1266](https://github.com/test-kitchen/test-kitchen/pull/1266) ([tas50](https://github.com/tas50))
- New install\_strategy option used in conjunction with product\_name [\#1262](https://github.com/test-kitchen/test-kitchen/pull/1262) ([wrightp](https://github.com/wrightp))
- Allow command line arguments config in shell provisioner [\#943](https://github.com/test-kitchen/test-kitchen/pull/943) ([mmckinst](https://github.com/mmckinst))

## [v1.17.0](https://github.com/test-kitchen/test-kitchen/tree/v1.17.0) (2017-08-11)

[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v1.16.0...v1.17.0)

**Fixed bugs:**

- SSH Transport with Windows doesn't appear to work [\#868](https://github.com/test-kitchen/test-kitchen/issues/868)
- Windows: cannot run kitchen test and kitchen login due to a forwading port problem. [\#708](https://github.com/test-kitchen/test-kitchen/issues/708)
- Can't disable ohai plugins using chef-zero provisioner [\#415](https://github.com/test-kitchen/test-kitchen/issues/415)
- Fix Dir.glob usage [\#1258](https://github.com/test-kitchen/test-kitchen/pull/1258) ([jaym](https://github.com/jaym))

**Closed issues:**

- get rid of provisioner, platforms, suites in custom driver from kitchen.yml [\#1257](https://github.com/test-kitchen/test-kitchen/issues/1257)
- unable to load new/custom kitchen driver in my kitchen.yml [\#1256](https://github.com/test-kitchen/test-kitchen/issues/1256)
- Feature request - enabled: false for suite [\#1253](https://github.com/test-kitchen/test-kitchen/issues/1253)
- Test-kitchen without Berkshelf [\#1251](https://github.com/test-kitchen/test-kitchen/issues/1251)
- transport [\#1248](https://github.com/test-kitchen/test-kitchen/issues/1248)
- kitchen verify fails [\#1245](https://github.com/test-kitchen/test-kitchen/issues/1245)
- list [\#1241](https://github.com/test-kitchen/test-kitchen/issues/1241)
- Kitchen create command failing for SUSE  [\#1239](https://github.com/test-kitchen/test-kitchen/issues/1239)
- kitchen converge Failed to complete \#converge action: \[no implicit conversion of nil into String\] [\#1238](https://github.com/test-kitchen/test-kitchen/issues/1238)
- \[windows\] No live threads left. Deadlock? [\#1224](https://github.com/test-kitchen/test-kitchen/issues/1224)
- Switching Test-Kitchen Configuration [\#1223](https://github.com/test-kitchen/test-kitchen/issues/1223)
- Improve 'Test Summary" Coloring; especially "0 Failures" being in Red [\#1222](https://github.com/test-kitchen/test-kitchen/issues/1222)
- synced\_folders not mounted on Windows guests [\#1221](https://github.com/test-kitchen/test-kitchen/issues/1221)
- Message: Could not load the 'propeller' driver from the load path.  [\#1219](https://github.com/test-kitchen/test-kitchen/issues/1219)
- \[QUESTION\] Verifier Retry Options [\#1217](https://github.com/test-kitchen/test-kitchen/issues/1217)
- kitchen converge ssl error on windows [\#1216](https://github.com/test-kitchen/test-kitchen/issues/1216)
- Syncronzing Cookbooks fails to sync root files [\#1213](https://github.com/test-kitchen/test-kitchen/issues/1213)
- Kitchen converge fails on second converge [\#1212](https://github.com/test-kitchen/test-kitchen/issues/1212)
- Message: Failed to complete \#converge action: \[\[WinRM::FS::Core::FileTransporter\] Upload failed \(exitcode: 1\) [\#1211](https://github.com/test-kitchen/test-kitchen/issues/1211)
- "file is of unknown type" error message should be "file not found" [\#1210](https://github.com/test-kitchen/test-kitchen/issues/1210)
- concurrency between multiple KITCHEN\_YAML [\#1207](https://github.com/test-kitchen/test-kitchen/issues/1207)
- serverspec `process` not working corretly [\#1206](https://github.com/test-kitchen/test-kitchen/issues/1206)
- Not possible to converge the machine.  [\#1204](https://github.com/test-kitchen/test-kitchen/issues/1204)
- Gems from metadata.rb are not installed when running via test kitchen. [\#1203](https://github.com/test-kitchen/test-kitchen/issues/1203)
- New release [\#1194](https://github.com/test-kitchen/test-kitchen/issues/1194)
- Message: SCP upload failed \(open failed \(1\)\) when additional\_copy\_path = '.' [\#1191](https://github.com/test-kitchen/test-kitchen/issues/1191)
- Travis fails with a SCP error on the spec directory [\#1187](https://github.com/test-kitchen/test-kitchen/issues/1187)
- kitchen login doesn't pass ssh password from kitchen.yml [\#1175](https://github.com/test-kitchen/test-kitchen/issues/1175)
- 1.14.2 throws network path was not found on Windows [\#1171](https://github.com/test-kitchen/test-kitchen/issues/1171)
- a link on kitchen.ci/blog is broken \(very minor\) [\#1161](https://github.com/test-kitchen/test-kitchen/issues/1161)
- ssh port forwarding [\#1159](https://github.com/test-kitchen/test-kitchen/issues/1159)
- TypeError: superclass mismatch for class Docker [\#1132](https://github.com/test-kitchen/test-kitchen/issues/1132)
- WinRM Transport requires the vagrant-winrm Vagrant plugin [\#1109](https://github.com/test-kitchen/test-kitchen/issues/1109)
- sometimes TK doesn't mount shares [\#1093](https://github.com/test-kitchen/test-kitchen/issues/1093)
- Docs on <https://docs.chef.io/> have not been kept up to date [\#1060](https://github.com/test-kitchen/test-kitchen/issues/1060)
- Test Kitchen now uses local profile and gives no option to use berks [\#1036](https://github.com/test-kitchen/test-kitchen/issues/1036)
- "kitchen list" breaks if suits: & - name: fields are missing [\#893](https://github.com/test-kitchen/test-kitchen/issues/893)
- Produce a better error message when the underlying virtualization provider is missing [\#831](https://github.com/test-kitchen/test-kitchen/issues/831)
- Output is buffered until the end of the Chef run -\> don't see what's going on [\#826](https://github.com/test-kitchen/test-kitchen/issues/826)
- Rename `:require\_chef\_omnibus` config attribute name to `:chef\_version` [\#771](https://github.com/test-kitchen/test-kitchen/issues/771)
- run with specific version of the chef-client [\#715](https://github.com/test-kitchen/test-kitchen/issues/715)
- require\_chef\_omnibus re-installs chef-client when not needed [\#691](https://github.com/test-kitchen/test-kitchen/issues/691)
- If Berksfile is present, kitchen never finds Cheffile [\#686](https://github.com/test-kitchen/test-kitchen/issues/686)
- Reference-Style Documentation for Kitchen file [\#682](https://github.com/test-kitchen/test-kitchen/issues/682)
- kitchen does not create needed interface. no errors [\#621](https://github.com/test-kitchen/test-kitchen/issues/621)
- Custom root\_path permissions issues [\#576](https://github.com/test-kitchen/test-kitchen/issues/576)
- .kitchen.yml configuration options  [\#574](https://github.com/test-kitchen/test-kitchen/issues/574)
- Need a mechanism to share tests between suites [\#503](https://github.com/test-kitchen/test-kitchen/issues/503)
- Doc needs updating with existing configuration options [\#409](https://github.com/test-kitchen/test-kitchen/issues/409)
- kitchen login not working with plink [\#367](https://github.com/test-kitchen/test-kitchen/issues/367)
- Add a way to execute arbitrary driver commands [\#350](https://github.com/test-kitchen/test-kitchen/issues/350)

**Merged pull requests:**

- release 1.17.0 [\#1259](https://github.com/test-kitchen/test-kitchen/pull/1259) ([robbkidd](https://github.com/robbkidd))
- reduce warnings during test runs [\#1255](https://github.com/test-kitchen/test-kitchen/pull/1255) ([robbkidd](https://github.com/robbkidd))
- use a more efficient sort for gem specs [\#1254](https://github.com/test-kitchen/test-kitchen/pull/1254) ([robbkidd](https://github.com/robbkidd))
- fixes formatting for tables on ECOSYSTEM.md [\#1247](https://github.com/test-kitchen/test-kitchen/pull/1247) ([brewn](https://github.com/brewn))
- test on precise [\#1237](https://github.com/test-kitchen/test-kitchen/pull/1237) ([lamont-granquist](https://github.com/lamont-granquist))
- remove 2.2.x support [\#1236](https://github.com/test-kitchen/test-kitchen/pull/1236) ([lamont-granquist](https://github.com/lamont-granquist))
- greenify appveyor tests [\#1235](https://github.com/test-kitchen/test-kitchen/pull/1235) ([lamont-granquist](https://github.com/lamont-granquist))
- just ignore busted test [\#1234](https://github.com/test-kitchen/test-kitchen/pull/1234) ([lamont-granquist](https://github.com/lamont-granquist))
- remove badges [\#1233](https://github.com/test-kitchen/test-kitchen/pull/1233) ([lamont-granquist](https://github.com/lamont-granquist))
- let dev gems float [\#1232](https://github.com/test-kitchen/test-kitchen/pull/1232) ([lamont-granquist](https://github.com/lamont-granquist))
- Test on most recent Ruby releases [\#1228](https://github.com/test-kitchen/test-kitchen/pull/1228) ([tas50](https://github.com/tas50))

## [v1.16.0](https://github.com/test-kitchen/test-kitchen/tree/v1.16.0) (2017-03-03)

[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v1.15.0...v1.16.0)

**Fixed bugs:**

- Pinning thor to match berks [\#1189](https://github.com/test-kitchen/test-kitchen/pull/1189) ([cheeseplus](https://github.com/cheeseplus))

**Closed issues:**

- Message: Could not load the 'ansible\_playbook' provisioner from the load path [\#1197](https://github.com/test-kitchen/test-kitchen/issues/1197)
- pull or push in a docker registry with kitchen [\#1186](https://github.com/test-kitchen/test-kitchen/issues/1186)
- Compat issues with net-ssh 4.x [\#1184](https://github.com/test-kitchen/test-kitchen/issues/1184)
- Changelog was not updated for the 1.15.0 release [\#1183](https://github.com/test-kitchen/test-kitchen/issues/1183)
- Could not load or activate Berkshelf [\#1172](https://github.com/test-kitchen/test-kitchen/issues/1172)
- WinRm - I/O Operation Aborted [\#1142](https://github.com/test-kitchen/test-kitchen/issues/1142)
- Guest hostname does not get set if converge times out during vagrant VM boot [\#1128](https://github.com/test-kitchen/test-kitchen/issues/1128)
- I'm trying to run kitchen converge but getting the converge IO error [\#1075](https://github.com/test-kitchen/test-kitchen/issues/1075)
- Enforce suite idempotency [\#874](https://github.com/test-kitchen/test-kitchen/issues/874)
- Documentation for support for Encrypted Data Bags [\#384](https://github.com/test-kitchen/test-kitchen/issues/384)

**Merged pull requests:**

- Preparation for Release [\#1202](https://github.com/test-kitchen/test-kitchen/pull/1202) ([afiune](https://github.com/afiune))
- Update to latest train \(and net-ssh 4\) for testing [\#1201](https://github.com/test-kitchen/test-kitchen/pull/1201) ([tduffield](https://github.com/tduffield))
- fixing chefstyle 0.5.0 issues [\#1192](https://github.com/test-kitchen/test-kitchen/pull/1192) ([lamont-granquist](https://github.com/lamont-granquist))
- Fix bad rakefile error message on missing chefstyle [\#1182](https://github.com/test-kitchen/test-kitchen/pull/1182) ([tas50](https://github.com/tas50))
- Add missing changelog for 1.15.0 [\#1181](https://github.com/test-kitchen/test-kitchen/pull/1181) ([tas50](https://github.com/tas50))
- Test on current ruby releases [\#1179](https://github.com/test-kitchen/test-kitchen/pull/1179) ([tas50](https://github.com/tas50))
- Export no\_proxy from kitchen config [\#1178](https://github.com/test-kitchen/test-kitchen/pull/1178) ([itmustbejj](https://github.com/itmustbejj))
- Adding transport option "ssh\_key\_only". [\#1141](https://github.com/test-kitchen/test-kitchen/pull/1141) ([cliles](https://github.com/cliles))
- Run chef-client twice in chef-zero provisioner [\#875](https://github.com/test-kitchen/test-kitchen/pull/875) ([kamaradclimber](https://github.com/kamaradclimber))

## [v1.15.0](https://github.com/test-kitchen/test-kitchen/tree/v1.15.0) (2017-01-12)

[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v1.14.2...v1.15.0)

**Fixed bugs:**

- Fix busser trying to run bats when bats tests don't exist [\#1133](https://github.com/test-kitchen/test-kitchen/pull/1133) ([amontalban](https://github.com/amontalban))

**Closed issues:**

- "incompatible character encodings: UTF-8 and ASCII-8BIT" when using cyrillic letters in cookbook [\#1170](https://github.com/test-kitchen/test-kitchen/issues/1170)
- ssh\_key is not read and sent to the args for ssh transport [\#1169](https://github.com/test-kitchen/test-kitchen/issues/1169)
- Display the last action's success [\#1124](https://github.com/test-kitchen/test-kitchen/issues/1124)

**Merged pull requests:**

- Relax dependencies to bring in newer gem versions [\#1176](https://github.com/test-kitchen/test-kitchen/pull/1176) ([lamont-granquist](https://github.com/lamont-granquist))
- Remove ruby 2.1.9 from test matrix [\#1174](https://github.com/test-kitchen/test-kitchen/pull/1174) ([mwrock](https://github.com/mwrock))
- Bump version after release [\#1168](https://github.com/test-kitchen/test-kitchen/pull/1168) ([afiune](https://github.com/afiune))
- Make RakeTask\#config public. [\#1069](https://github.com/test-kitchen/test-kitchen/pull/1069) ([gregsymons](https://github.com/gregsymons))

## [v1.14.2](https://github.com/test-kitchen/test-kitchen/tree/v1.14.2) (2016-12-09)

[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v1.14.1...v1.14.2)

**Merged pull requests:**

- Prep Release 1.14.2 [\#1167](https://github.com/test-kitchen/test-kitchen/pull/1167) ([afiune](https://github.com/afiune))
- Replace finstyle in favor of chefstyle [\#1166](https://github.com/test-kitchen/test-kitchen/pull/1166) ([afiune](https://github.com/afiune))
- Bump version after release [\#1165](https://github.com/test-kitchen/test-kitchen/pull/1165) ([afiune](https://github.com/afiune))

## [v1.14.1](https://github.com/test-kitchen/test-kitchen/tree/v1.14.1) (2016-12-08)

[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v1.14.0...v1.14.1)

**Closed issues:**

- Getting message: "Expected array default value for '--driver'; got "kitchen-vagrant" \(string\)" with every operation [\#1163](https://github.com/test-kitchen/test-kitchen/issues/1163)
- Possible to specify a custom bootstrap template? [\#1162](https://github.com/test-kitchen/test-kitchen/issues/1162)
- Deployment of cookbooks do differ from berks package [\#1158](https://github.com/test-kitchen/test-kitchen/issues/1158)
- Failed to complete \#create action: \[undefined method `\[\]' for nil:NilClass\] [\#1157](https://github.com/test-kitchen/test-kitchen/issues/1157)
- inspec works, but kitchen verify fails [\#1154](https://github.com/test-kitchen/test-kitchen/issues/1154)

**Merged pull requests:**

- Prep for 1.14.1 release [\#1164](https://github.com/test-kitchen/test-kitchen/pull/1164) ([afiune](https://github.com/afiune))
- Fix typo in berkshelf chef provisioner [\#1160](https://github.com/test-kitchen/test-kitchen/pull/1160) ([thommay](https://github.com/thommay))
- Update MAINTAINERS.md [\#1156](https://github.com/test-kitchen/test-kitchen/pull/1156) ([afiune](https://github.com/afiune))
- Fix to work with Thor 0.19.2 [\#1155](https://github.com/test-kitchen/test-kitchen/pull/1155) ([coderanger](https://github.com/coderanger))
- bump version after release [\#1153](https://github.com/test-kitchen/test-kitchen/pull/1153) ([smurawski](https://github.com/smurawski))

## [v1.14.0](https://github.com/test-kitchen/test-kitchen/tree/v1.14.0) (2016-11-22)

[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v1.13.2...v1.14.0)

**Closed issues:**

- Kitchen converge fails, doesn't install omnibus,  \[\[WinRM::FS::Core::FileTransporter\] Upload failed [\#1150](https://github.com/test-kitchen/test-kitchen/issues/1150)
- Re-Enable Code Climate [\#1146](https://github.com/test-kitchen/test-kitchen/issues/1146)
- kitchen + berkshelf don't work together with the latest versions of gems [\#1144](https://github.com/test-kitchen/test-kitchen/issues/1144)
- Vagrant drivers brings up virtualbox machine with 'cable connected' disabled option [\#1143](https://github.com/test-kitchen/test-kitchen/issues/1143)
- kitchen converge throws Berkshelf::LockfileNotFound on Windows [\#1140](https://github.com/test-kitchen/test-kitchen/issues/1140)
- Inspect tests is an empty value when using the kitchen\_ec2 driver [\#1136](https://github.com/test-kitchen/test-kitchen/issues/1136)
- kitchen test or verify with --parallel option fails [\#1125](https://github.com/test-kitchen/test-kitchen/issues/1125)
- Test Kitchen should use omnitruck's -d option by default [\#809](https://github.com/test-kitchen/test-kitchen/issues/809)
- Bats tests are being executed even missing specification [\#360](https://github.com/test-kitchen/test-kitchen/issues/360)

**Merged pull requests:**

- Prep for 1.14.0 Release [\#1152](https://github.com/test-kitchen/test-kitchen/pull/1152) ([smurawski](https://github.com/smurawski))
- Added `cache` interface for Drivers so that provisioners can leverage  [\#1149](https://github.com/test-kitchen/test-kitchen/pull/1149) ([afiune](https://github.com/afiune))
- Closed \#1146 and restores codeclimate reporting. [\#1148](https://github.com/test-kitchen/test-kitchen/pull/1148) ([smurawski](https://github.com/smurawski))
- Remove codeclimate-test-reporter as that has been deprecated [\#1147](https://github.com/test-kitchen/test-kitchen/pull/1147) ([smurawski](https://github.com/smurawski))
- Ensure that we only berks update with a lockfile [\#1145](https://github.com/test-kitchen/test-kitchen/pull/1145) ([thommay](https://github.com/thommay))
- Added `last\_error` and `--json` to `kitchen list` [\#1135](https://github.com/test-kitchen/test-kitchen/pull/1135) ([BackSlasher](https://github.com/BackSlasher))
- Allow the user to make deprecations errors [\#1117](https://github.com/test-kitchen/test-kitchen/pull/1117) ([thommay](https://github.com/thommay))

## [v1.13.2](https://github.com/test-kitchen/test-kitchen/tree/v1.13.2) (2016-09-26)

[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v1.13.1...v1.13.2)

**Fixed bugs:**

- fix broken path on nano so shell out works [\#1129](https://github.com/test-kitchen/test-kitchen/pull/1129) ([mwrock](https://github.com/mwrock))

**Merged pull requests:**

- Release 1.13.2 [\#1130](https://github.com/test-kitchen/test-kitchen/pull/1130) ([mwrock](https://github.com/mwrock))

## [v1.13.1](https://github.com/test-kitchen/test-kitchen/tree/v1.13.1) (2016-09-22)

[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v1.13.0...v1.13.1)

**Closed issues:**

- failed to converge on OSX 10.11.6 [\#1122](https://github.com/test-kitchen/test-kitchen/issues/1122)

**Merged pull requests:**

- Bump version to 1.13.1 [\#1127](https://github.com/test-kitchen/test-kitchen/pull/1127) ([jkeiser](https://github.com/jkeiser))
- Allow mixlib-install 2.0 [\#1126](https://github.com/test-kitchen/test-kitchen/pull/1126) ([jkeiser](https://github.com/jkeiser))

## [v1.13.0](https://github.com/test-kitchen/test-kitchen/tree/v1.13.0) (2016-09-16)

[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v1.12.0...v1.13.0)

**Fixed bugs:**

- SSH Transport: Bastion proxy results in broken pipe error [\#1079](https://github.com/test-kitchen/test-kitchen/issues/1079)

**Closed issues:**

- converge fails Windows Server 2012R2 "This implementation is not part of Windows Platform FIPS validated cryptographic algorithms" [\#1116](https://github.com/test-kitchen/test-kitchen/issues/1116)
- Run chef-solo in legacy mode for chef\_solo provisioner under Chef 12.11+ [\#1070](https://github.com/test-kitchen/test-kitchen/issues/1070)
- 'username:' keyword not respected during `kitchen exec -c 'command'` [\#756](https://github.com/test-kitchen/test-kitchen/issues/756)
- CONVERGE: Failed to complete \#converge action of .git folder [\#544](https://github.com/test-kitchen/test-kitchen/issues/544)
- Option to use internal gem server [\#474](https://github.com/test-kitchen/test-kitchen/issues/474)
- Add `kitchen status` command [\#87](https://github.com/test-kitchen/test-kitchen/issues/87)

**Merged pull requests:**

- Release 1.13.0 [\#1121](https://github.com/test-kitchen/test-kitchen/pull/1121) ([mwrock](https://github.com/mwrock))
- Add support for Windows Nano installs via chef provisioners [\#1119](https://github.com/test-kitchen/test-kitchen/pull/1119) ([mwrock](https://github.com/mwrock))
- Fixes \#87 because we love Mike [\#1115](https://github.com/test-kitchen/test-kitchen/pull/1115) ([cheeseplus](https://github.com/cheeseplus))
- Fixing deps [\#1114](https://github.com/test-kitchen/test-kitchen/pull/1114) ([cheeseplus](https://github.com/cheeseplus))
- Added Errno::EPIPE to RESCUE\_EXCEPTIONS\_ON\_ESTABLISH [\#1078](https://github.com/test-kitchen/test-kitchen/pull/1078) ([yoshiwaan](https://github.com/yoshiwaan))
- Add package driver command [\#1074](https://github.com/test-kitchen/test-kitchen/pull/1074) ([neillturner](https://github.com/neillturner))

## [v1.12.0](https://github.com/test-kitchen/test-kitchen/tree/v1.12.0) (2016-09-02)

[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v1.11.1...v1.12.0)

**Closed issues:**

- ssh\_key not used with kitchen login [\#1108](https://github.com/test-kitchen/test-kitchen/issues/1108)
- Add supplemental kitchen commands to rake task [\#1104](https://github.com/test-kitchen/test-kitchen/issues/1104)
- Ability to change tk- prefix to another optionally. [\#1101](https://github.com/test-kitchen/test-kitchen/issues/1101)
- Net::SSH::ChannelOpenFailed [\#1084](https://github.com/test-kitchen/test-kitchen/issues/1084)

**Merged pull requests:**

- Release 1.12.0 [\#1110](https://github.com/test-kitchen/test-kitchen/pull/1110) ([mwrock](https://github.com/mwrock))
- Add a new config option always\_update\_cookbooks [\#1107](https://github.com/test-kitchen/test-kitchen/pull/1107) ([coderanger](https://github.com/coderanger))
- Always run `chef install` even if the lock file exists. [\#1103](https://github.com/test-kitchen/test-kitchen/pull/1103) ([coderanger](https://github.com/coderanger))
- support passing Kitchen::Config Hash keys to Kitchen::RakeTasks.new [\#1102](https://github.com/test-kitchen/test-kitchen/pull/1102) ([theckman](https://github.com/theckman))
- Update Ruby versions to test on [\#1100](https://github.com/test-kitchen/test-kitchen/pull/1100) ([tas50](https://github.com/tas50))
- Use winrm v2 release gems [\#1061](https://github.com/test-kitchen/test-kitchen/pull/1061) ([mwrock](https://github.com/mwrock))

## [v1.11.1](https://github.com/test-kitchen/test-kitchen/tree/v1.11.1) (2016-08-13)

[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v1.11.0...v1.11.1)

**Closed issues:**

- More verbose kitchen verify output? [\#1097](https://github.com/test-kitchen/test-kitchen/issues/1097)

**Merged pull requests:**

- Release 1.11.1 [\#1099](https://github.com/test-kitchen/test-kitchen/pull/1099) ([mwrock](https://github.com/mwrock))
- Check the actual value, because `password: nil` shouldn't disable sending the key. [\#1098](https://github.com/test-kitchen/test-kitchen/pull/1098) ([coderanger](https://github.com/coderanger))

## [v1.11.0](https://github.com/test-kitchen/test-kitchen/tree/v1.11.0) (2016-08-12)

[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v1.10.2...v1.11.0)

**Fixed bugs:**

- Escape paths before running policyfile commands [\#1085](https://github.com/test-kitchen/test-kitchen/pull/1085) ([coderanger](https://github.com/coderanger))

**Closed issues:**

- Allow force override of chef attributes [\#1094](https://github.com/test-kitchen/test-kitchen/issues/1094)
- inspec "not found in load path" when used as verifier [\#1090](https://github.com/test-kitchen/test-kitchen/issues/1090)
- Is cane still useful? [\#1086](https://github.com/test-kitchen/test-kitchen/issues/1086)
- policy\_group hardcoded to 'local'.  I would like to set this per suite. [\#1080](https://github.com/test-kitchen/test-kitchen/issues/1080)
- Release 1.10.1 contains Windows newline characters [\#1066](https://github.com/test-kitchen/test-kitchen/issues/1066)
- Provide some way for Chef to know it's running under test [\#458](https://github.com/test-kitchen/test-kitchen/issues/458)

**Merged pull requests:**

- Release 1.11.0 [\#1096](https://github.com/test-kitchen/test-kitchen/pull/1096) ([mwrock](https://github.com/mwrock))
- Dont set ssh key configuration if a password is specified [\#1095](https://github.com/test-kitchen/test-kitchen/pull/1095) ([mwrock](https://github.com/mwrock))
- Ability to work with Instances over SSH tunnel. [\#1091](https://github.com/test-kitchen/test-kitchen/pull/1091) ([EYurchenko](https://github.com/EYurchenko))
- Add coderanger as a maintainer [\#1089](https://github.com/test-kitchen/test-kitchen/pull/1089) ([coderanger](https://github.com/coderanger))
- Remove cane in favor of RuboCop/finstyle. [\#1088](https://github.com/test-kitchen/test-kitchen/pull/1088) ([coderanger](https://github.com/coderanger))
- Add environment variables $TEST\_KITCHEN and $CI [\#1081](https://github.com/test-kitchen/test-kitchen/pull/1081) ([coderanger](https://github.com/coderanger))
- Adding test\_base\_path CLI arg to the diagnose command [\#1076](https://github.com/test-kitchen/test-kitchen/pull/1076) ([tyler-ball](https://github.com/tyler-ball))
- Add legacy\_mode argument for chef\_solo provisioner [\#1073](https://github.com/test-kitchen/test-kitchen/pull/1073) ([SaltwaterC](https://github.com/SaltwaterC))
- Added support for Chef 10 [\#1072](https://github.com/test-kitchen/test-kitchen/pull/1072) ([acondrat](https://github.com/acondrat))
- Use a less volatile recipe for ci tests [\#1071](https://github.com/test-kitchen/test-kitchen/pull/1071) ([mwrock](https://github.com/mwrock))

## [v1.10.2](https://github.com/test-kitchen/test-kitchen/tree/v1.10.2) (2016-06-24)

[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v1.10.2.dev...v1.10.2)

## [v1.10.2.dev](https://github.com/test-kitchen/test-kitchen/tree/v1.10.2.dev) (2016-06-24)

[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v1.10.1...v1.10.2.dev)

**Merged pull requests:**

- bumping version for a gem repackage [\#1067](https://github.com/test-kitchen/test-kitchen/pull/1067) ([mwrock](https://github.com/mwrock))

## [v1.10.1](https://github.com/test-kitchen/test-kitchen/tree/v1.10.1) (2016-06-23)

[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v1.10.0...v1.10.1)

**Fixed bugs:**

- Reboot resource with new 'reboot and try again' feature [\#1062](https://github.com/test-kitchen/test-kitchen/issues/1062)
- Fix WinRM Upload Failures After Reboot [\#1064](https://github.com/test-kitchen/test-kitchen/pull/1064) ([smurawski](https://github.com/smurawski))

**Closed issues:**

- Pulling in environment variable \(OS environment, not chef environment\) as an attribute [\#1063](https://github.com/test-kitchen/test-kitchen/issues/1063)

**Merged pull requests:**

- Release 1.10.1 [\#1065](https://github.com/test-kitchen/test-kitchen/pull/1065) ([smurawski](https://github.com/smurawski))

## [v1.10.0](https://github.com/test-kitchen/test-kitchen/tree/v1.10.0) (2016-06-17)

[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v1.9.2...v1.10.0)

**Closed issues:**

- Converge fails if encrypted\_data\_bag\_secret\_path is specified [\#1052](https://github.com/test-kitchen/test-kitchen/issues/1052)
- kitchen test -c will always return 0, even when failing [\#1051](https://github.com/test-kitchen/test-kitchen/issues/1051)
- Base Provisioner Should Support Reboot And Continue [\#1016](https://github.com/test-kitchen/test-kitchen/issues/1016)
- Custom Config for Busser Plugins  [\#945](https://github.com/test-kitchen/test-kitchen/issues/945)

**Merged pull requests:**

- Release 1.10.0 [\#1058](https://github.com/test-kitchen/test-kitchen/pull/1058) ([smurawski](https://github.com/smurawski))
- Fix appveyor builds [\#1057](https://github.com/test-kitchen/test-kitchen/pull/1057) ([smurawski](https://github.com/smurawski))
- Retry `Kitchen::Provisioner\#run\_command` after allowed exit codes [\#1055](https://github.com/test-kitchen/test-kitchen/pull/1055) ([smurawski](https://github.com/smurawski))
- Add fallback support for `policyfile` for compat with the older policyfile\_zero [\#1053](https://github.com/test-kitchen/test-kitchen/pull/1053) ([coderanger](https://github.com/coderanger))

## [v1.9.2](https://github.com/test-kitchen/test-kitchen/tree/v1.9.2) (2016-06-09)

[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v1.9.1...v1.9.2)

**Fixed bugs:**

- Message: SCP upload failed \(open failed \(1\)\) [\#1035](https://github.com/test-kitchen/test-kitchen/issues/1035)

**Merged pull requests:**

- Prep for 1.9.2 Release [\#1050](https://github.com/test-kitchen/test-kitchen/pull/1050) ([smurawski](https://github.com/smurawski))
- add max scp session handling [\#1047](https://github.com/test-kitchen/test-kitchen/pull/1047) ([lamont-granquist](https://github.com/lamont-granquist))

## [v1.9.1](https://github.com/test-kitchen/test-kitchen/tree/v1.9.1) (2016-06-02)

[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v1.9.0...v1.9.1)

**Fixed bugs:**

- Initializing Kitchen::RakeTasks causes error if Vagrant not installed [\#645](https://github.com/test-kitchen/test-kitchen/issues/645)
- test-kitchen exits if converge fails while there is still task to download a box [\#496](https://github.com/test-kitchen/test-kitchen/issues/496)

**Closed issues:**

- No live threads left. Deadlock? \(fatal\) error [\#1041](https://github.com/test-kitchen/test-kitchen/issues/1041)
- SCP Error 127 [\#1040](https://github.com/test-kitchen/test-kitchen/issues/1040)
- Windows kitchen-tests should run in an Elevated session under System account [\#876](https://github.com/test-kitchen/test-kitchen/issues/876)
- Support `:no\_proxy` in Provisioners and Verifiers [\#687](https://github.com/test-kitchen/test-kitchen/issues/687)

**Merged pull requests:**

- Allow rake task to use env var [\#1046](https://github.com/test-kitchen/test-kitchen/pull/1046) ([smurawski](https://github.com/smurawski))
- adding myself as a maintainer [\#1045](https://github.com/test-kitchen/test-kitchen/pull/1045) ([lamont-granquist](https://github.com/lamont-granquist))
- version bump and CHANGELOG.md for v1.9.1 [\#1044](https://github.com/test-kitchen/test-kitchen/pull/1044) ([smurawski](https://github.com/smurawski))
- Fix CHANGELOG.md links [\#1042](https://github.com/test-kitchen/test-kitchen/pull/1042) ([smurawski](https://github.com/smurawski))
- Add color options [\#1032](https://github.com/test-kitchen/test-kitchen/pull/1032) ([jorhett](https://github.com/jorhett))
- Add support for SSH connection debugging. [\#990](https://github.com/test-kitchen/test-kitchen/pull/990) ([rhass](https://github.com/rhass))

## [v1.9.0](https://github.com/test-kitchen/test-kitchen/tree/v1.9.0) (2016-05-26)

[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v1.8.0...v1.9.0)

**Fixed bugs:**

- Use command\_prefix provided by Kitchen::Provisioner::Base in shell provisioner [\#1033](https://github.com/test-kitchen/test-kitchen/pull/1033) ([pstengel](https://github.com/pstengel))

**Closed issues:**

- Cannot set log level to "info" [\#529](https://github.com/test-kitchen/test-kitchen/issues/529)

**Merged pull requests:**

- Release 1.9.0 [\#1039](https://github.com/test-kitchen/test-kitchen/pull/1039) ([smurawski](https://github.com/smurawski))
- Buffer errors until the end of an action [\#1034](https://github.com/test-kitchen/test-kitchen/pull/1034) ([smurawski](https://github.com/smurawski))
- Fix grammar in common\_sandbox warning message [\#1031](https://github.com/test-kitchen/test-kitchen/pull/1031) ([emachnic](https://github.com/emachnic))
- Update `chef\_omnbius\_url` default value [\#1028](https://github.com/test-kitchen/test-kitchen/pull/1028) ([schisamo](https://github.com/schisamo))
- Empty string for the config setting for proxies did not really work [\#1027](https://github.com/test-kitchen/test-kitchen/pull/1027) ([smurawski](https://github.com/smurawski))
- Added kitchen-docker [\#1025](https://github.com/test-kitchen/test-kitchen/pull/1025) ([jjasghar](https://github.com/jjasghar))
- Add kitchen-azurerm to list of community-provided drivers [\#1024](https://github.com/test-kitchen/test-kitchen/pull/1024) ([stuartpreston](https://github.com/stuartpreston))
- uploads: reuse connections+disable compression [\#1023](https://github.com/test-kitchen/test-kitchen/pull/1023) ([lamont-granquist](https://github.com/lamont-granquist))
- ECOSYSTEM doc. [\#1015](https://github.com/test-kitchen/test-kitchen/pull/1015) ([jjasghar](https://github.com/jjasghar))

## [v1.8.0](https://github.com/test-kitchen/test-kitchen/tree/v1.8.0) (2016-05-06)

[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v1.7.3...v1.8.0)

**Fixed bugs:**

- Trouble provisioning with chefdk [\#767](https://github.com/test-kitchen/test-kitchen/issues/767)

**Closed issues:**

- AWS Windows AMI adjustment needs a graceful error [\#1021](https://github.com/test-kitchen/test-kitchen/issues/1021)
- Docker provisioner converge fails: \[SSL: CERTIFICATE\_VERIFY\_FAILED\]  [\#1018](https://github.com/test-kitchen/test-kitchen/issues/1018)
- Windows RDP Port Forward Issue [\#1017](https://github.com/test-kitchen/test-kitchen/issues/1017)
- kitchen verify pester fails to install PsGet - "busser.bat : The system cannot find the path specified." [\#1011](https://github.com/test-kitchen/test-kitchen/issues/1011)
- Kitchen converge fails for vagrant kensykora-windows-2012-r2-standard [\#1010](https://github.com/test-kitchen/test-kitchen/issues/1010)

**Merged pull requests:**

- Release 1.8.0 [\#1022](https://github.com/test-kitchen/test-kitchen/pull/1022) ([mwrock](https://github.com/mwrock))
- Add native policyfile resolution support [\#1014](https://github.com/test-kitchen/test-kitchen/pull/1014) ([danielsdeleo](https://github.com/danielsdeleo))
- Provide the option to run all winrm commands through a scheduled task [\#1012](https://github.com/test-kitchen/test-kitchen/pull/1012) ([mwrock](https://github.com/mwrock))

## [v1.7.3](https://github.com/test-kitchen/test-kitchen/tree/v1.7.3) (2016-04-13)

[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v1.7.2...v1.7.3)

**Fixed bugs:**

- Test Kitchen on windows fails to upload data bags [\#1006](https://github.com/test-kitchen/test-kitchen/issues/1006)
- Test Kitchen 1.5+ is no longer compatible with Chef before 12.5.1 [\#922](https://github.com/test-kitchen/test-kitchen/issues/922)
- Long runs timeout [\#380](https://github.com/test-kitchen/test-kitchen/issues/380)
- Fixes busser install for older omnibus windows installs [\#1003](https://github.com/test-kitchen/test-kitchen/pull/1003) ([mwrock](https://github.com/mwrock))

**Closed issues:**

- Ability to pass commands for execution to kitchen login [\#832](https://github.com/test-kitchen/test-kitchen/issues/832)
- forward\_agent kitchen.yml config not honored [\#807](https://github.com/test-kitchen/test-kitchen/issues/807)
- Shell error when attempting to kitchen converge freebsd instance \(if not created first\) [\#712](https://github.com/test-kitchen/test-kitchen/issues/712)
- Busser execution fails serverspec tests with command not found due to sbin not on PATH [\#469](https://github.com/test-kitchen/test-kitchen/issues/469)

**Merged pull requests:**

- Improve README.md to reflect changes to log\_level behavior [\#1008](https://github.com/test-kitchen/test-kitchen/pull/1008) ([drrk](https://github.com/drrk))
- prep tk 1.7.3 release [\#1007](https://github.com/test-kitchen/test-kitchen/pull/1007) ([mwrock](https://github.com/mwrock))
- Relax cucumber and aruba restrictions [\#1002](https://github.com/test-kitchen/test-kitchen/pull/1002) ([jkeiser](https://github.com/jkeiser))
- Request to be added as maintainer [\#972](https://github.com/test-kitchen/test-kitchen/pull/972) ([drrk](https://github.com/drrk))

## [v1.7.2](https://github.com/test-kitchen/test-kitchen/tree/v1.7.2) (2016-04-07)

[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v1.7.1...v1.7.2)

**Closed issues:**

- After upgrading to test-kitchen 1.7.1, openstack fails [\#997](https://github.com/test-kitchen/test-kitchen/issues/997)
- Dos line endings passed to Linux VM during installation of verify tools [\#996](https://github.com/test-kitchen/test-kitchen/issues/996)
- Kitchen Converge Fails [\#994](https://github.com/test-kitchen/test-kitchen/issues/994)

**Merged pull requests:**

- Preparing 1.7.2 release [\#1001](https://github.com/test-kitchen/test-kitchen/pull/1001) ([tyler-ball](https://github.com/tyler-ball))
- Don't require dev dependencies to build [\#1000](https://github.com/test-kitchen/test-kitchen/pull/1000) ([jkeiser](https://github.com/jkeiser))
- update to win2k8 friendly dependencies [\#999](https://github.com/test-kitchen/test-kitchen/pull/999) ([mwrock](https://github.com/mwrock))
- Fix Berkshelf load test [\#998](https://github.com/test-kitchen/test-kitchen/pull/998) ([chefsalim](https://github.com/chefsalim))

## [v1.7.1](https://github.com/test-kitchen/test-kitchen/tree/v1.7.1) (2016-04-02)

[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v1.7.1.dev...v1.7.1)

**Merged pull requests:**

- final 1.7.1 release [\#993](https://github.com/test-kitchen/test-kitchen/pull/993) ([mwrock](https://github.com/mwrock))

## [v1.7.1.dev](https://github.com/test-kitchen/test-kitchen/tree/v1.7.1.dev) (2016-04-02)

[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v1.7.0...v1.7.1.dev)

**Fixed bugs:**

- Adding gitattributes file for managing line ending conversions [\#991](https://github.com/test-kitchen/test-kitchen/pull/991) ([mwrock](https://github.com/mwrock))

**Merged pull requests:**

- prepping 1.7.1 release [\#992](https://github.com/test-kitchen/test-kitchen/pull/992) ([mwrock](https://github.com/mwrock))

## [v1.7.0](https://github.com/test-kitchen/test-kitchen/tree/v1.7.0) (2016-04-01)

[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v1.6.0...v1.7.0)

**Fixed bugs:**

- Fix encrypted data bag uploads on windows [\#981](https://github.com/test-kitchen/test-kitchen/pull/981) ([mwrock](https://github.com/mwrock))
- Shell verifier should ensure env vars are strings [\#973](https://github.com/test-kitchen/test-kitchen/pull/973) ([jsok](https://github.com/jsok))
- Support Empty Proxy Settings [\#936](https://github.com/test-kitchen/test-kitchen/pull/936) ([tacchino](https://github.com/tacchino))

**Closed issues:**

- Windows tests fail with Test Kitchen 1.6 [\#987](https://github.com/test-kitchen/test-kitchen/issues/987)
- Windows 2012R2 Chef Client MD5 checksum mismatch [\#986](https://github.com/test-kitchen/test-kitchen/issues/986)
- chef\_metadata\_url is ignored [\#985](https://github.com/test-kitchen/test-kitchen/issues/985)
- No live threads left. Deadlock? \(fatal\) [\#978](https://github.com/test-kitchen/test-kitchen/issues/978)
- Ohai::Config\[:log\_level\] deprecated [\#974](https://github.com/test-kitchen/test-kitchen/issues/974)
- Advanced support for chef\_metadata\_url to override chef omnibus installation [\#965](https://github.com/test-kitchen/test-kitchen/issues/965)
- Installing busser-serverspec fails with chefdk on windows [\#964](https://github.com/test-kitchen/test-kitchen/issues/964)
- WinRM: dna.json is not updated on target machine during kitchen converge unless deleted [\#957](https://github.com/test-kitchen/test-kitchen/issues/957)
- Instance not treated as Windows unless Vagrant box starts with 'win' [\#949](https://github.com/test-kitchen/test-kitchen/issues/949)
- Setting Proxy Env Variable to "" [\#934](https://github.com/test-kitchen/test-kitchen/issues/934)
- Chef client output isn't complete [\#685](https://github.com/test-kitchen/test-kitchen/issues/685)
- vagrant-wrapper issues with `kitchen test` [\#575](https://github.com/test-kitchen/test-kitchen/issues/575)
- Support SOCKS proxy for post 'kitchen create' connectivity test [\#460](https://github.com/test-kitchen/test-kitchen/issues/460)
- $HOME not set correctly during verify [\#321](https://github.com/test-kitchen/test-kitchen/issues/321)

**Merged pull requests:**

- release 1.7.0 [\#989](https://github.com/test-kitchen/test-kitchen/pull/989) ([mwrock](https://github.com/mwrock))
- Travis and Appveyor should do actual kitchen create/converge/verify against PRs [\#980](https://github.com/test-kitchen/test-kitchen/pull/980) ([mwrock](https://github.com/mwrock))
- Use latest mixlib-install 1.0.2 [\#976](https://github.com/test-kitchen/test-kitchen/pull/976) ([mwrock](https://github.com/mwrock))
- Nominate Seth Thomas as lieutenant of Test Kitchen [\#975](https://github.com/test-kitchen/test-kitchen/pull/975) ([tyler-ball](https://github.com/tyler-ball))
- Updating example versions [\#970](https://github.com/test-kitchen/test-kitchen/pull/970) ([cheeseplus](https://github.com/cheeseplus))
- Fix rake dep to ~\> 10, since rubocop fails on 11 [\#966](https://github.com/test-kitchen/test-kitchen/pull/966) ([jkeiser](https://github.com/jkeiser))
- Create template for github issues [\#963](https://github.com/test-kitchen/test-kitchen/pull/963) ([smurawski](https://github.com/smurawski))
- update changelog for 1.6 release [\#958](https://github.com/test-kitchen/test-kitchen/pull/958) ([chris-rock](https://github.com/chris-rock))
- Stop log\_level being copied from base config into provisioner config [\#950](https://github.com/test-kitchen/test-kitchen/pull/950) ([drrk](https://github.com/drrk))

## [v1.6.0](https://github.com/test-kitchen/test-kitchen/tree/v1.6.0) (2016-02-29)

[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v1.5.0...v1.6.0)

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
- Uploading large files with WinRM [\#851](https://github.com/test-kitchen/test-kitchen/issues/851)
- Chef Omnibus Windows Issues \(mixlib-install \#22 related\) [\#847](https://github.com/test-kitchen/test-kitchen/issues/847)
- Invoking Rake tasks with concurrency? [\#799](https://github.com/test-kitchen/test-kitchen/issues/799)
- msiexec was not successful [\#742](https://github.com/test-kitchen/test-kitchen/issues/742)
- not able to force chef-client in local model even my .kitchen.yml said so. [\#739](https://github.com/test-kitchen/test-kitchen/issues/739)
- TK attempts to download install.sh every converge [\#714](https://github.com/test-kitchen/test-kitchen/issues/714)
- Publicly expose winrm session [\#670](https://github.com/test-kitchen/test-kitchen/issues/670)
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
- Support ChefDK [\#443](https://github.com/test-kitchen/test-kitchen/issues/443)
- Message: Failed to complete \#converge action: \[Permission denied [\#441](https://github.com/test-kitchen/test-kitchen/issues/441)
- Idea: enable chef-zero to run on another server than the converged node. [\#437](https://github.com/test-kitchen/test-kitchen/issues/437)
- Test Artifact Fetch Feature [\#434](https://github.com/test-kitchen/test-kitchen/issues/434)
- Loading installed gem dependencies with busser plugins [\#406](https://github.com/test-kitchen/test-kitchen/issues/406)
- Wrap mkdir in sudo\(\) for init\_command of chef\_base provisioner? [\#382](https://github.com/test-kitchen/test-kitchen/issues/382)
- Unable to override `test\_base\_path` in test-kitchen v1.2.1 [\#377](https://github.com/test-kitchen/test-kitchen/issues/377)
- Busser depends on Ruby \(ChefDK\) being available on target VM [\#347](https://github.com/test-kitchen/test-kitchen/issues/347)
- Option to turn off ssh forwarding x11? [\#338](https://github.com/test-kitchen/test-kitchen/issues/338)
- Remove dependency on mixlib-shellout. Ruby 1.9 has what we need. [\#148](https://github.com/test-kitchen/test-kitchen/issues/148)

**Merged pull requests:**

- Update release process to use github changelog generator [\#952](https://github.com/test-kitchen/test-kitchen/pull/952) ([jkeiser](https://github.com/jkeiser))
- allow non-busser verifier to work with legacy drivers [\#944](https://github.com/test-kitchen/test-kitchen/pull/944) ([chris-rock](https://github.com/chris-rock))
- The Net::SSH::Extensions were overwriting IO.select aggressively, so we scaled this down some [\#935](https://github.com/test-kitchen/test-kitchen/pull/935) ([tyler-ball](https://github.com/tyler-ball))
- use winrm transport as alternative detection method [\#928](https://github.com/test-kitchen/test-kitchen/pull/928) ([chris-rock](https://github.com/chris-rock))
- bypass execution policy when running powershell script files [\#925](https://github.com/test-kitchen/test-kitchen/pull/925) ([mwrock](https://github.com/mwrock))
- Make chef-config an optional dependency. [\#924](https://github.com/test-kitchen/test-kitchen/pull/924) ([coderanger](https://github.com/coderanger))
- Deprecating winrm-transport and winrm-s gems [\#902](https://github.com/test-kitchen/test-kitchen/pull/902) ([mwrock](https://github.com/mwrock))
- Add Provisioner chef\_apply [\#623](https://github.com/test-kitchen/test-kitchen/pull/623) ([sawanoboly](https://github.com/sawanoboly))

## [v1.5.0](https://github.com/test-kitchen/test-kitchen/tree/v1.5.0) (2016-01-21)

[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v1.5.0.rc.1...v1.5.0)

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
- Cluster support with Kitchen [\#905](https://github.com/test-kitchen/test-kitchen/issues/905)
- kitchen driver help message incorrect [\#903](https://github.com/test-kitchen/test-kitchen/issues/903)
- No arg for -v option \(install.sh missing version number\) [\#900](https://github.com/test-kitchen/test-kitchen/issues/900)
- n help converge [\#890](https://github.com/test-kitchen/test-kitchen/issues/890)
- Chef Zero should be the default provisioner with init [\#889](https://github.com/test-kitchen/test-kitchen/issues/889)
- Windows tests broken - mkdir -p [\#886](https://github.com/test-kitchen/test-kitchen/issues/886)
- toggling attributes in kitchen.yml [\#884](https://github.com/test-kitchen/test-kitchen/issues/884)
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
- windows\_feature \(and other not working with test kitchen base box  [\#655](https://github.com/test-kitchen/test-kitchen/issues/655)
- Possibility to lock down versions of gems [\#515](https://github.com/test-kitchen/test-kitchen/issues/515)
- Missing vagrant-wrapper gem, update test-kitchen gem dependencies? [\#488](https://github.com/test-kitchen/test-kitchen/issues/488)
- : Message: SSH exited \(1\) for command: \[sh -c 'BUSSER\_ROOT="/tmp/busser" GEM\_HOME="/tmp/busser/gems" GEM\_PATH="/tmp/busser/gems" GEM\_CACHE="/tmp/busser/gems/cache" ; export BUSSER\_ROOT GEM\_HOME GEM\_PATH GEM\_CACHE; sudo -E /tmp/busser/bin/busser test'\] [\#411](https://github.com/test-kitchen/test-kitchen/issues/411)
- TestKitchen isn't using VAGRANT\_HOME path [\#398](https://github.com/test-kitchen/test-kitchen/issues/398)
- deal with travis [\#369](https://github.com/test-kitchen/test-kitchen/issues/369)
- use a default path rubygems, ruby and busser [\#362](https://github.com/test-kitchen/test-kitchen/issues/362)
- shell provisioner: Add a KITCHEN\_DIR environment variable [\#349](https://github.com/test-kitchen/test-kitchen/issues/349)
- Don't use generic descriptions for create, converge, setup, verify, and destroy [\#344](https://github.com/test-kitchen/test-kitchen/issues/344)
- Exception Handler does not always print out anything to stdout [\#281](https://github.com/test-kitchen/test-kitchen/issues/281)
- `kitchen converge` uses different PATH than `vagrant provision` [\#279](https://github.com/test-kitchen/test-kitchen/issues/279)
- Allow for "double-converges" on specific test suites [\#162](https://github.com/test-kitchen/test-kitchen/issues/162)

**Merged pull requests:**

- 150 release prep [\#921](https://github.com/test-kitchen/test-kitchen/pull/921) ([tyler-ball](https://github.com/tyler-ball))
- Because net/ssh is no longer including timeout.rb, we need to so that Ruby doesn't think Timeout belongs to the TK class [\#919](https://github.com/test-kitchen/test-kitchen/pull/919) ([tyler-ball](https://github.com/tyler-ball))
- Diet travis [\#911](https://github.com/test-kitchen/test-kitchen/pull/911) ([cheeseplus](https://github.com/cheeseplus))
- Revert "fix driver help output" [\#910](https://github.com/test-kitchen/test-kitchen/pull/910) ([cheeseplus](https://github.com/cheeseplus))
- Updating to the latest release of net-ssh to consume <https://github.com/net-ssh/net-ssh/pull/280> [\#908](https://github.com/test-kitchen/test-kitchen/pull/908) ([tyler-ball](https://github.com/tyler-ball))
- Set version to 1.5.0 [\#907](https://github.com/test-kitchen/test-kitchen/pull/907) ([jkeiser](https://github.com/jkeiser))
- Adding Maintainers file [\#906](https://github.com/test-kitchen/test-kitchen/pull/906) ([cheeseplus](https://github.com/cheeseplus))
- fix driver help output [\#904](https://github.com/test-kitchen/test-kitchen/pull/904) ([akissa](https://github.com/akissa))
- Add support for --profile-ruby [\#901](https://github.com/test-kitchen/test-kitchen/pull/901) ([martinb3](https://github.com/martinb3))
- fix chef install on non-windows [\#899](https://github.com/test-kitchen/test-kitchen/pull/899) ([mwrock](https://github.com/mwrock))
- typo: on != no [\#897](https://github.com/test-kitchen/test-kitchen/pull/897) ([miketheman](https://github.com/miketheman))
- Added try/catch around main and set error action to stop [\#872](https://github.com/test-kitchen/test-kitchen/pull/872) ([mcallb](https://github.com/mcallb))
- Fix Windows Omnibus Install \#811 [\#864](https://github.com/test-kitchen/test-kitchen/pull/864) ([dissonanz](https://github.com/dissonanz))
- add cli option to set the test path [\#857](https://github.com/test-kitchen/test-kitchen/pull/857) ([chris-rock](https://github.com/chris-rock))
- WinRM connect \(with retry\) is failing on Windows [\#835](https://github.com/test-kitchen/test-kitchen/pull/835) ([Stift](https://github.com/Stift))
- update omnibus url to chef.io [\#827](https://github.com/test-kitchen/test-kitchen/pull/827) ([andrewelizondo](https://github.com/andrewelizondo))
- Add hooks for instance cleanup before exit. [\#825](https://github.com/test-kitchen/test-kitchen/pull/825) ([coderanger](https://github.com/coderanger))
- Add more options for WinRM [\#776](https://github.com/test-kitchen/test-kitchen/pull/776) ([smurawski](https://github.com/smurawski))
- add tests for empty or missing files [\#753](https://github.com/test-kitchen/test-kitchen/pull/753) ([miketheman](https://github.com/miketheman))

## [v1.5.0.rc.1](https://github.com/test-kitchen/test-kitchen/tree/v1.5.0.rc.1) (2015-12-29)

[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v1.4.2...v1.5.0.rc.1)

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
- Drop Ruby 1.9 support [\#806](https://github.com/test-kitchen/test-kitchen/issues/806)
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
- fixed SuSe OS busser install [\#816](https://github.com/test-kitchen/test-kitchen/pull/816) ([Peuserik](https://github.com/Peuserik))
- Honor proxy env vars. [\#813](https://github.com/test-kitchen/test-kitchen/pull/813) ([mcquin](https://github.com/mcquin))
- Drop Ruby 1.9.3 from TravisCI build matrix [\#804](https://github.com/test-kitchen/test-kitchen/pull/804) ([thommay](https://github.com/thommay))
- Use mixlib-install [\#782](https://github.com/test-kitchen/test-kitchen/pull/782) ([thommay](https://github.com/thommay))

## [v1.4.2](https://github.com/test-kitchen/test-kitchen/tree/v1.4.2) (2015-08-03)

[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v1.4.1...v1.4.2)

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
- server.rb:283:in `block in start\_background': undefined method`start' for nil:NilClass \(NoMethodError\) [\#710](https://github.com/test-kitchen/test-kitchen/issues/710)
- Windows guests cannot use Gemfile with serverspec tests [\#616](https://github.com/test-kitchen/test-kitchen/issues/616)
- ssl\_ca\_path cannot be set in kitchen client.rb [\#594](https://github.com/test-kitchen/test-kitchen/issues/594)
- Test kitchen setup fails during busser serverspec plugin post install [\#461](https://github.com/test-kitchen/test-kitchen/issues/461)

**Merged pull requests:**

- Support specifying exact nightly/build [\#788](https://github.com/test-kitchen/test-kitchen/pull/788) ([jaym](https://github.com/jaym))
- silence some aruba warnings [\#770](https://github.com/test-kitchen/test-kitchen/pull/770) ([thommay](https://github.com/thommay))
- Fix monkey patching of IO.read [\#768](https://github.com/test-kitchen/test-kitchen/pull/768) ([375gnu](https://github.com/375gnu))
- Style/Lint Updates \(finstyle 1.5.0\) [\#762](https://github.com/test-kitchen/test-kitchen/pull/762) ([fnichol](https://github.com/fnichol))
- Adding appveyor config [\#689](https://github.com/test-kitchen/test-kitchen/pull/689) ([tyler-ball](https://github.com/tyler-ball))

## [v1.4.1](https://github.com/test-kitchen/test-kitchen/tree/v1.4.1) (2015-06-18)

[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v0.9.1...v1.4.1)

**Fixed bugs:**

- Discovering more than 50 drivers fails a Cucumber scenario [\#733](https://github.com/test-kitchen/test-kitchen/issues/733)
- Transport defaults windows username to ./administrator [\#688](https://github.com/test-kitchen/test-kitchen/issues/688)
- Fixing issues to support windows in kitchen-ec2, fixes \#688, fixes \#733 [\#736](https://github.com/test-kitchen/test-kitchen/pull/736) ([tyler-ball](https://github.com/tyler-ball))
- Fix failing feature in `kitchen drvier discover` due to too many gems. [\#734](https://github.com/test-kitchen/test-kitchen/pull/734) ([fnichol](https://github.com/fnichol))

**Closed issues:**

- SSH race condition with RHEL/CentOS instances in EC2 [\#735](https://github.com/test-kitchen/test-kitchen/issues/735)
- 'kitchen init' should create a chefignore file [\#732](https://github.com/test-kitchen/test-kitchen/issues/732)
- Nested upload folders [\#725](https://github.com/test-kitchen/test-kitchen/issues/725)
- Intermittent "No such file or directory" on Windows converge [\#699](https://github.com/test-kitchen/test-kitchen/issues/699)
- "kitchen verify" output on windows is getting butchered [\#486](https://github.com/test-kitchen/test-kitchen/issues/486)

**Merged pull requests:**

- Updating CHANGELOG and version for 1.4.1 release [\#748](https://github.com/test-kitchen/test-kitchen/pull/748) ([tyler-ball](https://github.com/tyler-ball))
- generate a chefignore during init, fixes \#732 [\#737](https://github.com/test-kitchen/test-kitchen/pull/737) ([metadave](https://github.com/metadave))
- Revert "Use a relative name for the connection class." [\#731](https://github.com/test-kitchen/test-kitchen/pull/731) ([metadave](https://github.com/metadave))
- Use a relative name for the connection class. [\#726](https://github.com/test-kitchen/test-kitchen/pull/726) ([coderanger](https://github.com/coderanger))

## [v0.9.1](https://github.com/test-kitchen/test-kitchen/tree/v0.9.1) (2015-05-21)

[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v0.9.0...v0.9.1)

**Closed issues:**

- kitchen exec fails to show text content without linebreak [\#717](https://github.com/test-kitchen/test-kitchen/issues/717)
- How to copy files from box to host machine? [\#716](https://github.com/test-kitchen/test-kitchen/issues/716)

## [v0.9.0](https://github.com/test-kitchen/test-kitchen/tree/v0.9.0) (2015-05-19)

[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v1.4.0...v0.9.0)

**Fixed bugs:**

- default-centos-64 is not available [\#707](https://github.com/test-kitchen/test-kitchen/issues/707)

**Closed issues:**

- Exception on kitchen create: Windows Server 2012 R2 box [\#696](https://github.com/test-kitchen/test-kitchen/issues/696)
- Unable to run kitchen converge: Server 2012 R2 - WinRM [\#695](https://github.com/test-kitchen/test-kitchen/issues/695)
- Windows guest doesn't update serverspec files [\#693](https://github.com/test-kitchen/test-kitchen/issues/693)
- platform centos-6.4, centos-6.5 cannot be downloaded [\#663](https://github.com/test-kitchen/test-kitchen/issues/663)
- Busser sync is a bit slow [\#639](https://github.com/test-kitchen/test-kitchen/issues/639)
- client key is invalid or not found at: 'C:/chef/client.pem' [\#636](https://github.com/test-kitchen/test-kitchen/issues/636)
- Don't print extraneous equals signs to logs "================" [\#586](https://github.com/test-kitchen/test-kitchen/issues/586)

**Merged pull requests:**

- Update platform version defaults in `kitchen init` command. [\#711](https://github.com/test-kitchen/test-kitchen/pull/711) ([fnichol](https://github.com/fnichol))
- don't prompt for passwords when using public keys [\#704](https://github.com/test-kitchen/test-kitchen/pull/704) ([caboteria](https://github.com/caboteria))
- Bump to centos-6.6, fix \#663. [\#665](https://github.com/test-kitchen/test-kitchen/pull/665) ([lloydde](https://github.com/lloydde))

## [v1.4.0](https://github.com/test-kitchen/test-kitchen/tree/v1.4.0) (2015-04-28)

[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v1.4.0.rc.1...v1.4.0)

**Fixed bugs:**

- kitchen verify not updating tests on Windows guests [\#684](https://github.com/test-kitchen/test-kitchen/issues/684)

**Closed issues:**

- includes and excludes directives not working in 1.4.0.rc.1 [\#690](https://github.com/test-kitchen/test-kitchen/issues/690)
- avoid forwarding port 22 if a Windows guest? [\#676](https://github.com/test-kitchen/test-kitchen/issues/676)
- kitchen verify fails on opscode centos-6.6 vagrant box [\#664](https://github.com/test-kitchen/test-kitchen/issues/664)
- test-kitchen/lib/kitchen/provisioner/chef/powershell\_shell.rb expand\_version fails if behind proxy and http\_proxy is set [\#638](https://github.com/test-kitchen/test-kitchen/issues/638)
- kitchen hangs on converge [\#624](https://github.com/test-kitchen/test-kitchen/issues/624)
- help info for "kitchen driver incorrect" [\#613](https://github.com/test-kitchen/test-kitchen/issues/613)
- Detect and warn users about PowerShell bug KB2842230 that causes Out of Memory Errors [\#604](https://github.com/test-kitchen/test-kitchen/issues/604)
- Need solution/best practice for installing gem in VM chef-client [\#495](https://github.com/test-kitchen/test-kitchen/issues/495)
- Multi-project chaining of shared CLI subcommands [\#47](https://github.com/test-kitchen/test-kitchen/issues/47)
- Create kitchen driver for Razor [\#45](https://github.com/test-kitchen/test-kitchen/issues/45)
- Add Multi-provisioner support [\#36](https://github.com/test-kitchen/test-kitchen/issues/36)

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
- Chef DownloadFile fails on PowerShell 2.0/win 2003 [\#631](https://github.com/test-kitchen/test-kitchen/issues/631)
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
- Fixing bad default setting - if ENV is not set we are accidentally setting log\_level to nil for whole run [\#633](https://github.com/test-kitchen/test-kitchen/pull/633) ([tyler-ball](https://github.com/tyler-ball))
- Fixes Chef Client installation on Windows Guests [\#615](https://github.com/test-kitchen/test-kitchen/pull/615) ([robcoward](https://github.com/robcoward))
- Pinning winrm to newer version to support latest httpclient [\#612](https://github.com/test-kitchen/test-kitchen/pull/612) ([tyler-ball](https://github.com/tyler-ball))
- Windows2003 guest fix [\#610](https://github.com/test-kitchen/test-kitchen/pull/610) ([GolubevV](https://github.com/GolubevV))
- Proxy Implementation for Windows Chef Omnibus [\#603](https://github.com/test-kitchen/test-kitchen/pull/603) ([afiune](https://github.com/afiune))
- Adding --log-overwrite CLI option [\#600](https://github.com/test-kitchen/test-kitchen/pull/600) ([tyler-ball](https://github.com/tyler-ball))
- PowerShell no longer re-installs chef if version constraint is only major version [\#590](https://github.com/test-kitchen/test-kitchen/pull/590) ([tyler-ball](https://github.com/tyler-ball))
- Check the exit code of msiexec [\#589](https://github.com/test-kitchen/test-kitchen/pull/589) ([jaym](https://github.com/jaym))
- Change getchef.com chef.io in PowerShell provisioner [\#588](https://github.com/test-kitchen/test-kitchen/pull/588) ([jaym](https://github.com/jaym))
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
- <http://kitchen.ci> is down [\#551](https://github.com/test-kitchen/test-kitchen/issues/551)
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
- undefined method `full\_name' for nil:NilClass \(NoMethodError       \) [\#445](https://github.com/test-kitchen/test-kitchen/issues/445)
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
- \[undefined method `each' for nil:NilClass\] [\#395](https://github.com/test-kitchen/test-kitchen/issues/395)
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
- Message: SSH exited \(1\) for command: \[sudo -E /tmp/kitchen/bootstrap.sh\] [\#342](https://github.com/test-kitchen/test-kitchen/issues/342)
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
- Metadata should be compiled \(and favored\) [\#319](https://github.com/test-kitchen/test-kitchen/issues/319)
- Can't load data bags [\#317](https://github.com/test-kitchen/test-kitchen/issues/317)
- Kitchen doesn't cache chef packages during vm provision [\#315](https://github.com/test-kitchen/test-kitchen/issues/315)
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
- Have access to node attributes in tests [\#174](https://github.com/test-kitchen/test-kitchen/issues/174)
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
- Suites should be able to exclude a platform \#29 [\#57](https://github.com/test-kitchen/test-kitchen/pull/57) ([scoop206](https://github.com/scoop206))
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

[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/0.5.0...v0.5.2)

## [0.5.0](https://github.com/test-kitchen/test-kitchen/tree/0.5.0) (2012-08-16)

[Full Changelog](https://github.com/test-kitchen/test-kitchen/compare/v0.5.0...0.5.0)

## [v0.5.0](https://github.com/test-kitchen/test-kitchen/tree/v0.5.0) (2012-08-16)

\* *This Change Log was automatically generated by [github_changelog_generator](https://github.com/skywinder/Github-Changelog-Generator)*
