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
      assertions = [
        {
          assertion = !config.colorschemes.rose-pine.enable;
          message = "only one colorscheme should be enabled at any time";
        }
      ];
      plugins = [
        {
          slug = "folke/tokyonight.nvim";
          enabled = true;
          name = "tokyonight";
          src = plugins.tokyonight-nvim;
          opts = {style = "${cfg.style}";};
        }
      ];
      postHooks = "vim.cmd.colorscheme('tokyonight')";
    })
  ];
}
