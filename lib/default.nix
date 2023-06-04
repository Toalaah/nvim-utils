{lib}: let
  toLua = import ./toLua.nix {inherit lib;};
  vim = import ./vim.nix {inherit lib toLua;};
  mkPluginSpec = import ./mkPluginSpec.nix {inherit lib;};
  evalModule = import ./evalModule {inherit lib;};
in {
  inherit toLua vim mkPluginSpec evalModule;
}
