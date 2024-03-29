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
      enable = mkEnableOption (lib.mdDoc "nix LSP features / additional language tooling.");
      settings = mkOption {
        type = types.attrs;
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
    (mkIf cfg.enable {
      treesitter.parsers = ["nix"];
      rtp = [./ftdetect];

      lsp.lsp-config.servers.nil_ls = {
        cmd = ["${pkgs.nil}/bin/nil"];
        extraOpts = {inherit (cfg) settings;};
      };
    })
  ];
}
