---
title: Adding a New Feature
slug: adding-feature
menu:
  docs:
    parent: getting_started
    weight: 130
---

##### Adding a Feature

Now we're going to add limited support to our Git cookbook for a read-only Git daemon. This will walk us through adding a new suite, recipe, and corresponding set of tests.


> **We're not looking to make the perfect Chef cookbook in this guide. There will be more than a couple style and code smells as we go but this is to keep us focused on driving our tool. Think of it as a dirty first-pass implementation. Plenty of room for refactoring! state.**


It seems like the reasonable thing to do would be to create another recipe in our Chef cookbook to deal with the Git server. After all, not every server that requires the Git tool needs to be a server. We are adding net-new behavior that needs to operate independently of the default recipe. So it's natural that we want to test these two behaviors in isolation.

> **Testing different behaviors of a codebase in isolation is the primary use case for Kitchen Suites.**

Now that we have a feel for developing a Chef cookbook with Kitchen let's up the ante and add this feature test-first. That is, let's determine the acceptance criteria for a simple Git daemon and encode this as an executable test.

After consulting the web and the man page for `git-daemon`, two simple acceptance criteria emerge:

* A process is listening on port `9418` (the default Git daemon port).
* A service is running called `git-daemon`. This name is arbitrary but shouldn't surprise anyone using this cookbook.

Let's work through this step by step.

<div class="sidebar--footer">
<a class="button primary-cta" href="/docs/getting-started/adding-suite">Next - Adding a Suite</a>
<a class="sidebar--footer--back" href="/docs/getting-started/adding-platform">Back to previous step</a>
</div>
