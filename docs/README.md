# Documentation for Test Kitchen

The Getting Started guide is written in [Markdown](https://daringfireball.net/projects/markdown/) and rendered using [Hugo](https://gohugo.io).

## Hosting

All documentation will be hosted on the official Kitchen website <https://kitchen.ci/>, which is a static site stored in an S3 bucket and fronted by CloudFront.

## Running Locally

### Install Hugo

- On macOS run: `brew install hugo`
- On Windows run: `choco install hugo`
- On Ubuntu run: `apt install -y build-essential; snap install hugo --channel=extended`

### Run Hugo

Run `hugo serve` and browse the the URL presented

## Style Guide

There are four elements that may be used for "styling" the docs content: in-line code highlighting, code blocks, blockquotes, and a special hack around markdown tables that we'll use for what we call "Pro-Tips".

### In-line Code Highlighting

To highlight `some code` inline with other content, just "quote" the text using backtick characters (`).

### Fenced Code Blocks

To highlight a block of code, start and finish the block with three or more tilde characters (`~`). To enable syntax-highlighting, just indicate the code language after the tildes on the first line.

For example, this code:

```yaml
---
title: "KitchenCI Overview"
next:
  url: installing-kitchen
  text: "Installing KitchenCI"
---
```

...yields this output:

```yaml
---
title: "KitchenCI Overview"
next:
  url: installing-kitchen
  text: "Installing KitchenCI"
---
```

See [the kramdown documentation](https://kramdown.gettalong.org/syntax.html#fenced-code-blocks) for more information.

### Blockquotes

To draw attention to some content with a blockquote, just start the line(s) with a `>` (right angle bracket / greater than symbol). See [the kramdown documentation](https://kramdown.gettalong.org/syntax.html#blockquotes) for more information.

## License

The Kitchen Documentation is released under the [MIT license][mit-license].

[mit-license]: https://opensource.org/license/mit/
