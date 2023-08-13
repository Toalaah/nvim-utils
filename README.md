# Nvim-Utils

[![Smoke test](https://github.com/Toalaah/nvim-utils/actions/workflows/smoke-test.yml/badge.svg?branch=master)](https://github.com/Toalaah/nvim-utils/actions/workflows/smoke-test.yml)

`nvim-utils` is a collection of utility functions and modules for managing
Neovim configurations / plugins in Nix. It aims to simplify the creation of
reproducible, reusable, and extensible configurations.

## Quick-Start

You can get up and running with your own configuration by calling `mkNvimPkg`.

```nix
# flake.nix
{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  inputs.nvim-utils.url = "github:/toalaah/nvim-utils";
  inputs.nvim-utils.inputs.nixpkgs.follows = "nixpkgs";

  outputs = {
    self,
    nixpkgs,
    nvim-utils,
  }: let
    system = "x86_64-linux";
  in {
    packages.${system}.default = with nvim-utils.lib;
      mkNvimPkg {
        pkgs = import nixpkgs {inherit system;};
        modules = [baseModules.all];
        configuration = import ./configuration.nix;
      };
  };
}
```

Configuration for `nvim-utils` is simply a module, as you may be used to from
NixOS or Home Manager.

```nix
# configuration.nix
{
    treesitter.enable = true;
    treesitter.opts.highlight.enable = true;

    lsp.lspconfig.enable = true;
    # enable lsp tooling for lua and nix
    languages.lua.enable = true;
    languages.nix.enable = true;

    # plugin opts are directly converted to their lua representation!
    telescope.enable = true;
    telescope.opts.pickers.find_files = {
        theme = "dropdown";
    };
}
```

## Documentation

Detailed usage documentation and available module options can be found
[here](https://toalaah.github.io/nvim-utils).

## FAQ

**_How do I define (keybindings/autocmds/...)_?**

See the [documentation](https://toalaah.github.io/nvim-utils). If something you
need is not supported, open an issue.

---

**_How is this different to NixVim?_**

It's not really that much different to be honest in so much that `nvim-utils`
is significantly less mature and more bug-prone. I suppose the primary
difference is the plugin backend used (or lack thereof), as `nixvim` seems use
packer / `packadd` rather than `lazy` (although there appear to be discussions
surrounding this). So why reinvent the wheel?

- TBH I was not aware of this project until well into development of this tool
- One of the goals with project ~~was~~ is to improve my understanding of the
  Nix language
- I wanted to continue using `lazy.nvim` as my plugin manager while moving to a
  more nix-based neovim configuration

---

**_Plugin <...\> is not available_**

You can quite easily integrate any plugin of your choosing to `nvim-utils`. See
the relevant
[section](https://toalaah.github.io/nvim-utils/getting-started.html#writing-custom-modules)
in the documentation

## Acknowledgments

- [lazy.nvim](https://github.com/folke/lazy.nvim/), used as the plugin backend.
- [home manager](https://github.com/nix-community/home-manager), for general
  guidance on custom module structuring and auto-generation of documentation.
- [nix-vim](https://github.com/nix-community/nixvim), a similar approach to
  nix-based neovim configuration

## License

This project is released under the terms of the GPL-3.0 license.
