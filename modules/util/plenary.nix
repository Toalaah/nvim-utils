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
    rev = "b9fd5226c2f76c951fc8ed5923d85e4de065e509";
    sha256 = "1kg043h7dqcrqqgg8pp6hsldx7jdhlh8qwad2kkckia191xgnjgm";
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
