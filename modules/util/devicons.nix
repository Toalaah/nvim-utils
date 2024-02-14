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
    rev = "7f30f2da3c3641841ceb0e2c150281f624445e8f";
    sha256 = "1srssx18fgipznnl6b3lk17jkv0acsx6cw86m6x788nawl6qhsv7";
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
