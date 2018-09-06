Documentation for KitchenCI.

## Overview

To preview the documentation in your browser run the following:

~~~ shell
bundle install
bundle exec middleman server
~~~

While the Getting Started guide is written in primarily [Markdown][markdown] a few pages use [Slim](http://slim-lang.com/), an HTML templating engine for Ruby.

Then go view the docs at [http://localhost:4567](http://localhost:4567). Edits to the documentation source files should cause the `middleman` server to reload so you can see your changes update live.

## Hosting

All documentation will be hosted on the official Kitchen website (http://kitchen.ci), which is a static site built with [Middleman][middleman].

The important parts to familiarize yourself with for contributing to the KitchenCI documentation are the markdown renderer and syntax highlighting engines used to power http://kitchen.ci.

Markdown rendering is handled by [kramdown][kramdown]. It would be worth your while to briefly review the kramdown documentation as there are some subtle differences (as well as a number of helpful extensions) that deviate from the Markdown standard.

Syntax Highlighting is handled by [middleman-syntax][syntax], which uses [Rouge][rouge], which is a ruby-based syntax highlighting engine that is compatible with [Pygments][pygments] templates and supports things like "fenced code blocks" and language-specific syntax highlighting from Markdown.

## Style Guide

There are four elements that may be used for "styling" the docs content: in-line code highlighting, code blocks, blockquotes, and a special hack around markdown tables that we'll use for what we call "Pro-Tips".

### In-line Code Highlighting

To highlight `some code` inline with other content, just "quote" the text using backtick characters (`). See [the kramdown documentation](http://kramdown.gettalong.org/syntax.html#code-spans) for more details.

### Fenced Code Blocks

To highlight a block of code, start and finish the block with three or more tilde characters (`~`). To enable syntax-highlighting, just indicate the code language after the tildes on the first line.

For example, this code:

    ~~~yaml
    ---
    title: "KitchenCI Overview"
    next:
      url: installing-kitchen
      text: "Installing KitchenCI"
    ---
    ~~~

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
