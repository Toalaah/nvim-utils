{
  configuration,
  modules',
  pkgs,
  lib ? pkgs.lib,
}: let
  lib' = import ../../lib {inherit lib;};
  inherit (lib') toLua rawLua mkPluginSpec vim evalModule;
  cfg = evalModule {
    specialArgs = {
      inherit pkgs toLua rawLua;
      mkOpts = opts: lib.filterAttrs (n: _: n != "enable") opts;
    };
    modules = [
      modules'
      configuration
      # base options
      ./options.nix
      ../../modules/lazy
    ];
  };
  lazy = let
    # https://stackoverflow.com/questions/54504685
    recursiveMerge = attrList: let
      f = attrPath:
        lib.zipAttrsWith (
          n: values:
            if builtins.tail values == []
            then builtins.head values
            else if builtins.all builtins.isList values
            then lib.unique (lib.concatLists values)
            else if builtins.all builtins.isAttrs values
            then f (attrPath ++ [n]) values
            else lib.warn "ignoring configuration value for 'lazy.opts.${n}', using default instead." lib.last values
        );
    in
      f [] attrList;
  in {
    inherit (cfg.lazy) src;
    opts = toLua (recursiveMerge [cfg.lazy.opts cfg.lazy._readOnlyOpts]);
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
