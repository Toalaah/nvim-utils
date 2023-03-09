rec {
  # standard config exposed in flake's default package / app
  default = {
    colorschemes = {
      tokyonight = {
        enable = true;
        style = "moon";
      };
    };
  };

  # TODO: multiple configs for different workflows (programming / prose / devops?)
  minimal = default;
}
