rec {
  # default config exposed in flake's default package / app
  default = {
    colorschemes = {
      rose-pine = {
        enable = false;
        variant = "moon";
      };
      tokyonight = {
        enable = true;
        style = "moon";
      };
    };
  };

  # TODO: multiple configs for different workflows (programming / prose / devops?)
  minimal = default;
}
