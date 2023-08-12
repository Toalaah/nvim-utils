{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  inputs.nvim-utils.url = "github:toalaah/nvim-utils";
  inputs.nvim-utils.inputs.nixpkgs.follows = "nixpkgs";

  outputs = {
    self,
    nixpkgs,
    nvim-utils,
  }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {inherit system;};
  in {
    packages.${system}.default = with nvim-utils.lib;
      mkNvimPkg {
        inherit pkgs;
        modules = [baseModules.all ./exampleModule.nix];
        configuration = ./configuration.nix;
      };
  };
}
