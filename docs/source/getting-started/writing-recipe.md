---
title: "Writing a Recipe"
prev:
  text: "Creating a Cookbook"
  url: "creating-cookbook"
next:
  text: "Running Kitchen Converge"
  url: "running-converge"
---

Here we go, time to automate our Git installation! Open `recipes/default.rb` in your editor of choice and write the following:

~~~ruby
package "git"

log "Well, that was too easy"
~~~

Hrm. That was a bit too easy. Let's put our code to the test right away!
