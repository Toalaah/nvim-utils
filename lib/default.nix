{
  pkgs,
  lib ? pkgs.lib,
  ...
}: rec {
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
    # evaluates configuration into a set of stringified lua tables
    evalConfig = import ./configGenerator.nix {inherit lib;};
    cfg = evalConfig {inherit configuration plugins;};
  in
    wrapLuaConfig ''
      vim.opt.runtimepath:prepend('${lazy-nvim}')
      require('lazy').setup({${cfg.config.spec}},
        {
          root = '/tmp/lazy',
          dev = { path = "~/dev" },
          defaults = { lazy = true },
          checker = { enabled = false },
          performance = {
            cache = { enabled = true },
            rtp = {
              disabled_plugins = {
                'gzip',
                'matchit',
                'matchparen',
                'rplugin',
                'tarPlugin',
                'tohtml',
                'tutor',
                'zipPlugin',
              },
            },
          }
        })
      ${cfg.config.preferences}
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
      pkgs.wrapNeovim neovim-nightly.packages.${system}.neovim {
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
}
