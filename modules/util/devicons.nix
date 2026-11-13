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
    rev = "0dc0cfb0c6858041174a53c7aa4adaf65e994b3c";
    sha256 = "07ndvg4i5fwg16gqc7ras7bgm29h3jlj43xjzqa9kyfkk4hixmpf";
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
