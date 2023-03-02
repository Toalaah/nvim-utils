{
  config,
  lib,
  plugins,
  ...
}:
with lib; let
  cfg = config.colorschemes.tokyonight;
  bool = x: lib.boolToString x;
in {
  options = {
    colorschemes.tokyonight = {
      enable = mkEnableOption "tokyonight";
      style = mkOption {
        description = "variant of tokyonight to use";
        type = types.enum ["day" "moon" "night" "storm"];
        default = "moon";
      };
    };
  };
  config = mkMerge [
    (mkIf cfg.enable {
      spec = ''
        {
          "folke/tokyonight.nvim",
          enabled = ${bool cfg.enable},
          name = "tokyonight",
          dir = "${plugins.tokyonight-nvim}",
          opts = { style = "${cfg.style}" },
        },
      '';
      preferences = ''
        vim.cmd.colorscheme "tokyonight"
      '';
    })
  ];
}
