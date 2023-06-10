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
        # lsp-config
        {
          slug = "neovim/nvim-lspconfig.nvim";
          event = ["BufReadPre" "BufNewFile"];
          src = plugins.nvim-lspconfig;
          dependencies = [
            {
              slug = "hrsh7th/cmp-nvim-lsp";
              src = plugins.cmp-nvim-lsp;
            }
            {
              slug = "whynothugo/lsp_lines.nvim";
              src = plugins.lsp_lines;
              config = _: ''
                function()
                  require('lsp_lines').setup()
                  vim.diagnostic.config({
                    virtual_text = false,
                    virtual_lines = {
                      highlight_whole_line = false,
                    },
                  })
                end
              '';
              keys = [
                {
                  __index__a = "<Leader>l";
                  __index__b = _: ''
                    function()
                      require('lsp_lines').toggle()
                    end
                  '';
                  mode = "n";
                  desc = "Toggle LSP diagnostic virtual lines";
                }
              ];
            }
          ];
        }
        # completion
        {
          slug = "hrsh7th/nvim-cmp";
          event = ["InsertEnter" "CmdLineEnter"];
          src = plugins.nvim-cmp;
          config = _: ''
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
          opts = _: ''
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
                snippet = {
                  expand = function(args)
                    require('luasnip').lsp_expand(args.body)
                  end,
                },
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

                sources = cmp.config.sources({
                  { name = 'nvim_lsp' },
                  { name = 'nvim_lua' },
                  { name = 'luasnip' },
                  { name = 'async_path', max_item_count = 10, },
                  { name = 'buffer', keyword_length = 3, max_item_count = 10, },
                }),
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
            {
              slug = "hrsh7th/cmp-nvim-lsp";
              src = plugins.cmp-nvim-lsp;
            }
            {
              slug = "hrsh7th/cmp-nvim-lua";
              src = plugins.cmp-nvim-lua;
            }
            {
              slug = "hrsh7th/cmp-buffer";
              src = plugins.cmp-buffer;
            }
            {
              slug = "hrsh7th/cmp-cmdline";
              src = plugins.cmp-cmdline;
            }
            {
              slug = "felipelema/cmp-asyncpath";
              src = plugins.cmp-async-path;
            }
            {
              slug = "saadparwaiz1/cmp_luasnip";
              src = plugins.cmp_luasnip;
            }
          ];
        }
        # snippets
        {
          slug = "L3MON4D3/LuaSnip";
          src = plugins.luasnip;
          dependencies = [
            {
              slug = "rafamadriz/friendly-snippets";
              src = plugins.friendly-snippets;
              config = _: ''
                function()
                  require("luasnip.loaders.from_vscode").lazy_load()
                end
              '';
            }
          ];
          opts = {
            history = true;
            delete_check_events = "TextChanged";
          };
          keys = [
            {
              __index__a = "<tab>";
              __index__b = _: ''
                function()
                  return require('luasnip').jumpable(1) and '<Plug>luasnip-jump-next' or '<tab>'
                end
              '';
              expr = true;
              silent = true;
              mode = "i";
            }
            {
              __index__a = "<tab>";
              __index__b = _: "function() require('luasnip').jump(1) end";
              mode = "s";
            }
            {
              __index__a = "<s-tab>";
              __index__b = _: "function() require('luasnip').jump(-1) end";
              mode = ["i" "s"];
            }
          ];
        }
      ];
    })
  ];
}
