---
title: ""
---

I'm a programmer working on Linux stuff,
distributed systems,
and compilers/runtimes.

## Uses

I run NixOS on all my computers and servers,
and prefer to use simple unixy workflows.

### Editors

I use Emacs as my text editor,
although its slowly taking over my workflow as I grow proficient.
Rather than use a premade distribution,
I decided early on to go vanilla and build a config myself.
Part of the reasoning was to get a better understanding of the core emacs philosophy before adding plugins,
the other part being that I didn't know what most plugins even did.

In the past I enjoyed using neovim but left to try out the emacs hype.
I didn't think they were too different until I tried using neovim again after ~6 months,
and immediately missed all the functionality from emacs,
maybe I'll elaborate in a post one day.
Sure, neovim is a lot more minimal as an editor,
but emacs aims to be a computing platorm with a text editor bolted on.
They are ultimately trying to do different things,
and lisp is just better than lua.

I've played around with Helix and Kakoune but haven't dedicated serious time yet.

## Meta

This site is built mostly using [zola](http://getzola.org),
with other projects built with nix sprinkled in afterwards.
The entire site is then generated as a nix derivation and served from there.
