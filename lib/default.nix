{lib}: let
  toLua = import ./toLua.nix {inherit lib;};
  vim = import ./vim.nix {inherit lib toLua;};
  mkPluginSpec = import ./mkPluginSpec.nix {inherit lib;};
  evalModule = import ./evalModule {inherit lib;};
  rawLua = code: _: code;
in {
  inherit toLua vim mkPluginSpec evalModule rawLua;
}
