---
title: "Introduction"
next:
  text: "Installing Test Kitchen"
  url: "installing"
---

## Welcome to Test Kitchen!

No, contrary to popular belief, this has nothing to do with the cooking show, or the video game, and everything to do with streamlining and automating the process of getting infrastructure code under test, and into continuous integration.  

## Why would we test infrastructure code?

Why would we want to do that?  Well, you test your application code, right?  You wouldn't think of putting a complex website into production without a test harness, would you?  Well increasingly web operations folk are using tools like Chef and Puppet to write infrastructure code that builds and maintains the platform that these complex applications sit upon.  This code - this infrastructure code - well, that needs to be tested too!  Test Kitchen makes this easy to do.

## Speeding up the QA cycle

At the dawn of time, the standard workflow for an engineer building a server was to follow a run book, or checklist, and build a machine ready for production.  After a couple of days, this would be passed to a QA engineer to verify that everything was in good shape.  The engineer would log onto the machine, check config files, run a variety of tests to make sure everything looked good, and then either pass the build or send it back for rework.

The introduction of configuration management or infrastructure automation tools decreased the time taken to build the machines, and increased the quality and repeatability of the process.  However, the testing cycle is still slow.

Test Kitchen takes the automation to the next level, and allows you to automate the testing process, to verify that your infrastructure code has done the right thing.  And more than that, it's designed specifically to make it easy to plug that testing process into your continuous integration workflow, so that as people collaborate on improving your infrastructure code, everyone gets rapid feedback on the impact of the work in progress.

## Getting Started

This is the quick start guide for Test Kitchen.  It doesn't assume any great familiarity with Chef or Ruby, and takes you through the process of writing a Chef cookbook, with automated testing as standard.  Once you've finished this guide you'll be in good shape to start writing more cookbooks, or contributing to others in the community.  Ready to dive in? Great, let's go!
