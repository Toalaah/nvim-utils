{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  inherit (lib.lua) rawLua;
  cfg = config.lsp.null-ls;
  src = pkgs.fetchFromGitHub {
    owner = "jose-elias-alvarez";
    repo = "null-ls.nvim";
    rev = "a138b14099e9623832027ea12b4631ddd2a49256";
    hash = "sha256-N8TlKUq9fGzlYaGtOVDE1A40AVoE6vQlM9J1P2WA+sk=";
  };
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
  imports = [../util/plenary.nix];
  options.lsp.null-ls = {
    enable = mkEnableOption (lib.mdDoc "null-ls");
    src = mkOption {
      type = types.package;
      description = lib.mdDoc ''
        Source to use for this plugin. This allows you to swap out the pinned
        version with a newer revision/fork or add patches by creating a
        wrapper derivation.
      '';
      default = src;
    };
    autoformat = mkEnableOption (lib.mdDoc "autoformatting");
    code-actions = mkSourceOption "code-actions";
    completion = mkSourceOption "completion";
    diagnostics = mkSourceOption "diagnostics";
    hover = mkSourceOption "hover";
    formatters = mkSourceOption "formatter";
  };
  config = mkMerge [
    (mkIf cfg.enable {
      util.plenary.enable = true;
      plugins = [
        {
          slug = "jose-elias-alvarez/null-ls.nvim";
          event = ["BufReadPre" "BufNewFile"];
          inherit (cfg) src;
          dependencies = [config.util.plenary.slug];
          name = "null-ls.nvim";
          opts = rawLua ''
            function()
              local nls = require("null-ls")
              return {
                debounce = 150,
                root_dir = require("null-ls.utils").root_pattern("Makefile", ".git"),
                sources = {
                  ${lib.concatStringsSep ",\n" allSources}
                },

              ${lib.optionalString cfg.autoformat ''
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
      preHooks = lib.optionalString cfg.autoformat ''
        local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
      '';
    })
  ];
}
