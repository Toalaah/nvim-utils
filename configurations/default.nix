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
    lsp.lsp-config.enable = true;
    lsp.null-ls.enable = true;
    languages.lua.enable = true;
    languages.nix.enable = true;
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

    vim = {
      opt = {
        tabstop = 2;
        relativenumber = true;
        number = true;
        listchars = {
          extends = "⟩";
          nbsp = "␣";
          precedes = "⟨";
          tab = "→\\\\ ";
          trail = "•";
        };
      };
      g.mapleader = " ";
    };
  };

  # TODO: multiple configs for different workflows (programming / prose / devops?)
  minimal = default;
}
