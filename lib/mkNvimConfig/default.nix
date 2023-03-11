{lib}: let
  options = import ./options.nix {inherit lib;};
  mkLazySpec = import ../mkLazySpec.nix {inherit lib;};
  toLua = import ../toLua.nix {inherit lib;};

  /*
  Produces an attribute set of various pieces of lua code to be consumed by the
  top-level mkNeovimPackage wrapper.

  Type:
    mkNvimConfig :: AttrSet -> AttrSet
  */
  mkNvimConfig = {
    configuration,
    plugins,
    # TODO: allow custom modules / plugins to be passed through
  }: let
    cfg =
      (lib.evalModules {
        specialArgs = {inherit plugins;};
        modules = [../../modules options configuration];
      })
      .config;
  in {
    preferences = lib.strings.concatStringsSep "\n" cfg.preferences;
    plugins = toLua (builtins.map mkLazySpec cfg.plugins);
  };
in
  mkNvimConfig
