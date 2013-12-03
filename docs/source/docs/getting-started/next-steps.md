---
title: Next Steps
prev:
  text: "Backfilling Platforms"
  url: "backfilling-platforms"
---

This concludes the getting started guide for Test Kitchen. Hopefully you are now more comfortable with Test Kitchen's basic usage, fundamental concepts, and a feel for a testing workflow.

From here, there are a few resources that can help you along your infrastructure testing journey:

* Jump in the [#kitchenci](http://webchat.freenode.net/?channels=kitchenci) IRC channel on Freenode as a question
* Send a tweet to [@kitchenci](https://twitter.com/kitchenci) or follow the [#kitchenci](https://twitter.com/search?q=%23kitchenci&src=typd) Twitter hash tag
* Check out the Test Kitchen [core code](https://github.com/test-kitchen/test-kitchen) on GitHub
* Submit an [issue, feature, or pull request](https://github.com/test-kitchen/test-kitchen/issues) on the Issue tracker
* Search RubyGems.org for Test Kitchen [Drivers](https://rubygems.org/search?utf8=%E2%9C%93&query=kitchen-) or Busser [Runner Plugins](https://rubygems.org/search?utf8=%E2%9C%93&query=busser-)
* Write a blog post describing getting started with Test Kitchen, or an interesting problem Test Kitchen has allowed you to solve
* Take a look at the excellent O'Reilly book [Test-driven Infrastructure with Chef](http://shop.oreilly.com/product/0636920030973.do) 

One question that users often raise is: "How can I get Test Kitchen to test multiple machines?".  Usually this question really means: I want to test the interaction between machines, for example a webserver and a database.  It's important to understand that this is not the kind of testing that Test Kitchen was designed for.  Acceptance testing of infrastructure stacks is valueable, fascinating and difficult - for an approach which makes use of Test Kitchen as a library, see [Leibniz](http://leibniz.cc).

The rest of the documentation is a work in progress so bear with us. Better yet, if you've learned something and want to contribute, please **fork the docs**!
