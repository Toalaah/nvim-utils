{nixos ? false}: {
  lib,
  pkgs,
  config,
  ...
}:
with lib; let
  cfg = config.programs.nvim;
  mkNvimPkg = pkgs.callPackage (import ./package);
  neovimPackage = mkNvimPkg {
    inherit (cfg) package configuration modules;
  };
in {
  options.programs.nvim = {
    enable = mkEnableOption "A lazy.nvim-based neovim configuration";
    package = mkOption {
      type = types.package;
      default = pkgs.neovim-unwrapped;
      description = "Neovim package to use in the underlying derivation";
    };
    modules = mkOption {
      # TODO: stricter typechecking?
      type = types.listOf types.anything;
      default = [];
      description = "Additional modules to pass to the underlying derivation";
    };
    configuration = mkOption {
      type = types.attrs;
      default = {};
      description = "Top-level plugin configuration to pass to the underlying derivation";
    };
  };
  config = let
    homeConfiguration = {
      home.packages = [neovimPackage];
    };
    nixosConfiguration = {
      environment.systemPackages = [neovimPackage];
    };
  in
    mkIf cfg.enable
    (
      if nixos
      then nixosConfiguration
      else homeConfiguration
    );
}
