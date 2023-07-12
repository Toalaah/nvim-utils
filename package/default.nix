{
  pkgs,
  lib ? pkgs.lib,
  configuration ? {},
  modules ? [],
  lazy-nvim ? pkgs.fetchFromGitHub (import ./lazy-src.nix),
  package ? pkgs.neovim-unwrapped,
}: let
  mkConfig = import ./mkConfig {inherit pkgs lib;};
  cfg = mkConfig {
    inherit configuration lazy-nvim;
    modules' = {imports = modules;};
  };
  wrapLuaConfig = luaCode: ''
    lua << EOF
    ${luaCode}
    EOF
  '';
in
  pkgs.wrapNeovim package {
    extraMakeWrapperArgs = lib.strings.concatStringsSep " " [
      "--prefix PATH : ${cfg.extraPkgs}/bin"
      ''--add-flags "--cmd 'set rtp^=${lazy-nvim},${cfg.rtp}'"''
    ];
    configure.customRC = wrapLuaConfig ''
      ${cfg.preHooks}
      require('lazy').setup(${cfg.plugins}, ${cfg.lazy})
      ${cfg.vim.opt}
      ${cfg.vim.g}
      ${cfg.postHooks}
    '';
  }
