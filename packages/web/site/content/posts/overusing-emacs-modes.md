---
title: On editors and plugins
date: 2025-08-14
draft: true
---

The healthy package ecosystems that extensible editors have is a standout feature.

After setting up my first neovim package manager,
I never hesitated testdriving cool plugins from the community.
I installed a terminal plugin that without really having problems with `:term`,
or using a file manager without ever trying `:netrw`.
After a while, I found neovim overloaded with more features than I understood,
and frequently hit problems that encouraged yet another plugin to fix.
The issue wasn't that I had too many plugins per se,
it was that I didn't really understand what they did.
I promptly declared config bankruptcy.

Going forward I strictly used plugins that were worth their weight.
That is, how they affect performance as well as any cognitive slowdown.
I quickly found that when a plugin strays too far from core neovim,
like not hooking into builtin functionality or not reusing normal keybinds,
it wouldn't make the cut.
It is simply not worth learning if it doesn't enrich the editor as a whole.

Using this philosophy for a few years,
the only external plugins that survived were
LSP completion, a proper code formatter, and fzf for search.
Some plugins ended up in core neovim,
like language aware commenting and better compile commands.
Most were deleted.

This meant my editor was really good at editing text and code projects,
and not much more.
It was fine that it didn't have a UI for viewing GitHub stars or whatever.
I could live without

## Enter emacs
Modes reshape emacs to better fit certain work.
