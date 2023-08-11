{
  configuration,
  userModules,
  pkgs,
  lib ? pkgs.lib,
  extraArgs ? {},
}: let
  lib' = lib.extend (_: prev: (import ../../lib {lib = prev;}) // prev);
  inherit (lib') mkPluginSpec;
  inherit (lib'.lua) toLua;
  inherit (lib'.vim) processVimPrefs;

  cfg =
    (lib'.evalModule {
      specialArgs =
        extraArgs
        // {
          inherit pkgs;
          lib = lib';
        };
      modules = [
        # base options (builtins)
        ../../modules/lazy
        ../../modules/core

        configuration
        userModules
      ];
    })
    .config;

  lazy = {
    inherit (cfg.lazy) src;
    opts = toLua (lib.attrsets.recursiveUpdate cfg.lazy.opts cfg.lazy._readOnlyOpts);
  };
in {
  inherit (cfg) preHooks postHooks;
  inherit lazy;
  rtp = cfg._rtpPath;
  vim = lib.mapAttrs (name: value: processVimPrefs name value) cfg.vim;
  plugins = toLua (builtins.map mkPluginSpec cfg.plugins);
  extraPkgs = pkgs.symlinkJoin {
    name = "extra-packages";
    paths = [cfg.extraPackages];
  };
}
