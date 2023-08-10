# Flake Usage

In addition to standard Nix expressions, `nvim-utils` fully supports flake
usage. See the example below.


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

    apps.${system}.default = let
      pkg = self.packages.${system}.default;
    in {
      type = "app";
      program = "${pkg}/bin/nvim";
    };
  };
}
```
