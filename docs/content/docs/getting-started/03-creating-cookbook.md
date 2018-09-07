---
title: "Creating a Cookbook"
slug: creating-cookbook
menu:
  docs:
    parent: getting_started
    weight: 30
---

##### Creating a cookbook

In order to keep our example as simple as possible let's create a Chef cookbook to automate the installation and management of the [Git](http://git-scm.com/) distributed version control tool. It's true that there is already a very capable [Git cookbook](https://supermarket.chef.io/cookbooks/git) available on the [Chef Supermarket](https://supermarket.chef.io/cookbooks) but this simple example will us to show all the features of test-kitchen in a workflow.

First of all, let's generate a cookbook skeleton.

~~~
$ chef generate cookbook git_cookbook
Generating cookbook git_cookbook
- Ensuring correct cookbook file content
- Committing cookbook files to git
- Ensuring delivery configuration
- Ensuring correct delivery build cookbook content
- Adding delivery configuration to feature branch
- Adding build cookbook to feature branch
- Merging delivery content feature branch to master

Your cookbook is ready. Type `cd git_cookbook` to enter it.

There are several commands you can run to get started locally developing and testing your cookbook.
Type `delivery local --help` to see a full list.

Why not start by writing a test? Tests for the default recipe are stored at:

test/smoke/default/default_test.rb

If you'd prefer to dive right in, the default recipe can be found at:

recipes/default.rb
~~~

> **Congratulations. You've authored a Chef cookbook.**

Make sure you've changed into the new cookbook directory via `cd git_cookbook`. Next we'll talk about what just happened and how kitchen configuration works.

<div class="sidebar--footer">
<a class="button primary-cta" href="/docs/getting-started/kitchen-yml">Next - The .kitchen.yml</a>
<a class="sidebar--footer--back" href="/docs/getting-started/getting-help">Back to previous step</a>
</div>
