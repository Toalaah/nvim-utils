{
  pkgs,
  lib,
  ...
}: let
  inherit (lib.vim) nnoremap inoremap;
  inherit (lib.lua) rawLua;
in {
  treesitter = {
    enable = true;
    opts.highlight.enable = true;
    parsers = ["vim" "c" "terraform" "nix"];
    # test overriding default src
    src = pkgs.fetchFromGitHub {
      owner = "nvim-treesitter";
      repo = "nvim-treesitter";
      rev = "fa414da96f4a2e60c2ac8082f0c1802b8f3c8f6c";
      sha256 = "sha256-CZGCFh32Zs9ZDk8g1KN51PyFdOi8Xm95vcHOiakA5wg=";
    };
  };

  colorschemes.gruvbox.enable = true;
  colorschemes.gruvbox.opts.transparent_mode = true;
  postHooks = ''
    vim.cmd.colorscheme 'gruvbox'
  '';

  languages.lua.enable = true;
  lsp.lsp-config.enable = true;

  vim.g.mapleader = " ";

  vim.opt.number = true;
  vim.opt.relativenumber = true;
  vim.opt.shiftwidth = 2;
  vim.opt.wrap = false;
  vim.opt.smartcase = true;
  vim.opt.swapfile = false;
  vim.opt.tabstop = 2;

  rtp = [./lua];

  keymaps = let
    printFib = rawLua ''
      function()
        local n = vim.fn.input("N: ", "")
        print(n)
        if n then
          local fib = require('test').fib
          print(fib(tonumber(n)))
        end
      end
    '';
  in [
    (nnoremap "<leader>o" ":lua print('test keymap')<CR>")
    (nnoremap "<leader>p" printFib)
    (inoremap "jk" "<esc>" {
      silent = true;
      desc = "Quick-escape from insert mode";
    })
  ];

  autocmds = let
    highlightOnYank = rawLua ''
      function()
        vim.highlight.on_yank { higroup = "IncSearch", timeout = 500 }
      end
    '';
  in [
    {
      event = "TextYankPost";
      pattern = ["*"];
      callback = highlightOnYank;
      description = "Highlight copied content after yank";
    }
  ];
}
