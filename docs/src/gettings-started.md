# Getting Started

To create a basic config without any tweaks, we can simply call `mkNvimPkg`
without any additional arguments.

```nix
# default.nix
{pkgs ? import <nixpkgs> {}}: let
  nvim-utils = import (builtins.fetchGit {
    url = "https://github.com/toalaah/nvim-utils";
  });
in
  nvim-utils.lib.mkNvimPkg {
    inherit pkgs;
  }
```

# Using Modules

Let's try to set the colorscheme by using the builtin `colorschemes` module.
Make sure to include the corresponding module, otherwise you will get
definition errors!

```nix
# default.nix
nvim-utils.lib.mkNvimPkg {
  inherit pkgs;
  modules = with nvim-utils.lib.baseModules; [colorschemes.tokyonight];
  configuration = {
    colorschemes.tokyonight.enable = true;
  };
}
```

Refer to the [builtin modules](./modules/builtins/README.md) for all available
modules along with their options.

# Writing Custom Modules

Say we want to use a colorscheme which is not a builtin module. No problem,
let's write our own. The process is very similar to writing a NixOS module, as
under the hood the same process is used to merge and apply each module.

Let's create a file `myCoolColorscheme.nix` and use `mkSimplePlugin` to reduce
the amount of boilerplate needed.

```nix
# myCoolColorscheme.nix
{ config, pkgs, mkSimplePlugin, ... }: mkSimplePlugin {
  inherit config;
  # The category correspondes to the module path. So we will be able to
  # activate this module by specifying `colorschemes.myCoolColorscheme`
  category = "colorschemes/myCoolColorscheme";
  plugin = pkgs.fetchFromGitHub {
    owner = "user";
    repo = "myCoolColorscheme";
    rev = "v1.0.0";
  };
}
```

Then in `default.nix`, simply add the module file and enable the configuration.

```nix
# default.nix
nvim-utils.lib.mkNvimPkg {
  inherit pkgs;
  modules = [ ./myCoolColorscheme.nix ];
  configuration = {
    colorschemes.myCoolColorscheme.enable = true;
    # Opts are converted to lua and passed to `myCoolColorscheme.setup()` by lazy.nvim.
    colorschemes.myCoolColorscheme.opts = {
        style = "foo";
        highlights = [ "bar" "baz" ];
    }
  };
}
```

# Autocmds, Keymaps, etc.

Besides plugins, there are a number of other components which you can
configure, for instance:

- Autocommands
- Keymaps
- Pre- and post-hooks

Refer to the [core](./lib/README.md) module for more information.

**Note**: The `core` and `lazy` modules are implicitly included and do not need
to be specified in the `modules` argument of `mkNvimPkg`.
