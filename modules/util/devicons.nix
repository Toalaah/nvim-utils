{
  config,
  lib,
  pkgs,
  ...
}:
lib.vim.mkSimplePlugin {
  inherit config;
  plugin = pkgs.fetchFromGitHub {
    owner = "nvim-tree";
    repo = "nvim-web-devicons";
    rev = "3ee60deaa539360518eaab93a6c701fe9f4d82ef";
    sha256 = "1a0z8canxpr5vlnmkqpys35yar8l296gdznqlvvvf1200wai3i8v";
  };
  noSetup = true;
  moduleName = "devicons";
  category = "util";
  extraModuleOpts = {
    slug = lib.mkOption {
      default = "nvim-tree/nvim-web-devicons";
      readOnly = true;
      internal = true;
      type = lib.types.str;
      description = "a readonly value for referencing nvim-web-devicons as a dependency";
    };
  };
}
