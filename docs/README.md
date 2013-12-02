Documentation for KitchenCI.

## Overview

All documentation is written in [Markdown][markdown]. To preview the documentation in your browser run the following:

~~~ shell
bundle install
bundle exec middleman
~~~ 

Then go view the docs at [http://localhost:4567](http://localhost:4567) (which redirects to [http://localhost:4567/getting-started/](http://localhost:4567/getting-started/)). Edits to the documentation source files should cause the `middleman` server to reload so you can see your changes update live.

*NOTE:* _the middleman stuff was yanked from the (upcoming) http://kitchen.ci website middleman project. An attempt was made to strip any/all styling and theme sources, as well as removal of any references to commercial support offerings. If any of that was left over and it offends you, please feel free to remove it and submit a pull request._

## Hosting

All documentation will be hosted on the official Kitchen website (http://kitchen.ci), which is a static site built with [Middleman][middleman]. 

The important parts to familiarize yourself with for contributing to the KitchenCI documentation are the markdown renderer and syntax highlighting engines used to power http://kitchen.ci. 

Markdown rendering is handled by [kramdown][kramdown]. It would be worth your while to briefly review the kramdown documentation as there are some subtle differences (as well as a number of helpful extensions) that deviate from the Markdown standard. 

Syntax Highlighting is handled by [middleman-syntax][syntax], which uses [Rouge][rouge], which is a ruby-based syntax highlighting engine that is compatible with [Pygments][pygments] templates and supports things like "fenced code blocks" and language-specific syntax highlighting from Markdown. 

## Metadata

Each page also contains some YAML "frontmatter" that is used to compile the navigation menus (etc) on http://kitchen.ci. The only required metadata property is **title**.

~~~ yaml
---
title: "KitchenCI Overview"
--- 
~~~

In addition to these required properties, there are also some optional metadata properties which can be employed:

**User Guide / Next Steps**

Some portions of the documentation should be read like a guide, prompting you on to the next step in the process. So, when present the "next" property will cause a prompt to appear at the bottom of the documentation page on http://kitchen.ci to guide the reader to the next relevant topic. If this property is missing (or if the corresponding "url" + "text" properties are omitted), no such prompt will appear.

~~~ yaml
--- 
title: "KitchenCI Overview"
next:
  url: installing-kitchen
  text: "Installing KitchenCI"
---
~~~

**Banners**

Sometimes it is helpful to alert the reader to changes, warn them of common pitfalls, or make it known that _there be dragons_. Adding a `alert`, `warning`, or `danger` property to the frontmatter will cause a corresponding blue, yellow, or red banner to be displayed at the top of the content section of the documentation page on http://kitchen.ci. 

~~~ yaml
---
title: "KitchenCI Documentation"
alert: "Added in kitchen version 1.0.x"
---
~~~

## Style Guide

There are four elements that may be used for "styling" the docs content: in-line code highlighting, code blocks, blockquotes, and a special hack around markdown tables that we'll use for what we call "Pro-Tips". 

### In-line Code Highlighting

To highlight `some code` inline with other content, just "qoute" the text using backtick characters (`). See [the kramdown documentation](http://kramdown.gettalong.org/syntax.html#code-spans) for more details.

### Fenced Code Blocks

To highlight a block of code, start and finish the block with three or more tilde characters (`~`). To enable syntax-highlighting, just indicate the code language after the tildes on the first line. 

For example, this code: 

~~~~~~~
~~~yaml
---
title: "KitchenCI Overview"
next:
  url: installing-kitchen
  text: "Installing KitchenCI"
---
~~~
~~~~~~~

...will yield this output: 

~~~~yaml
---
title: "KitchenCI Overview"
next:
  url: installing-kitchen
  text: "Installing KitchenCI"
---
~~~~

See [the kramdown documentation](http://kramdown.gettalong.org/syntax.html#fenced-code-blocks) for more information.

### Blockquotes

To draw attention to some content with a blockquote, just start the line(s) with a `>` (right angle bracket / greater than symbol). See [the kramdown documentation](http://kramdown.gettalong.org/syntax.html#blockquotes) for more information. 

### Pro-Tips (Tables)

To draw attention to some content that may be a side-bar or advanced content, just start the line(s) with double pipe characters (`||`). For example: 

~~~
|| Pro-Tip
|| This is an advanced topic...
~~~

## License
The Kitchen Documentation is released under the [MIT license][mit-license].


[markdown]: http://daringfireball.net/projects/markdown/syntax
[kitchenci]: http://kitchen.ci
[middleman]: http://middlemanapp.com
[pages]: http://pages.github.com/
[kramdown]: http://kramdown.gettalong.org/
[syntax]: https://github.com/middleman/middleman-syntax
[rouge]: https://github.com/jayferd/rouge
[pygments]: http://pygments.org/
[mit-license]: MIT-LICENSE.txt

