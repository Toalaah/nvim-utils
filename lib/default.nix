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
    mkConfig = import ./mkNvimConfig.nix.nix {inherit lib;};
    toLua = import ./toLua.nix.nix {inherit lib;};
    cfg = (mkConfig {inherit configuration plugins;}).config;
    lazyOpts = toLua {
      spec = [];
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
