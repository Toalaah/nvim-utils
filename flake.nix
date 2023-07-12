{
  description = "Utilities for creating extensible, reproducible, and portable lazy.nvim-based neovim configurations in nix";

  inputs.nixpkgs.url = "github:nixos/nixpkgs";

  outputs = {
    self,
    nixpkgs,
    ...
  }: let
    mkModule = import ./module.nix;
    eachSystem = f:
      nixpkgs.lib.genAttrs [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ] (system: let pkgs = import nixpkgs {inherit system;}; in f {inherit system pkgs;});
  in {
    homeManagerModules.nvim = mkModule {};
    homeManagerModules.default = self.homeManagerModules.nvim;

    nixosModules.nvim = mkModule {nixos = true;};
    nixosModules.default = self.nixosModules.nvim;

    lib.baseModules = ./modules;

    formatter = eachSystem ({pkgs, ...}: pkgs.alejandra);

    devShells = eachSystem ({pkgs, ...}: {
      default = import ./shell.nix {inherit pkgs;};
    });

    packages = eachSystem (
      {pkgs, ...}: let
        mkNvimPkg = pkgs.callPackage (import ./package);
        configurations = import ./configurations;
      in
        builtins.mapAttrs (name: _:
          mkNvimPkg {
            configuration = configurations.${name};
            modules = [self.lib.baseModules];
          })
        configurations
    );
  };
}
