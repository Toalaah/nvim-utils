{
  pkgs,
  lib ? pkgs.lib,
  configuration ? {},
  modules ? [],
  package ? pkgs.neovim-unwrapped,
  extraArgs ? {},
}: let
  mkConfig = import ./mkConfig;
  cfg = mkConfig {
    inherit configuration pkgs lib extraArgs;
    modules' = {imports = modules;};
  };
  initLua = pkgs.writeTextFile {
    name = "init.lua";
    text = ''
      ${cfg.vim.opt}
      ${cfg.vim.g}
      ${cfg.preHooks}
      require('lazy').setup(${cfg.plugins}, ${cfg.lazy.opts})
      ${cfg.postHooks}
    '';
  };
in
  (pkgs.wrapNeovim package {
    extraMakeWrapperArgs = lib.strings.concatStringsSep " " [
      "--prefix PATH : ${cfg.extraPkgs}/bin"
      ''--add-flags "--cmd 'set rtp^=${cfg.lazy.src},${cfg.rtp}'"''
      "--add-flags '-u ${initLua}'"
    ];
  })
  .overrideAttrs (_: {passthru = {inherit initLua;};})
