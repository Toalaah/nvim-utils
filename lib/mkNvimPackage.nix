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
    pkgs,
  }: let
    mkConfig = import ./mkNvimConfig {inherit pkgs lib;};
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
  mkNvimPackage = {
    configuration,
    lazy-nvim,
    package,
    plugins,
  }: let
    extraPkgs = pkgs.symlinkJoin {
      name = "extra-packages";
      paths = [pkgs.hello];
    };
  in
    pkgs.wrapNeovim package {
      extraMakeWrapperArgs = ''
        --prefix PATH : ${extraPkgs}/bin
      '';
      configure = {
        customRC = mkVimRC {
          inherit
            lazy-nvim
            configuration
            plugins
            pkgs
            ;
        };
      };
    };
in
  mkNvimPackage
