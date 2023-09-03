{
  core = ./core;

  languages.lua = ./languages/lua;
  languages.nix = ./languages/nix;
  languages.rust = ./languages/rust;

  lazy = ./lazy;

  lsp = ./lsp;

  telescope = ./telescope;

  treesitter = ./treesitter;

  util.plenary = ./util/plenary.nix;
  util.devicons = ./util/devicons.nix;
}
