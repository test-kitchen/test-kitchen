---
title: "Manually Verifying"
slug: manually-verifying
menu:
  docs:
    parent: getting_started
    weight: 80
---



If you're a skeptical person then you might be asking:

> "How can we be sure that Git was actually installed?"

Let's verify this right now.

Kitchen has a **login** subcommand for just these kinds of situations:

~~~
Welcome to Ubuntu 16.04.2 LTS (GNU/Linux 4.4.0-75-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

0 packages can be updated.
0 updates are security updates.


Last login: Mon May 15 14:56:09 2017 from 10.0.2.2
vagrant@default-ubuntu-1604:~$
~~~

As you can see by the prompt above we are now in the `default-ubuntu-1604` instance. We'll denote the prompt in an instance with `# ` for clarity. Now to check if Git is installed:

~~~
# which git
/usr/bin/git
# git --version
git version 2.7.4
~~~

Rockin. Now we can exit out back to our workstation:

~~~
# exit
logout
Connection to 127.0.0.1 closed.
~~~

Feel free to use the **login** subcommand any time you have the urge to poke around, uninstall packages, turn off services, grep logs, etc. Go to town, this is a sandbox and isn't production after all.

<div class="sidebar--footer">
<a class="button primary-cta" href="/docs/getting-started/writing-test">Next - Writing a Test</a>
<a class="sidebar--footer--back" href="/docs/getting-started/running-converge">Back to previous step</a>
</div>
