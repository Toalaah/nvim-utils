{lib}: let
  options = import ./options.nix {inherit lib;};
  assertions = import ../assertions.nix {inherit lib;};
  mkLazySpec = import ../mkLazySpec.nix {inherit lib;};
  toLua = import ../toLua.nix {inherit lib;};
  /*
  processes each vim namespace (for example "vim.g" or "vim.o") into
  stringified lua code
  */
  processVimPrefs = ns: values:
    lib.strings.concatStringsSep "\n"
    (
      lib.mapAttrsToList
      (name: value: "vim.${ns}.${name} = ${toLua value}")
      values
    );

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
    evaledModule = lib.evalModules {
      specialArgs = {inherit plugins;};
      modules = [
        ../../modules
        options
        configuration
        assertions
      ];
    };

    testAssertions = assertions: let
      failedAssertions = map (x: x.message) (lib.filter (x: !x.assertion) assertions);
    in
      if failedAssertions == []
      then lib.id
      else throw "\nFailed assertions:\n${lib.concatMapStringsSep "\n" (x: "- ${x}") failedAssertions}";

    cfg = (testAssertions evaledModule.config.assertions) evaledModule.config;
  in {
    lazy = toLua cfg.lazy;
    vim = lib.mapAttrs (name: value: processVimPrefs name value) cfg.vim;
    plugins = toLua (builtins.map mkLazySpec cfg.plugins);
    inherit (cfg) preHooks postHooks;
  };
in
  mkNvimConfig
