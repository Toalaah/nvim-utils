{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.colorschemes.rose-pine;
  src = pkgs.fetchFromGitHub {
    owner = "rose-pine";
    repo = "neovim";
    rev = "34f68e871527fb8d7d193e04dafedcf7005304c1";
    hash = "sha256-Hu78KpnXvhTWEIfsKx3oZL9kUc7xfV/0mAbY74q300o=";
  };
in {
  options = {
    colorschemes.rose-pine = {
      enable = mkEnableOption (lib.mdDoc "rose-pine");
      src = mkOption {
        type = types.package;
        description = lib.mdDoc ''
          Source to use for this plugin. This allows you to swap out the pinned
          version with a newer revision/fork or add patches by creating a
          wrapper derivation.
        '';
        default = src;
      };
      opts = {
        variant = mkOption {
          description = lib.mdDoc "variant of rose-pine to use";
          type = types.enum ["auto" "main" "moon" "dawn"];
          default = "auto";
        };
        bold_vert_split = mkEnableOption (lib.mdDoc "bold vertical split");
        dim_nc_background = mkEnableOption (lib.mdDoc "dim nc background");
        disable_background = mkEnableOption (lib.mdDoc "disable background");
        disable_float_background = mkEnableOption (lib.mdDoc "disable float background");
        disable_italics = mkEnableOption (lib.mdDoc "disable italics");
      };
    };
  };
  config = mkIf cfg.enable {
    assertions = [];
    plugins = [
      {
        inherit (cfg) src opts;
        name = "rose-pine";
        main = "rose-pine";
      }
    ];
  };
}
