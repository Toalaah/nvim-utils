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
    rev = "50012918b2fc8357b87cff2a7f7f0446e47da174";
    sha256 = "1sn7vpsbwpyndsjyxb4af8fvz4sfhlbavvw6jjsv3h18sdvkh7nd";
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
