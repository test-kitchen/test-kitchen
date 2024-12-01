---
title: "Creating a Cookbook"
slug: creating-cookbook
menu:
  docs:
    parent: getting_started
    weight: 30
---

In order to keep our example as simple as possible let's create a Chef Infra cookbook to automate the installation and management of the [Git](https://git-scm.com/) distributed version control tool. It's true that there is already a very capable [Git cookbook](https://supermarket.chef.io/cookbooks/git) available on the [Chef Supermarket](https://supermarket.chef.io/cookbooks) but this simple example will us to show all the features of Test Kitchen in a workflow.

First of all, let's generate a cookbook skeleton.

```ruby
$ chef generate cookbook git_cookbook
Generating cookbook git_cookbook
- Ensuring correct cookbook content
- Committing cookbook files to git

Your cookbook is ready. Type `cd git_cookbook` to enter it.

There are several commands you can run to get started locally developing and testing your cookbook.
Type `delivery local --help` to see a full list of local testing commands.

Why not start by writing an InSpec test? Tests for the default recipe are stored at:

test/integration/default/default_test.rb

If you'd prefer to dive right in, the default recipe can be found at:

recipes/default.rb
```

**Congratulations. You've authored a Chef Infra cookbook.**

Make sure you've changed into the new cookbook directory via `cd git_cookbook`. Next we'll talk about what just happened and how Test Kitchen configuration works.

<div class="sidebar--footer">
<a class="button primary-cta" href="/docs/getting-started/kitchen-yml">Next - The kitchen.yml</a>
<a class="sidebar--footer--back" href="/docs/getting-started/getting-help">Back to previous step</a>
</div>
