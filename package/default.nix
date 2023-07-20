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
  initLua = pkgs.writeTextFile {
    name = "init.lua";
    text = ''
      ${cfg.vim.opt}
      ${cfg.vim.g}
      ${cfg.preHooks}
      require('lazy').setup(${cfg.plugins}, ${cfg.lazy})
      ${cfg.postHooks}
    '';
  };
in
  (pkgs.wrapNeovim package {
    extraMakeWrapperArgs = lib.strings.concatStringsSep " " [
      "--prefix PATH : ${cfg.extraPkgs}/bin"
      ''--add-flags "--cmd 'set rtp^=${lazy-nvim},${cfg.rtp}'"''
      "--add-flags '-u ${initLua}'"
    ];
  })
  .overrideAttrs (old: {passthru.initLua = builtins.readFile initLua;})
