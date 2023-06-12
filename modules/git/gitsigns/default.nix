{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.git.gitsigns;
  src = pkgs.fetchFromGitHub {
    owner = "lewis6991";
    repo = "gitsigns.nvim";
    rev = "4455bb5364d29ff86639dfd5533d4fe4b48192d4";
    hash = "sha256-DmbtKxU/tyFzIUNzoKvtsqlucdINYCSePzLiV7LLGn4=";
  };
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
            description = "delay";
            default = 1000;
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
  };
  config = mkMerge [
    (mkIf cfg.enable {
      plugins = [
        {
          event = "VeryLazy";
          inherit (cfg) src opts;
        }
      ];
    })
  ];
}