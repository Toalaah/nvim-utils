{lib}: rec {
  evalModule = import ./evalModule {inherit lib;};
  mkPluginSpec = import ./mkPluginSpec.nix {inherit lib;};
  mkSimplePlugin = import ./mkSimplePlugin.nix {inherit lib;};
  rawLua = code: _: code;
  toLua = import ./toLua.nix {inherit lib;};
  vim = import ./vim.nix {inherit lib toLua;};
}
