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
    rev = "08e301982b9a057110ede7a735dd1b5285eb341f";
    sha256 = "03x9mxxqscahs3plml9pw0q6yacyiz6nvw4pcbpqlcqj99f0qbdz";
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
