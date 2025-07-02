---
title: Adding a New Feature
slug: adding-feature
menu:
  docs:
    parent: getting_started
    weight: 130
---
In this section, we'll extend our Git cookbook to provide basic support for a read-only Git daemon. You'll learn how to add a new suite, create a dedicated recipe, and write targeted tests for this new functionality.

Our goal here isn't to craft a flawless Chef Infra cookbook. Instead, we'll focus on quickly iterating and validating our changes, even if that means introducing some stylistic or structural imperfections along the way. This "first draft" approach keeps us moving forward and leaves room for future improvements.

Since not every system that installs Git needs to run a Git server, it makes sense to isolate this new behavior in its own recipe. By doing so, we can test the Git daemon functionality independently from the default recipe, ensuring our changes are modular and maintainable.

**Testing different behaviors of a codebase in isolation is the primary use case for Test Kitchen Suites.**

Now that we have a feel for developing a Chef Infra cookbook with Test Kitchen let's up the ante and add this feature test-first. That is, let's determine the acceptance criteria for a simple Git daemon and encode this as an executable test.

After consulting the web and the man page for `git-daemon`, two simple acceptance criteria emerge:

* A process is listening on port `9418` (the default Git daemon port).
* A service is running called `git-daemon`. This name is arbitrary but shouldn't surprise anyone using this cookbook.

Let's work through this step by step.

<div class="sidebar--footer">
<a class="button primary-cta" href="/docs/getting-started/adding-suite">Next - Adding a Suite</a>
<a class="sidebar--footer--back" href="/docs/getting-started/adding-platform">Back to previous step</a>
</div>
