{
  config,
  lib,
  plugins,
  ...
}:
with lib; let
  cfg = config.colorschemes.rose-pine;
in {
  options = {
    colorschemes.rose-pine = {
      enable = mkEnableOption "rose-pine";
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
  config = mkMerge [
    (mkIf cfg.enable {
      assertions = [
        {
          assertion = !config.colorschemes.tokyonight.enable;
          message = "only one colorscheme should be enabled at any time";
        }
      ];
      plugins = [
        {
          slug = "rose-pine/neovim";
          enabled = true;
          name = "rose-pine";
          src = plugins.rose-pine;
          opts = {
            variant = cfg.variant;
            bold_vert_split = cfg.bold_vert_split;
            dim_nc_background = cfg.dim_nc_background;
            disable_background = cfg.disable_background;
            disable_float_background = cfg.disable_float_background;
            disable_italics = cfg.disable_italics;
          };
        }
      ];
      postHooks = [
        "vim.cmd.colorscheme('rose-pine')"
      ];
    })
  ];
}
