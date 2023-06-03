{
  config,
  lib,
  plugins,
  ...
}:
with lib; let
  cfg = config.lsp.null-ls;
in {
  options.lsp.null-ls.enable = mkEnableOption "null-ls";
  config = mkMerge [
    (mkIf cfg.enable {
      assertions = [];
      plugins = [
        {
          slug = "jose-elias-alvarez/null-ls.nvim";
          event = ["BufReadPre" "BufNewFile"];
          # TODO: recurse into dependencies and turn attrset to lazy-compatible
          # table in order to allow for same syntax-sugar as in parent plugin
          # declaration
          dependencies = [
            {
              __index__ = "nvim-lua/plenary.nvim";
              name = "plenary.nvim";
              dir = builtins.toString plugins.plenary-nvim;
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
                  nls.builtins.formatting.stylua,
                },
              }
            end
          '';
        }
      ];
    })
  ];
}
