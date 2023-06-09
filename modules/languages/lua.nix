{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.languages.lua;
in {
  options = {
    languages.lua = {
      enable = mkEnableOption "lua";
      opts = {
      };
    };
  };
  config = mkMerge [
    (mkIf cfg.enable {
      assertions = [];
      plugins = [];
      treesitter.parsers = ["lua"];
      lsp.null-ls.formatters = ["stylua"];
      lsp.null-ls.diagnostics = ["selene"];
      extraPackages = [pkgs.stylua pkgs.selene];
      postHooks = lib.optionalString config.lsp.lsp-config.enable ''
        require('lspconfig').lua_ls.setup {
            cmd = { "${pkgs.lua-language-server}/bin/lua-language-server" },
            settings = {
              single_file_support = true,
              Lua = {
                semantic = { enable = false },
                diagnostics = {
                globals = { 'vim' },
                unusedLocalExclude = { '_*' },
                },
              },
            },
          }
      '';
    })
  ];
}
