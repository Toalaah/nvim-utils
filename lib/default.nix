{lib}: rec {
  # TODO: these are both not public-facing lib func, move to internal folder or
  # package drv directrly
  evalModule = import ./evalModule {inherit lib;};
  mkPluginSpec = import ./mkPluginSpec.nix {inherit lib;};

  lua = import ./lua.nix {inherit lib;};
  vim = import ./vim.nix {
    inherit lib;
    inherit (lua) toLua;
  };
}
