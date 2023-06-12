{
  pkgs,
  lib ? pkgs.lib,
}: let
  mkNvimPackage = {
    configuration,
    lazy-nvim,
    package,
  }: let
    mkNvimConfig = import ./mkNvimConfig {inherit pkgs lib;};
    cfg = mkNvimConfig {inherit configuration lazy-nvim;};
    vimRC = import ./rc.nix {inherit cfg lazy-nvim;};
  in
    pkgs.wrapNeovim package {
      extraMakeWrapperArgs = lib.strings.concatStringsSep " " [
        "--prefix PATH : ${cfg.extraPkgs}/bin"
        ''--add-flags "--cmd 'set rtp^=${lazy-nvim},${cfg.rtp}'"''
      ];
      configure.customRC = vimRC;
    };
in
  mkNvimPackage
