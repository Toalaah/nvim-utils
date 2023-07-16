{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.colorschemes.tokyonight;
  src = pkgs.fetchFromGitHub {
    owner = "folke";
    repo = "tokyonight.nvim";
    rev = "161114bd39b990995e08dbf941f6821afbdcd666";
    hash = "sha256-IMrqcx/f5cauDBxSLP1bjsaFXLBv24XXCPxpyj+Jb/E=";
  };
in {
  options = {
    colorschemes.tokyonight = {
      enable = mkEnableOption "tokyonight";
      src = mkOption {
        type = types.attrs;
        description = lib.mdDoc ''
          Source to use for this plugin. This allows you to swap out the pinned
          version with a newer revision/fork or add patches by creating a
          wrapper derivation.
        '';
        default = src;
      };
      opts = {
        style = mkOption {
          description = "variant of tokyonight to use";
          type = types.enum ["day" "moon" "night" "storm"];
          default = "moon";
        };
      };
    };
  };
  config = mkIf cfg.enable {
    assertions = [];
    plugins = [
      {
        slug = "folke/tokyonight.nvim";
        inherit (cfg) src opts;
      }
    ];
  };
}
