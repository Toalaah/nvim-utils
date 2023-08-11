{
  description = "Nix bindings for creating and sharing neovim configurations";

  inputs.nixpkgs.url = "github:nixos/nixpkgs";

  outputs = {
    self,
    nixpkgs,
    ...
  }: let
    mkModule = import ./mkModule.nix;
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

    lib.baseModules = let
      modules = import ./modules;
      recurseAttrValuesToList = list:
        builtins.map (
          v:
            if builtins.typeOf v == "set"
            then recurseAttrValuesToList (nixpkgs.lib.attrValues v)
            else v
        )
        list;
      moduleList = nixpkgs.lib.flatten (recurseAttrValuesToList (nixpkgs.lib.attrValues modules));
    in
      {
        all = {imports = moduleList;};
      }
      // modules;

    lib.mkNvimPkg = import ./package;

    formatter = eachSystem ({pkgs, ...}: pkgs.alejandra);

    devShells = eachSystem ({pkgs, ...}: {
      default = import ./shell.nix {inherit pkgs;};
    });
  };
}
