{
  default = {
    colorschemes.tokyonight.enable = true;
    colorschemes.tokyonight.opts.style = "moon";
    postHooks = "vim.cmd.colorscheme('tokyonight')";

    treesitter.enable = true;
    treesitter.opts = {
      highlight.enable = true;
    };

    git.gitsigns.enable = true;

    lsp.lsp-config.enable = true;

    # lsp.completion.enable = true;
    # lsp.snippets.enable = true;

    lsp.null-ls.enable = true;
    lsp.null-ls.autoformat = false;

    languages.lua.enable = true;
    languages.nix.enable = true;

    lazy = {
      # TODO: this should not be overwritten. Create a module for lazy setup
      # and add warnings if user tries to specify non-default root.
      root = "/tmp/lazy";
      dev.path = "~/dev";
      lockfile = "/dev/null";
      defaults.lazy = true;
      change_detection.enabled = false;
      install.missing = false;
      performance = {
        cache.enabled = true;
        reset_packpath = false;
        # TODO: this should also not be overwritten. Or alternatively, add the
        # final drv rtp to `lazy.performance.rt.paths`
        rtp.reset = false;
        rtp.disabled_plugins = [
          "gzip"
          "matchit"
          "matchparen"
          "rplugin"
          "tarPlugin"
          "tohtml"
          "tutor"
          "zipPlugin"
        ];
      };
    };

    vim.opt.backup = false;
    vim.opt.undofile = true;
    vim.opt.clipboard = "unnamedplus";
    vim.opt.cmdheight = 0;
    vim.opt.completeopt = "menu,menuone,noselect";
    vim.opt.confirm = true;
    vim.opt.cursorline = true;
    vim.opt.diffopt = "vertical";
    vim.opt.splitright = true;
    vim.opt.splitbelow = true;
    vim.opt.expandtab = true;
    vim.opt.hidden = true;
    vim.opt.ignorecase = true;
    vim.opt.inccommand = "nosplit";
    vim.opt.incsearch = true;
    vim.opt.laststatus = 0;
    vim.opt.list = true;
    vim.opt.listchars = {
      extends = "⟩";
      nbsp = "␣";
      precedes = "⟨";
      tab = "→\\\\ ";
      trail = "•";
    };
    vim.opt.mouse = "a";
    vim.opt.number = true;
    vim.opt.relativenumber = true;
    vim.opt.scrolloff = 8;
    vim.opt.shiftwidth = 2;
    vim.opt.showbreak = "↪";
    vim.opt.showmode = false;
    vim.opt.showtabline = 0;
    vim.opt.signcolumn = "auto:2";
    vim.opt.smartcase = true;
    vim.opt.swapfile = false;
    vim.opt.tabstop = 2;
    vim.opt.termguicolors = true;
    vim.opt.timeoutlen = 250;
    vim.opt.wrap = false;
    vim.g.tex_flavor = "latex";
    vim.g.mapleader = " ";
    vim.g.editorconfig = true;
  };
}
