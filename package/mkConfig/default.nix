{
  configuration,
  userModules,
  pkgs,
  lib ? pkgs.lib,
  extraArgs ? {},
}: let
  lib' = import ../../lib {inherit lib;};
  inherit (lib') toLua rawLua mkPluginSpec mkSimplePlugin vim evalModule;
  cfg = (evalModule {
    specialArgs =
      extraArgs
      // {
        inherit pkgs toLua rawLua mkSimplePlugin;
        inherit (lib') vim;
        mkOpts = opts: lib.filterAttrs (n: _: n != "enable") opts;
      };
    modules = [
      # base options (builtins)
      ../../modules/lazy
      ../../modules/core

      configuration
      userModules
    ];
  }).config;
  lazy = {
    inherit (cfg.lazy) src;
    opts = toLua (lib.attrsets.recursiveUpdate cfg.lazy.opts cfg.lazy._readOnlyOpts);
  };
in {
  inherit (cfg) preHooks postHooks;
  inherit lazy;
  rtp = cfg._rtpPath;
  vim = lib.mapAttrs (name: value: vim.processVimPrefs name value) cfg.vim;
  plugins = toLua (builtins.map mkPluginSpec cfg.plugins);
  extraPkgs = pkgs.symlinkJoin {
    name = "extra-packages";
    paths = [cfg.extraPackages];
  };
}
