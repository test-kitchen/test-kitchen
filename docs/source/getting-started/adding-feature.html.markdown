---
title: Adding a New Feature
---

Now we're going to add limited support to our Git cookbook for a read-only Git daemon. This lets us see two new concepts in action: working with multiple suites and managing cookbook dependencies.

<div class="well">
  <h4><span class="glyphicon glyphicon-pushpin"></span> Pro-Tip</h4>
  <p>We're not looking to make the perfect Chef cookbook in this guide. There will be more than a couple style and code smells as we go but this is to keep us focused on driving our tool. Think of it as a dirty first-pass implementation. Plenty of room for refactoring!</p>
</div>

It seems like the reasonable thing to do would be to create another recipe in our Chef cookbook to deal with the Git server. After all, not every server that requires the Git tool needs to be a server. We are adding net-new behavior that needs to operate independently of the default recipe. So it's natural that we want to test these two behaviors in isloation.

> **Testing different behaviors of a codebase in isloation is the primary use case for Test Kitchen Suites.**

Now that we have a feel for developing a Chef cookbook with Test Kitchen let's up the ante and add this feature test-first. That is, let's determine the acceptance criteria for a simple Git daemon and encode this as an executable test.

After consulting the web and the man page for `git-daemon`, two simple acceptance criteria emerge:

* A process is listening on port 9418 (the default Git daemon port).
* A service is running called `"git-daemon"`. This name is arbitrary but shouldn't surprise anyone using this cookbook.

Let's work through this step by step.
