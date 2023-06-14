{
  pkgs,
  lib ? pkgs.lib,
}: let
  lib' = import ../../lib {inherit lib;};
  inherit (lib') toLua rawLua mkPluginSpec vim evalModule;

  mkNvimConfig = {
    lazy-nvim,
    configuration ? {},
  }: let
    cfg = evalModule {
      specialArgs = {
        inherit pkgs toLua rawLua;
        mkOpts = opts: lib.filterAttrs (n: _: n != "enable") opts;
      };
      # TODO: allow custom modules / plugins to be passed through
      modules = [
        ../../modules
        configuration
        ./options.nix
      ];
    };

    mkPlugNameDrv = plug: let
      src = plug.src;
      name = src.repo;
    in
      pkgs.runCommand name {} ''
        mkdir -p $out
        cp -r ${src} $out/${name}
      '';
    pluginDrv = let
      nestedPlugins = lib.lists.flatten (builtins.map (p: p.dependencies or []) cfg.plugins);
      nestedPluginSpecs = builtins.filter (p: builtins.isAttrs p) nestedPlugins;
      allPlugins = cfg.plugins ++ nestedPluginSpecs;
    in
      pkgs.symlinkJoin {
        name = "plugins";
        paths = builtins.map mkPlugNameDrv allPlugins;
      };
  in {
    rtp = cfg._rtpPath;

    # TODO: create a designated module for the lazy config?

    lazy = toLua (cfg.lazy // {root = pluginDrv.outPath;});
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
