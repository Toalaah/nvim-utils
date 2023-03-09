{lib}: let
  options = import ./options.nix {inherit lib;};
  mkNvimConfig = {
    configuration,
    plugins,
    # TODO: allow custom modules / plugins to be passed through
  }:
    (lib.evalModules {
      specialArgs = {inherit plugins;};
      modules = [../modules options configuration];
    })
    .config;
in
  mkNvimConfig
