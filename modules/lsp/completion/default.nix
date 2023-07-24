{
  config,
  lib,
  pkgs,
  rawLua,
  ...
}:
with lib; let
  sources = builtins.mapAttrs (_: v: pkgs.fetchFromGitHub (v // {name = v.repo;})) (import ./sources.nix);
in {
  config = mkMerge [
    (mkIf config.lsp.lsp-config.enable {
      assertions = [];
      plugins = [
        {
          event = ["InsertEnter" "CmdLineEnter"];
          src = sources.nvim-cmp;
          config = rawLua ''
            function(_, opts)
              local cmp = require('cmp')
              cmp.setup(opts)
              -- use cmdline & path source for ':'
              cmp.setup.cmdline({ ':' }, {
                mapping = cmp.mapping.preset.cmdline(),
                sources = cmp.config.sources({
                  { name = 'async_path', max_item_count = 8, },
                  { name = 'cmdline', max_item_count = 8, },
                }),
              })
            end
          '';
          opts = rawLua ''
            function()
              local cmp = require('cmp')
              return {
                completion = {
                  completeopt = "menu,menuone,noinsert",
                  autocomplete = {
                    cmp.TriggerEvent.TextChanged,
                    cmp.TriggerEvent.InsertEnter,
                  },
                },
                -- TODO: snippets
                snippet = {},
                -- enable for modifiable buffers only
                enabled = function()
                  local is_prompt = vim.api.nvim_buf_get_option(0, 'buftype') == 'prompt'
                  local is_modifiable = vim.api.nvim_buf_get_option(0, 'modifiable')
                  return not is_prompt and is_modifiable
                end,

                mapping = cmp.mapping.preset.insert({
                  ["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
                  ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
                  ["<C-b>"] = cmp.mapping.scroll_docs(-4),
                  ["<C-f>"] = cmp.mapping.scroll_docs(4),
                  ["<C-Space>"] = cmp.mapping.complete(),
                  ["<C-e>"] = cmp.mapping.abort(),
                  ["<CR>"] = cmp.mapping.confirm({
                    behavior = cmp.ConfirmBehavior.Replace,
                    select = false,
                  }),
                }),

                sources = {
                  { name = 'nvim_lsp' },
                  { name = 'nvim_lua' },
                  { name = 'async_path', max_item_count = 10, },
                  { name = 'buffer', keyword_length = 3, max_item_count = 10, },
                },
                window = {
                  completion = cmp.config.window.bordered(),
                  documentation = cmp.config.window.bordered(),
                },
                experimental = {
                  ghost_text = true
                },
              }
            end
          '';
          dependencies = [
            {src = sources.cmp-nvim-lsp;}
            {src = sources.cmp-nvim-lua;}
            {src = sources.cmp-buffer;}
            {src = sources.cmp-cmdline;}
            {src = sources.cmp-async-path;}
          ];
        }
      ];
    })
  ];
}
