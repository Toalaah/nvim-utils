{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.languages.rust;
in {
  options = {
    languages.rust = {
      enable = mkEnableOption (lib.mdDoc "rust LSP features / additional language tooling.");
      settings = mkOption {
        type = types.attrs;
        default = {};
        description = lib.mdDoc ''
          Additional options passed to rust-lsp.

          Consult the project's [documentation](https://github.com/oxalica/nil/blob/main/docs/configuration.md)
          for all available options.
        '';
      };
    };
  };
  config = mkMerge [
    (mkIf cfg.enable {
      treesitter.parsers = ["rust"];

      lsp.lsp-config.servers.rust_analyzer = {
        cmd = ["${pkgs.rust-analyzer}/bin/rust-analyzer"];
        extraOpts = {inherit (cfg) settings;};
      };
    })
  ];
}
