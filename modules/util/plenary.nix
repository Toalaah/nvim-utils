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
    rev = "74b06c6c75e4eeb3108ec01852001636d85a932b";
    sha256 = "1bms9ihcz2gsk88mr00izxn7sjl1lfc62mk0fy54z20g756c8iwy";
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
