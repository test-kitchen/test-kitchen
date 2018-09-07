---
title: kitchen verify
slug: running-verify
menu:
  docs:
    parent: getting_started
    weight: 100
---

##### kitchen verify

In order to execute our test, we use the command `kitchen verify`:

~~~
$ kitchen verify default-ubuntu-1604
-----> Starting Kitchen (v1.16.0)
Please report a bug if this causes problems.
-----> Verifying <default-ubuntu-1604>...
       Loaded tests from test/smoke/default

Profile: tests from test/smoke/default
Version: (not specified)
Target:  ssh://vagrant@127.0.0.1:2222


  System Package
     ✔  git should be installed

Test Summary: 1 successful, 0 failures, 0 skipped
       Finished verifying <default-ubuntu-1604> (0m0.77s).
-----> Kitchen is finished. (0m5.07s)
~~~

A few things of note from the output above:

* `Verifying <default-ubuntu-1604>` output corresponds to the start of the **Verify Action**
* `✔  git should be installed` is output from the InSpec test


<div class="callout">
<h3 class="callout--title">Pro Tip</h3>
If using a Bash shell, <code>echo $?</code> is will print the exit code of the last run shell command. This would show that the **kitchen verify** command exited cleanly with <code>0</code>.
</div>

Let's check the status of our instance again:

~~~
$ kitchen list
Instance             Driver   Provisioner  Verifier  Transport  Last Action  Last Error
default-ubuntu-1604  Vagrant  ChefZero     Inspec    Ssh        Verified     <None>
~~~

So what would a failing test look like? Let's see. Open `test/smoke/default/default_test.rb` and edit the test so that we're testing that git is _not_ installed:

~~~
describe package('git') do
  it { should_not be_installed }
end
~~~

And re-run the **verify** subcommand:

~~~
$ kitchen verify default-ubuntu-1604
-----> Starting Kitchen (v1.16.0)
-----> Verifying <default-ubuntu-1604>...
       Loaded tests from test/smoke/default

Profile: tests from test/smoke/default
Version: (not specified)
Target:  ssh://vagrant@127.0.0.1:2222


  System Package
     ∅  git should not be installed
     expected System Package git not to be installed

Test Summary: 0 successful, 1 failures, 0 skipped
>>>>>> ------Exception-------
>>>>>> Class: Kitchen::ActionFailed
>>>>>> Message: 1 actions failed.
>>>>>>     Verify failed on instance <default-ubuntu-1604>.  Please see .kitchen/logs/default-ubuntu-1604.log for more details
>>>>>> ----------------------
>>>>>> Please see .kitchen/logs/kitchen.log for more details
>>>>>> Also try running `kitchen diagnose --all` for configuration
>>>>>> ----------------------
~~~

Unsurprisingly, we get the message `∅  git should not be installed` and kitchen throws an Exception.

Let's revert our forced failure:

~~~
describe package('git') do
  it { should be_installed }
end
~~~

Then verify our revert:

~~~
-----> Starting Kitchen (v1.16.0)
-----> Verifying <default-ubuntu-1604>...
       Loaded tests from test/smoke/default

Profile: tests from test/smoke/default
Version: (not specified)
Target:  ssh://vagrant@127.0.0.1:2222


  System Package
     ✔  git should be installed

Test Summary: 1 successful, 0 failures, 0 skipped
       Finished verifying <default-ubuntu-1604> (0m0.24s).
-----> Kitchen is finished. (0m1.51s)
~~~

One of the advantages of `kitchen-inspec` is that the InSpec tests are executed from the host over the transport (SSH or WinRM) to the instance. No tests need to be uploaded to the instance itself.

<div class="sidebar--footer">
<a class="button primary-cta" href="/docs/getting-started/running-test">Next - kitchen test</a>
<a class="sidebar--footer--back" href="/docs/getting-started/writing-test">Back to previous step</a>
</div>
