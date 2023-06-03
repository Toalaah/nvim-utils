{...}: {
  imports = [
    ./colorschemes/rose-pine.nix
    ./colorschemes/tokyonight.nix
    ./git/gitsigns.nix
    ./treesitter
    ./languages/lua.nix
    ./languages/nix.nix
    ./lsp/lsp-config.nix
    ./lsp/null-ls.nix
  ];
}
