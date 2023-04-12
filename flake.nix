{
  description = "Neovim flake powered via Lazy.nvim";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    # plugins
    lazy-nvim = {
      url = "github:folke/lazy.nvim";
      flake = false;
    };
    rose-pine = {
      url = "github:rose-pine/neovim";
      flake = false;
    };
    tokyonight-nvim = {
      url = "github:folke/tokyonight.nvim";
      flake = false;
    };
    gitsigns-nvim = {
      url = "github:lewis6991/gitsigns.nvim";
      flake = false;
    };

    neovim-nightly = {
      url = "github:neovim/neovim/nightly?dir=contrib";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    flake-utils,
    lazy-nvim,
    neovim-nightly,
    nixpkgs,
    rose-pine,
    tokyonight-nvim,
    ...
  } @ attrs:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        config = {};
        overlays = [];
      };
      mkNvimPackage = import ./lib/mkNvimPackage.nix {inherit pkgs;};
      configurations = import ./configurations;
      plugins = pkgs.lib.filterAttrs (x: _:
        !(builtins.elem x [
          "flake-utils"
          "lazy-nvim"
          "neovim-nightly"
          "nixpkgs"
        ]))
      attrs;
    in rec {
      # map each configuration to an individual package
      packages = builtins.mapAttrs (name: _:
        mkNvimPackage {
          configuration = configurations.${name};
          inherit plugins neovim-nightly lazy-nvim;
        })
      configurations;
      # expose each package as an app
      apps = with flake-utils.lib;
        builtins.mapAttrs (name: _:
          mkApp {
            drv = packages.${name};
            exePath = "/bin/nvim";
          })
        packages;

      # TODO: nixos + home-manager modules
      formatter = pkgs.alejandra;

      devShells.default = import ./shell.nix {inherit pkgs;};
    });
}
