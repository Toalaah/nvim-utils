{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.tools.zk;
  src = pkgs.fetchFromGitHub {
    owner = "mickael-menu";
    repo = "zk-nvim";
    rev = "797618aa07f58ceba6f79fb6e777e8e45c51e1ce";
    hash = "sha256-vQPDMxl56Hk90sumb7LecdvHJxSmtX/UiwfyO+CYIcM=";
  };
in {
  options = {
    tools.zk = {
      enable = mkEnableOption (lib.mdDoc "zk");
      src = mkOption {
        type = types.package;
        description = lib.mdDoc ''
          Source to use for this plugin. This allows you to swap out the pinned
          version with a newer revision/fork or add patches by creating a
          wrapper derivation.
        '';
        default = src;
      };
      opts = mkOption {
        description = lib.mdDoc ''
          Additional options passed to zk.

          Consult the project's [documentation](https://github.com/mickael-menu/zk-nvim)
          for all available options.
        '';
        type = types.attrsOf types.anything;
        default = {};
      };
    };
  };
  config = mkMerge [
    (mkIf cfg.enable {
      treesitter.parsers = ["markdown"];

      extraPackages = [pkgs.zk pkgs.fzf];

      lsp.lsp-config.serverConfigurations.zk = {
        cmd = ["${pkgs.zk}/bin/zk"];
      };

      plugins = [
        {
          main = "zk";
          ft = ["markdown"];
          inherit (cfg) src opts;
        }
      ];
    })
  ];
}
