# Modules

There are a number of pre-built modules offered by `nvim-utils`. Most of these
are completely optional, although some are hard-coded to be included due to
their primitive nature.

The following modules are **builtin** to `mkNvimPkg`. They cannot be omitted or
overwritten.

- [Core](./core.md)
- [Autocmds](./autocmds.md)
- [Keymaps](./keymaps.md)
- [Lazy](./lazy.md)
- [Vim](./vim.md)

All other modules are completely optional and need to be **manually** included
as dependencies in `mkNvimPkg`. For instance, to add the optional
[treesitter](./treesitter.md) module, you would add `baseModules.treesitter` to
your list of modules.


```nix
nvim-utils.lib.mkNvimPkg {
  inherit pkgs;
  modules = with nvim-utils.lib.baseModules; [
    treesitter
    # other modules, for instance your own...
  ];
  # ...
}
```
