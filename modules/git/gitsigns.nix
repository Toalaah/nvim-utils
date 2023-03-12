{
  config,
  lib,
  mkOpts,
  plugins,
  ...
}:
with lib; let
  cfg = config.git.gitsigns;
  mkDefaultTrueOption = desc:
    mkOption {
      type = types.bool;
      default = true;
      description = desc;
    };
in {
  options = {
    git.gitsigns = {
      enable = mkEnableOption "gitsigns";
      signcolumn = mkDefaultTrueOption "signcolumn";
      numhl = mkEnableOption "numhl";
      linehl = mkEnableOption "linehl";
      word_diff = mkEnableOption "word diff";
      current_line_blame = mkEnableOption "current line blame";
      current_line_blame_opts = {
        virt_text = mkDefaultTrueOption "virtual text";
        virt_text_pos = mkOption {
          type = types.enum ["eol" "overlay" "right_align"];
          default = "eol";
          description = "virtual text position";
        };
        delay = mkOption {
          type = types.int;
          default = "delay";
          description = 1000;
        };
        ignore_whitespace = mkEnableOption "ignore whitespace";
      };
      current_line_blame_formatter = mkOption {
        type = types.str;
        default = "<author>, <author_time:%Y-%m-%d> - <summary>";
        description = "current line blame";
      };
    };
  };
  config = mkMerge [
    (mkIf cfg.enable {
      plugins = [
        {
          slug = "lewis6991/gitsigns.nvim";
          src = plugins.gitsigns-nvim;
          event = "VeryLazy";
          opts = mkOpts cfg;
        }
      ];
    })
  ];
}
