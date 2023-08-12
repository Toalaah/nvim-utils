# Nvim-Utils

[`nvim-utils`](https://github.com/toalaah/nvim-utils) is a collection of
utility functions and modules for managing Neovim configurations / plugins in
Nix. It aims to simplify the creation of reproducible, reusable, and extensible
configurations.

`nvim-utils` is module-based. Just like with [NixOS
modules](https://nixos.wiki/wiki/NixOS_modules), users may [create their own
modules](./usage.md) or use one of several
[prebuilt](./modules/builtins/README.md) ones to build up their configs,
depending on their needs.

The plugin backend used in `nvim-utils` is the wonderful
[lazy.nvim](https://github.com/folke/lazy.nvim). For one, this plugin manager
is extremely performant and allows for trivial implementation of lazy-loading,
resulting in snappy configs. Furthermore, the structure of `lazy.nvim`'s plugin
specs lends itself quite nicely to the module structure found within
`nvim-utils`.

Under the hood, each module corresponding to a plugin or component of a user's
config is simply transpiled to Lua and inserted into a final `init.lua` file,
as one may already be familiar with. In fact, you may also use `nvim-utils` to
simply generate a valid `init.lua` and use it as-is!

To get started, view the [next](./getting-started.md) page to get your first
configuration going.
