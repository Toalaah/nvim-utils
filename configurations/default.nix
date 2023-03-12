rec {
  # standard config exposed in flake's default package / app
  default = {
    colorschemes = {
      tokyonight = {
        enable = true;
        style = "moon";
      };
    };

    lazy = {
      dev.path = "~/dev";
      defaults.lazy = true;
      checker.enabled = false;
      performance.cache.enabled = true;
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

    vim = {
      opt = {
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
