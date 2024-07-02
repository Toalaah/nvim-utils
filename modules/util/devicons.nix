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
    rev = "c0cfc1738361b5da1cd0a962dd6f774cc444f856";
    sha256 = "1fwc0xrg07cr7x8cgksckqlkwbjl3nh0qvailp89zd35al9pzw4g";
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
