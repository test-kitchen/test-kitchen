---
title: "Installing Test Kitchen"
next:
  text: "Getting Help"
  url: "getting-help"
---

Okay let's get down to it, shall we? Test Kitchen is packaged and delivered to you as a [RubyGem](http://guides.rubygems.org/what-is-a-gem/). If you've used Chef, Puppet, or Rails before then working with Gems shouldn't present a huge challenge. If all this Ruby "stuff" is new, then don't despair--we're going to steer clear of a lot of Ruby-looking code.

To follow this guide there is some software that we will need in order for Test Kitchen to do its thing:

* A Ruby distribution - version 1.9 and higher
* Git - oh yes, we're going to be commiting code
* Vagrant - a great tool to help manage development virtual machines
* VirtualBox - a virtualization tool that let's you run virtual machines locally

I know, it sounds like a lot of work but fear not. It's not overly tricky to get going, and the folks over at the [#learnchef](https://learnchef.opscode.com/) website have a handy [Workstation Setup](https://learnchef.opscode.com/quickstart/workstation-setup/) that we can follow to get us started. Take a few minutes to get your software setup and if you run into any issues there should be some smart and capable people in the [#learnchef](http://webchat.freenode.net/?channel=learnchef) IRC chatroom to get you back on track.


> **All done? Great! Open a terminal window and let's get started.**

Installing Test Kitchen from RubyGems goes like this:

~~~
$ gem install test-kitchen
Successfully installed mixlib-shellout-1.2.0
Fetching: net-ssh-2.7.0.gem (100%)
Successfully installed net-ssh-2.7.0
Fetching: net-scp-1.1.2.gem (100%)
Successfully installed net-scp-1.1.2
Fetching: safe_yaml-0.9.7.gem (100%)
Successfully installed safe_yaml-0.9.7
Fetching: thor-0.18.1.gem (100%)
Successfully installed thor-0.18.1
Fetching: test-kitchen-1.0.0.gem (100%)
Successfully installed test-kitchen-1.0.0
6 gems installed
~~~

Now if the version of Test Kitchen is important to you, then you can add a `-v <version_string>` to the end of the `gem install` command. Alternatively if you prefer living on the edge, adding a `--pre` to the install command will give you the latest alpha/beta/release candiate release. Note that these releases may not be as stable but your courage and feedback is greatly appreciated.

|| Pro-Tip
|| If you are familiar with and use [Bundler](http://bundler.io) then you can safely add `gem "test-kitchen"` to your project's **Gemfile**. Just don't forget to `bundle install`.

Now let's verify that Test Kitchen is installed. To save on typing, the tool's main command is `kitchen`. So to get the currently installed version we type:

~~~
$ kitchen version
Test Kitchen version 1.0.0
~~~
