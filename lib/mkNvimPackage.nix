{
  pkgs,
  lib ? pkgs.lib,
}: let
  wrapLuaConfig = luaCode: ''
    lua << EOF
    ${luaCode}
    EOF
  '';

  mkVimRC = {
    lazy-nvim,
    configuration,
    plugins,
  }: let
    mkConfig = import ./mkNvimConfig {inherit lib;};
    cfg = mkConfig {inherit configuration plugins;};
  in
    wrapLuaConfig ''
      ${cfg.preHooks}
      vim.opt.runtimepath:prepend('${lazy-nvim}')
      require('lazy').setup(${cfg.plugins}, ${cfg.lazy})
      ${cfg.vim.opt}
      ${cfg.vim.g}
      ${cfg.postHooks}
    '';

  # TODO: allow for specifiying custom neovim packages
  mkNvimPackage = let
    system = pkgs.system;
  in
    {
      configuration,
      plugins,
      lazy-nvim,
      neovim-nightly,
    }:
      pkgs.wrapNeovim neovim-nightly {
        configure = {
          customRC = mkVimRC {
            inherit
              lazy-nvim
              configuration
              plugins
              ;
          };
        };
      };
in
  mkNvimPackage
