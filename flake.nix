{
  description = "Functions for creating extensible, lazy-based neovim configurations in nix";

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
      neovim-nightly' = inputs.neovim-nightly.packages.${system}.neovim.overrideAttrs (_finalAttrs: {
        patches = [];
      });
    in {
      # # map each configuration to an individual package
      packages = builtins.mapAttrs (name: _:
        pkgs.callPackage nvimPkg {
          # configuration = configurations.${name};
          # package = neovim-nightly';
        })
      configurations;
      # # expose each package as an app
      # apps = builtins.mapAttrs (name: _:
      #   flake-utils.lib.mkApp {
      #     drv = self.packages.${name};
      #     exePath = "/bin/nvim";
      #   })
      # self.packages;

      # TODO: nixos + home-manager modules
      formatter = pkgs.alejandra;

      devShells.default = import ./shell.nix {inherit pkgs;};
    });
}
