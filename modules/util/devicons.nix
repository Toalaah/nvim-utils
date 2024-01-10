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
    rev = "db0c864375c198cacc171ff373e76bfce2a85045";
    sha256 = "1qli4s3i00bd93wc0mjhp6wx9py2rc7lbdcf5dl93x2ymggy6ln5";
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
