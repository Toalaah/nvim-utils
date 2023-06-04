{lib}: {
  specialArgs,
  modules,
}: let
  inherit (import ./assertions.nix {inherit lib;}) assertionModule testAssertions;
  evaledModule = lib.evalModules {
    inherit specialArgs;
    modules = modules ++ [assertionModule];
  };
in
  (testAssertions evaledModule.config.assertions) evaledModule.config
