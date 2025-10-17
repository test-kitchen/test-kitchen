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

```ruby
$ kitchen login
Welcome to Ubuntu 24.04 LTS (GNU/Linux 6.11.0-29-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

  System information as of Wed 2 Jul 2025 07:20:35 PM UTC

  System load:  0.01              Processes:             100
  Usage of /:   2.6% of 61.31GB   Users logged in:       0
  Memory usage: 16%               IPv4 address for eth0: 10.0.2.15
  Swap usage:   0%


0 updates can be installed immediately.
0 of these updates are security updates.


The list of available updates is more than a week old.
To check for new updates run: sudo apt update


This system is built by the Bento project by Chef Software
More information can be found at https://github.com/chef/bento
Last login: Wed Jul 2 19:17:07 2025 from 10.0.2.2
vagrant@default-ubuntu-2404:~$
```

As you can see by the prompt above we are now in the `default-ubuntu-2404` instance. We'll denote the prompt in an instance with `$` for clarity. Now to check if Git is installed:

```bash
$ which git
/usr/bin/git
$ git --version
git version 2.43.0
```

Rockin. Now we can exit out back to our workstation:

```bash
$ exit
logout
Connection to 127.0.0.1 closed.
```

Feel free to use the **login** subcommand any time you have the urge to poke around, uninstall packages, turn off services, grep logs, etc. Go to town, this is a sandbox and isn't production after all.

<div class="sidebar--footer">
<a class="button primary-cta" href="/docs/getting-started/writing-test">Next - Writing a Test</a>
<a class="sidebar--footer--back" href="/docs/getting-started/running-converge">Back to previous step</a>
</div>
