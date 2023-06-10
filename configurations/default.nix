rec {
  # standard config exposed in flake's default package / app
  default = {
    colorschemes = {
      tokyonight = {
        enable = true;
        style = "moon";
      };
    };
    treesitter = {
      enable = true;
      opts = {
        highlight.enable = true;
      };
    };

    # enable general language server configs and completion setup
    lsp.lsp-config.enable = true;
    lsp.null-ls.enable = true;
    lsp.null-ls.enableAutoFormat = true;

    # enable per-language lsp-configs
    languages.nix.enable = true;
    languages.nix.opts = {nix.flake.autoArchive = false;};
    languages.lua.enable = true;

    git.gitsigns = {
      enable = true;
      current_line_blame = true;
      current_line_blame_opts = {
        virt_text = true;
        virt_text_pos = "eol";
        delay = 500;
        ignore_whitespace = false;
      };
      current_line_blame_formatter = "<author>; <author_time:%R> - <summary>";
    };

    lazy = {
      root = "/tmp/lazy";
      dev.path = "~/dev";
      defaults.lazy = true;
      checker.enabled = false;
      performance = {
        cache.enabled = true;
        reset_packpath = false;
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

    # vim = {
    #   opt = {
    #     tabstop = 2;
    #     relativenumber = true;
    #     number = true;
    #     listchars = {
    #       extends = "⟩";
    #       nbsp = "␣";
    #       precedes = "⟨";
    #       tab = "→\\\\ ";
    #       trail = "•";
    #     };
    #   };
    #   g.mapleader = " ";
    # };

    vim.opt.backup = false;
    vim.opt.undofile = true;
    vim.opt.clipboard = "unnamedplus";
    vim.opt.cmdheight = 0;
    vim.opt.completeopt = "menu,menuone,noselect";
    # vim.cmd [[set spelllang=en_us,de_de ]];
    vim.opt.confirm = true;
    vim.opt.cursorline = true;
    vim.opt.diffopt = "vertical";
    # vim.o.foldcolumn = "1";
    # vim.o.foldlevel = 99;
    # vim.o.foldlevelstart = 99;
    # vim.o.foldenable = true;
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
      # eol = "↴";
      # space = "⋅";
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

  # TODO: multiple configs for different workflows (programming / prose / devops?)
  minimal = default;
}
