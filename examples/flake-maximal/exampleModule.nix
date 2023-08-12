{
  config,
  lib,
  pkgs,
  ...
}:
lib.vim.mkSimplePlugin {
  inherit config;
  plugin = pkgs.fetchFromGitHub {
    owner = "ellisonleao";
    repo = "gruvbox.nvim";
    rev = "353be593e52e2008ce17d61208668747dd557248";
    sha256 = "sha256-OyQQpXiXlPuv0KOo5ppt7ox12cRR8vA0Qk76fRA2/6U=";
  };
  category = "colorschemes";
  extraPluginConfig = _cfg: {
    priority = 1000;
    lazy = false;
  };
}
