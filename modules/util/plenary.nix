{
  config,
  lib,
  pkgs,
  ...
}:
lib.vim.mkSimplePlugin {
  inherit config;
  plugin = pkgs.fetchFromGitHub {
    owner = "nvim-lua";
    repo = "plenary.nvim";
    rev = "8aad4396840be7fc42896e3011751b7609ca4119";
    sha256 = "06ahw1mxjp5g1kbsdza29hyawr4blqzw3vb9d4rg2d5qmnwcbky0";
  };
  noSetup = true;
  category = "util";
  extraModuleOpts = {
    slug = lib.mkOption {
      default = "nvim-lua/plenary.nvim";
      readOnly = true;
      internal = true;
      type = lib.types.str;
      description = "a readonly value for referencing plenary.nvim as a dependency";
    };
  };
}
