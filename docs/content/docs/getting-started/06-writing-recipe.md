---
title: "Writing a Recipe"
slug: writing-recipe
menu:
  docs:
    parent: getting_started
    weight: 60
---

Here we go, time to automate our Git installation! Open `recipes/default.rb` in your editor of choice and add the following:

```ruby
package 'git'
```

Hrm. That was a bit too easy. Let's put our code to the test right away!

<div class="sidebar--footer">
<a class="button primary-cta" href="07-running-converge.md">Next - Running Kitchen Converge</a>
<a class="sidebar--footer--back" href="05-instances.md">Back to previous step</a>
</div>
