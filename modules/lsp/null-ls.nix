{
  config,
  lib,
  plugins,
  ...
}:
with lib; let
  cfg = config.lsp.null-ls;
  mkSourceOption = srcType:
    mkOption {
      type = types.listOf types.string;
      description = lib.mdDoc ''
        List of ${srcType} sources to enable.

        Consult the project's [documentation](https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md#${srcType})
        for available ${srcType} sources.
      '';
      default = [];
    };
  mapSources = srcType: builtins.map (x: "nls.builtins.${srcType}.${x}");
  allCodeActionSources = mapSources "code_actions" cfg.code-actions;
  allCompletionSources = mapSources "completion" cfg.completion;
  allDiagnosticSources = mapSources "diagnostics" cfg.diagnostics;
  allHoverSources = mapSources "hover" cfg.hover;
  allFormatterSources = mapSources "formatting" cfg.formatters;
  allSources =
    allCodeActionSources
    ++ allCompletionSources
    ++ allDiagnosticSources
    ++ allHoverSources
    ++ allFormatterSources;
in {
  options.lsp.null-ls = {
    enable = mkEnableOption "null-ls";
    enableAutoFormat = mkEnableOption "autoformatting";
    code-actions = mkSourceOption "code-actions";
    completion = mkSourceOption "completion";
    diagnostics = mkSourceOption "diagnostics";
    hover = mkSourceOption "hover";
    formatters = mkSourceOption "formatter";
  };
  config = mkMerge [
    (mkIf cfg.enable {
      assertions = [];
      plugins = [
        {
          slug = "jose-elias-alvarez/null-ls.nvim";
          event = ["BufReadPre" "BufNewFile"];
          dependencies = [
            {
              slug = "nvim-lua/plenary.nvim";
              src = plugins.plenary-nvim;
            }
          ];
          src = plugins.null-ls-nvim;
          name = "null-ls.nvim";
          opts = _: ''
            function()
              local nls = require("null-ls")
              return {
                root_dir = require("null-ls.utils").root_pattern("Makefile", ".git"),
                sources = {
                  ${lib.concatStringsSep ",\n" allSources}
                },

              ${lib.optionalString cfg.enableAutoFormat ''
              on_attach = function(client, bufnr)
                if client.supports_method("textDocument/formatting") then
                  vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
                  vim.api.nvim_create_autocmd("BufWritePre", {
                    group = augroup,
                    buffer = bufnr,
                    callback = function()
                      vim.lsp.buf.format({ bufnr = bufnr })
                    end,
                  })
                  end
              end,
            ''}
            }
            end
          '';
        }
      ];
      # TODO: create aucmd module
      preHooks = ''
        local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
      '';
    })
  ];
}
