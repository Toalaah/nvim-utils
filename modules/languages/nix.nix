{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.languages.nix;
in {
  options = {
    languages.nix = {
      enable = mkEnableOption "nix";
    };
  };
  config = mkMerge [
    (mkIf cfg.enable {
      assertions = [];
      plugins = [];
      treesitter.parsers = ["nix"];
    })
  ];
}
