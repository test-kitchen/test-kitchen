# Test Kitchen

# Quick Start

    gem install test-kitchen

    # create a new test kitchen project
    mkdir my-test-kitchen && cd my-test-kitchen
    kitchen init

    # install the dependencies
    bundle install --binstubs

# Running tests

    # create a test kitchen for the foo project
    bin/kitchen create --project foo

    # run tests against the test kitchen for the foo project
    bin/kitchen test --project foo

    # check the status of our test kitchen
    bin/kitchen status

    # ssh into the test instance for the ubuntu-10.04 platform
    bin/kitchen ssh --platform ubuntu-10.04

    # this is identical since ubuntu-10.04 is the default platform
    bin/kitchen ssh

    # destroy a single test instance in the kitchen
    bin/kitchen destroy --platform ubuntu-11.04

    # fully destroy your test kitchen
    bin/kitchen destroy

# Project Configuration

Projects are configured in the `config/projects.json` file.  Here is an example
project configuration:

    "foo": {
      "language": "ruby",
      "rvm": ["1.8.7","1.9.2"],
      "repository": "https://github.com/you/your-repo.git",
      "revision": "master",
      "test_command": "rspec spec"
    }

The following options can be used in a project configuration:

<table>
  <tr>
    <th>Option</th>
    <th>Description</th>
    <th>Valid values</th>
    <th>Default value</th>
  </tr>
  <tr>
    <td>repository</td>
    <td>URI to the project's underlying Git repository</td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td>repository</td>
    <td>Revision to checkout. can be symbolic, like "HEAD", a branch name or revision id</td>
    <td></td>
    <td>master</td>
  </tr>
  <tr>
    <td>language</td>
    <td>Programming language the project uses.</td>
    <td>ruby</td>
    <td></td>
  </tr>
  <tr>
    <td>rvm</td>
    <td>Ruby projects specify releases they need to be tested against using the `rvm` key.</td>
    <td>`1.8.7`, `1.9.2`, `1.9.3` </td>
    <td></td>
  </tr>
  <tr>
    <td>install</td>
    <td>Command used to install project dependencies</td>
    <td></td>
    <td>256 MB</td>
  </tr>
  <tr>
    <td>script</td>
    <td>Main command used to run tests.</td>
    <td></td>
    <td>rspec spec</td>
  </tr>
  <tr>
    <td>memory</td>
    <td>Amount of memory the underlying guest VM will require for testing.</td>
    <td></td>
    <td>256 MB</td>
  </tr>
</table>

You may have noticed Test Kitchen's `projects.json` file shares much in common
with [Travis CI's .travis.yml](http://about.travis-ci.org/docs/user/build-configuration/)
file. This is intentional, as Test Kitchen will eventually support loading/parsing
of `.travis.yml` files if they are present in a project's repository.
