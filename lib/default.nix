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
    cfg = (evalConfig {inherit configuration plugins;}).config;
    lazyOpts = (import ./stringifyAttrSet.nix {inherit lib;}) {
      spec = [
        {
          __index__ = "folke/tokyonight.nvim";
          dir = plugins.tokyonight-nvim.outPath;
          enabled = true;
          name = "tokyonight";
          opts = {style = "storm";};
        }
      ];
      root = "/tmp/lazy";
      dev = {path = "~/dev";};
      defaults = {lazy = true;};
      checker = {enabled = false;};
      performance = {
        cache = {enabled = true;};
        rtp = {
          disabled_plugins = [
            "gzip"
            "matchit"
            "matchparen"
            "rplugin"
            "tarPlugin"
            "tohtml"
            "tutor"
            "zipPlugin"
          ];
        };
      };
    };
  in
    wrapLuaConfig ''
      vim.opt.runtimepath:prepend('${lazy-nvim}')
      require('lazy').setup(${lazyOpts})
      ${cfg.preferences}
    '';

  # TODO: allow for specifiying custom neovim packages
  mkNeovimPackage = let
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
