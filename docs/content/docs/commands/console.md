---
title: kitchen console
menu:
  docs:
    identifier: cmd-console
    parent: commands
    weight: 80
---

Starts an interactive Ruby console with your Test Kitchen configuration loaded. It is a tool for plugin authors and for debugging configuration that resists explanation by other means.

```bash
kitchen console
```

### What is available

The console exposes the loaded `Kitchen::Config` object, so you can inspect instances and their plugins directly:

```ruby
# every instance Test Kitchen knows about
@config.instances.map(&:name)

# one instance
instance = @config.instances.get("default-ubuntu-2204")

# the plugin objects for that instance
instance.driver
instance.provisioner
instance.transport
instance.verifier

# the computed diagnostic hash, the same data `kitchen diagnose` prints
instance.diagnose

# the driver's resolved configuration
instance.driver.diagnose
```

### When to use it

Most configuration questions are better answered by [`kitchen diagnose`](/docs/commands/diagnose), which prints the same information as YAML without requiring you to know the object model. Reach for the console when you need to go further than a static dump:

- you are writing a plugin and want to call its methods against real configuration
- you want to test how a driver responds to a particular state
- you are tracing why a configuration value resolves the way it does, one method call at a time

{{% info %}}
`kitchen console` is a debugging and development tool. Nothing about it is required for ordinary Test Kitchen use — if you are working through the [Getting Started guide](/docs/getting-started/00-introduction), you can safely ignore it.
{{% /info %}}
