Documentation for Test Kitchen.

The Getting Started guide is written in [Markdown](https://daringfireball.net/projects/markdown/) and rendored using [Hugo](https://gohugo.io).

To install Hugo run:

```
brew install hugo
```

## Hosting

All documentation will be hosted on the official Kitchen website (http://kitchen.ci), which is a static site stored in an S3 bucket and fronted by CloudFront.

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
