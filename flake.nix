{
  description = "Neovim flake powered via Lazy.nvim";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
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

    # Temporary fix for unreproducable build. See
    # nix-community/neovim-nightly-overlay#164
    nixpkgs-neovim-nightly.url = "github:nixos/nixpkgs?rev=fad51abd42ca17a60fc1d4cb9382e2d79ae31836";
    neovim-nightly = {
      url = "github:neovim/neovim/nightly/?dir=contrib";
      inputs.nixpkgs.follows = "nixpkgs-neovim-nightly";
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
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        config = {};
        overlays = [];
      };
      lib = import ./lib {inherit pkgs;};
      configurations = import ./configurations;
      plugins = {
        inherit rose-pine tokyonight-nvim;
      };
    in rec {
      # map each configuration to an individual package
      packages = builtins.mapAttrs (name: _:
        lib.mkNeovimPackage {
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
