{
  config,
  lib,
  pkgs,
  toLua,
  ...
}:
with lib; let
  cfg = config.languages.nix;
in {
  options = {
    languages.nix = {
      enable = mkEnableOption "nix";
      opts = mkOption {
        description = lib.mdDoc ''
          Additional options passed to nix-lsp.

          Consult the project's [documentation](https://github.com/oxalica/nil/blob/main/docs/configuration.md)
          for all available options.
        '';
        type = types.attrsOf types.anything;
        default = {};
      };
    };
  };
  config = mkMerge [
    (mkIf cfg.enable {
      assertions = [];
      plugins = [];
      treesitter.parsers = ["nix"];
      lsp.null-ls.formatters = ["alejandra"];
      lsp.null-ls.diagnostics = ["deadnix"];
      extraPackages = [ pkgs.alejandra pkgs.deadnix ];
      postHooks = lib.optionalString config.lsp.lsp-config.enable ''
        require('lspconfig').nil_ls.setup {
          cmd = { "${pkgs.nil}/bin/nil" },
          settings = {
            ['nil'] = ${toLua cfg.opts}
          },
        }
      '';
    })
  ];
}
