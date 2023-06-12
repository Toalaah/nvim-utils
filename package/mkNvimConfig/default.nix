{
  pkgs,
  lib ? pkgs.lib,
}: let
  lib' = import ../../lib {inherit lib;};
  inherit (lib') toLua rawLua mkPluginSpec vim evalModule;
  options = import ./options.nix {inherit lib;};

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
        options
        configuration
      ];
    };
    mkRtp = import ./rtp.nix pkgs;
  in {
    rtp = mkRtp cfg.rtp;

    # TODO: create a designated module for the lazy config?

    # We set the root to the path of an empty derivation as it is useless
    # within the context of a pre-installed/built, immutable config
    lazy = let
      root = (pkgs.runCommand "lazy-root" {} "mkdir $out").outPath;
    in
      toLua (cfg.lazy // {inherit root;});
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
