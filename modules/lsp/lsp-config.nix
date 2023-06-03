{
  config,
  lib,
  plugins,
  ...
}:
with lib; let
  cfg = config.lsp.lsp-config;
in {
  options.lsp.lsp-config.enable = mkEnableOption "lsp-config";
  config = mkMerge [
    (mkIf cfg.enable {
      assertions = [];
      plugins = [
        {
          slug = "neovim/nvim-lspconfig.nvim";
          event = ["BufReadPre" "BufNewFile"];
          src = plugins.nvim-lspconfig;
        }
      ];
    })
  ];
}
