{lib}: {
  specialArgs,
  modules,
}: let
  inherit (import ./assertions.nix {inherit lib;}) assertionModule testAssertions;
  inherit (import ./warnings.nix {inherit lib;}) warningModule evalWarnings;
  evaledModule = lib.evalModules {
    inherit specialArgs;
    modules = modules ++ [assertionModule warningModule];
  };
in
  (evalWarnings evaledModule.config.warnings testAssertions evaledModule.config.assertions) evaledModule
