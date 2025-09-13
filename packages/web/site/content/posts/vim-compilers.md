---
title: "Neovim's built-in compilers"
date: "2025-01-17"
---

Today I learned that neovim's `:make` comes with many
[backends](https://neovim.io/doc/user/quickfix.html#_6.-selecting-a-compiler)
already configured.
This works for checking c/cpp and python files, among other, but I was
most interested to see [Typst] and [Pandoc] listed as well.

I was looking to add this functionality with a plugin or implementing it
manually,
where a document can be compiled on the fly from the editor.
After setting `:compiler pandoc`,
generating a pdf is done with `:make pdf`,
with other pandoc options just appended afterwards if needed.

[typst]: https://typst.app
[pandoc]: https://github.com/jgm/pandoc
