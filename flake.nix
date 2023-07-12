{
  description = "Utilities for creating extensible, reproducible, and portable lazy.nvim-based neovim configurations in nix";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";

    neovim-nightly.url = "github:neovim/neovim?dir=contrib";
    neovim-nightly.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    flake-utils,
    neovim-nightly,
    nixpkgs,
    ...
  } @ inputs:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {inherit system;};
      nvimPkg = import ./package;
      configurations = import ./configurations;
      neovim-nightly' = inputs.neovim-nightly.packages.${system}.neovim;
    in {
      # map each configuration to an individual package
      packages = builtins.mapAttrs (name: _:
        pkgs.callPackage nvimPkg {
          configuration = configurations.${name};
          package = neovim-nightly';
        })
      configurations;

      # TODO: nixos + home-manager modules
      formatter = pkgs.alejandra;

      devShells.default = import ./shell.nix {inherit pkgs;};
    });
}
