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
      enable = mkEnableOption "rose-pine";
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
        variant = mkOption {
          description = "variant of rose-pine to use";
          type = types.enum ["auto" "main" "moon" "dawn"];
          default = "auto";
        };
        bold_vert_split = mkEnableOption "bold vertical split";
        dim_nc_background = mkEnableOption "dim nc background";
        disable_background = mkEnableOption "disable background";
        disable_float_background = mkEnableOption "disable float background";
        disable_italics = mkEnableOption "disable italics";
      };
    };
  };
  config = mkMerge [
    (mkIf (cfg.enable || config.colorschemes.default == "rose-pine") {
      assertions = [];
      plugins = [
        {
          slug = "rose-pine/neovim";
          name = "rose-pine";
          inherit (cfg) src opts;
        }
      ];
    })
  ];
}
