{
  config,
  lib,
  pkgs,
  rawLua,
  toLua,
  ...
}:
with lib; let
  src = pkgs.fetchFromGitHub {
    owner = "hrsh7th";
    repo = "nvim-cmp";
    rev = "b8c2a62b3bd3827aa059b43be3dd4b5c45037d65";
    hash = "sha256-mGRJy5fmGEuJD9jJhNNIW+J7juWPBLqHwlD81di/A/Y=";
  };
in {
  config = mkMerge [
    (mkIf config.lsp.lsp-config.enable {
      assertions = [];
      plugins = [
        {
          event = ["InsertEnter" "CmdLineEnter"];
          inherit src;
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
            {
              src = pkgs.fetchFromGitHub {
                owner = "hrsh7th";
                repo = "cmp-nvim-lsp";
                rev = "0e6b2ed705ddcff9738ec4ea838141654f12eeef";
                hash = "sha256-DxpcPTBlvVP88PDoTheLV2fC76EXDqS2UpM5mAfj/D4=";
              };
            }
            {
              src = pkgs.fetchFromGitHub {
                owner = "hrsh7th";
                repo = "cmp-nvim-lua";
                rev = "f12408bdb54c39c23e67cab726264c10db33ada8";
                hash = "sha256-6eXOK1mVK06TN1akhN42Bo4wQpeen3rk3b/m7iVmGKM=";
              };
            }
            {
              src = pkgs.fetchFromGitHub {
                owner = "hrsh7th";
                repo = "cmp-buffer";
                rev = "3022dbc9166796b644a841a02de8dd1cc1d311fa";
                hash = "sha256-dG4U7MtnXThoa/PD+qFtCt76MQ14V1wX8GMYcvxEnbM=";
              };
            }
            {
              src = pkgs.fetchFromGitHub {
                owner = "hrsh7th";
                repo = "cmp-cmdline";
                rev = "8ee981b4a91f536f52add291594e89fb6645e451";
                hash = "sha256-W8v/XhPjbvKSwCrfOAPihO2N9PEVnH5Cp/Fa25lNRw4=";
              };
            }
            {
              src = pkgs.fetchFromGitHub {
                owner = "felipelema";
                repo = "cmp-async-path";
                rev = "d8229a93d7b71f22c66ca35ac9e6c6cd850ec61d";
                hash = "sha256-dgAiVbdMiKjiKWk+dJf/Zz8T20+D4OalGH5dTzYi5aM=";
              };
            }
          ];
        }
      ];
    })
  ];
}
