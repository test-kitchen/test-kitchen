---
title: kitchen verify
slug: running-verify
menu:
  docs:
    parent: getting_started
    weight: 100
---

In order to execute our test, we use the command `kitchen verify`:

~~~
$ kitchen verify default-ubuntu-1604
-----> Starting Kitchen (v1.23.2)
-----> Setting up <default-ubuntu-1604>...
       Finished setting up <default-ubuntu-1604> (0m0.00s).
-----> Verifying <default-ubuntu-1604>...
       Loaded tests from {:path=>".Users.cheeseplus.focus.git_cookbook.test.integration.default"}

Profile: tests from {:path=>"/Users/cheeseplus/focus/git_cookbook/test/integration/default"} (tests from {:path=>".Users.cheeseplus.focus.git_cookbook.test.integration.default"})
Version: (not specified)
Target:  ssh://vagrant@127.0.0.1:2222

  System Package git
     ✔  should be installed

Test Summary: 1 successful, 0 failures, 0 skipped
       Finished verifying <default-ubuntu-1604> (0m0.28s).
-----> Kitchen is finished. (0m3.33s)
~~~

A few things of note from the output above:

* `Verifying <default-ubuntu-1604>` output corresponds to the start of the **Verify Action**
* `✔  git should be installed` is output from the InSpec test


<div class="callout">
<h3 class="callout--title">Pro Tip</h3>
If using a Bash-like shell, <code>echo $?</code> is will print the exit code of the last run shell command. This would show that the <code>kitchen verify</code> command exited cleanly with <code>0</code>.
</div>

Let's check the status of our instance again:

~~~
$ kitchen list
Instance             Driver   Provisioner  Verifier  Transport  Last Action  Last Error
default-ubuntu-1604  Vagrant  ChefZero     Inspec    Ssh        Verified     <None>
~~~

So what would a failing test look like? Let's see. Open `test/integration/default/default_test.rb` and edit the test so that we're testing that git is _not_ installed:

~~~
describe package('git') do
  it { should_not be_installed }
end
~~~

And re-run the **verify** subcommand:

~~~
$ kitchen verify default-ubuntu-1604
-----> Starting Kitchen (v1.23.2)
-----> Verifying <default-ubuntu-1604>...
       Loaded tests from {:path=>".Users.cheeseplus.focus.git_cookbook.test.integration.default"}

Profile: tests from {:path=>"/Users/cheeseplus/focus/git_cookbook/test/integration/default"} (tests from {:path=>".Users.cheeseplus.focus.git_cookbook.test.integration.default"})
Version: (not specified)
Target:  ssh://vagrant@127.0.0.1:2222

  System Package git
     ×  should not be installed
     expected System Package git not to be installed

Test Summary: 0 successful, 1 failure, 0 skipped
>>>>>> ------Exception-------
>>>>>> Class: Kitchen::ActionFailed
>>>>>> Message: 1 actions failed.
>>>>>>     Verify failed on instance <default-ubuntu-1604>.  Please see .kitchen/logs/default-ubuntu-1604.log for more details
>>>>>> ----------------------
>>>>>> Please see .kitchen/logs/kitchen.log for more details
>>>>>> Also try running `kitchen diagnose --all` for configuration
~~~

Unsurprisingly, we get the message `×  should not be installed` and kitchen throws an exception.

Let's revert our forced failure:

~~~
describe package('git') do
  it { should be_installed }
end
~~~

Then verify our revert:

~~~
$ kitchen verify default-ubuntu-1604
-----> Starting Kitchen (v1.23.2)
-----> Verifying <default-ubuntu-1604>...
       Loaded tests from {:path=>".Users.cheeseplus.focus.git_cookbook.test.integration.default"}

Profile: tests from {:path=>"/Users/cheeseplus/focus/git_cookbook/test/integration/default"} (tests from {:path=>".Users.cheeseplus.focus.git_cookbook.test.integration.default"})
Version: (not specified)
Target:  ssh://vagrant@127.0.0.1:2222

  System Package git
     ✔  should be installed

Test Summary: 1 successful, 0 failures, 0 skipped
       Finished verifying <default-ubuntu-1604> (0m0.32s).
-----> Kitchen is finished. (0m3.06s)
~~~

One of the advantages of `kitchen-inspec` is that the InSpec tests are executed from the host over the transport (SSH or WinRM) to the instance. No tests need to be uploaded to the instance itself.

<div class="sidebar--footer">
<a class="button primary-cta" href="/docs/getting-started/running-test">Next - kitchen test</a>
<a class="sidebar--footer--back" href="/docs/getting-started/writing-test">Back to previous step</a>
</div>
