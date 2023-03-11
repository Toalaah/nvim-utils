{
  config,
  lib,
  plugins,
  ...
}:
with lib; let
  cfg = config.colorschemes.tokyonight;
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
      plugins = [
        {
          slug = "folke/tokyonight.nvim";
          enabled = true;
          name = "tokyonight";
          src = plugins.tokyonight-nvim;
          opts = {style = "${cfg.style}";};
        }
      ];
      preferences = [
        ''
          vim.cmd.colorscheme "tokyonight"
        ''
      ];
    })
  ];
}
