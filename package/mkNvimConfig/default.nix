{
  pkgs,
  lib ? pkgs.lib,
}: let
  lib' = import ../../lib {inherit lib;};
  inherit (lib') toLua mkPluginSpec vim evalModule;
  options = import ./options.nix {inherit lib;};

  mkNvimConfig = {
    configuration,
    plugins,
    lazy-nvim,
  }: let
    cfg = evalModule {
      specialArgs = {
        inherit plugins pkgs toLua;
        mkOpts = opts: lib.filterAttrs (n: _: n != "enable") opts;
      };
      # TODO: allow custom modules / plugins to be passed through
      modules = [
        ../../modules
        options
        configuration
      ];
    };
  in {
    lazy = toLua cfg.lazy;
    vim = lib.mapAttrs (name: value: vim.processVimPrefs name value) cfg.vim;
    plugins = toLua (builtins.map mkPluginSpec cfg.plugins);
    inherit (cfg) preHooks postHooks;
    extraPkgs = pkgs.symlinkJoin {
      name = "extra-packages";
      paths = [cfg.extraPackages];
    };
  };
in
  mkNvimConfig
