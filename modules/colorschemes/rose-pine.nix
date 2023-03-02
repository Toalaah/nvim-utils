{
  config,
  lib,
  plugins,
  ...
}:
with lib; let
  cfg = config.colorschemes.rose-pine;
  bool = x: lib.boolToString x;
  defaultFalse = desc:
    mkOption {
      description = desc;
      type = types.bool;
      default = false;
    };
in {
  options = {
    colorschemes.rose-pine = {
      enable = mkEnableOption "rose-pine";
      variant = mkOption {
        description = "variant of rose-pine to use";
        type = types.enum ["auto" "main" "moon" "dawn"];
        default = "auto";
      };
      bold_vert_split = defaultFalse "bold vertical split";
      dim_nc_background = defaultFalse "dim nc background";
      disable_background = defaultFalse "disable background";
      disable_float_background = defaultFalse "disable float background";
      disable_italics = defaultFalse "disable italics";
    };
  };
  config = mkMerge [
    (mkIf cfg.enable {
      spec = ''
        {
          "rose-pine/neovim",
          enabled = ${bool cfg.enable},
          name = "rose-pine",
          dir = "${plugins.rose-pine}",
          opts = {
            variant = "${cfg.variant}",
            bold_vert_split = ${bool cfg.bold_vert_split},
            dim_nc_background = ${bool cfg.dim_nc_background},
            disable_background = ${bool cfg.disable_background},
            disable_float_background = ${bool cfg.disable_float_background},
            disable_italics = ${bool cfg.disable_italics},
          },
        },
      '';
      preferences = ''
        vim.cmd.colorscheme "rose-pine"
      '';
    })
  ];
}
