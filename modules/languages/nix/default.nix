{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.languages.nix;
in {
  options = {
    languages.nix = {
      enable = mkEnableOption "nix";
      autoEnableLsp = mkOption {
        description = lib.mdDoc "lsp features for nix. This implies enabling `lsp.lsp-config`";
        type = types.bool;
        default = true;
      };
      settings = mkOption {
        type = types.attrsOf types.anything;
        default = {};
        description = lib.mdDoc ''
          Additional options passed to nix-lsp.

          Consult the project's [documentation](https://github.com/oxalica/nil/blob/main/docs/configuration.md)
          for all available options.
        '';
      };
    };
  };
  config = mkMerge [
    (mkIf (cfg.enable && cfg.autoEnableLsp) {
      lsp.lsp-config.enable = true;
    })
    (mkIf cfg.enable {
      assertions = [];
      plugins = [];
      treesitter.parsers = ["nix"];
      lsp.null-ls.formatters = ["alejandra"];
      lsp.null-ls.diagnostics = ["deadnix"];
      extraPackages = [pkgs.alejandra pkgs.deadnix];
      rtp = [./ftdetect];
      lsp.lsp-config.serverConfigurations.nil_ls = {
        cmd = ["${pkgs.nil}/bin/nil"];
        inherit (cfg) settings;
      };
    })
  ];
}
