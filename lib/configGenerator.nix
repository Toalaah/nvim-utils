{lib}: {
  configuration,
  plugins,
}:
lib.evalModules {
  specialArgs = {inherit plugins;};
  modules = [
    ../modules
    {
      options = {
        spec = lib.mkOption {
          type = lib.types.str;
          description = ''Combined plugin spec passed to lazy.nvim'';
          default = "{}";
        };
        preferences = lib.mkOption {
          type = lib.types.str;
          description = ''
            Vim preferences / commands to execute after lazy.nvim startup, separated by '\n'
          '';
          example = ''
            vim.opt.leader = ""
          '';
          default = "";
        };
      };
    }
    configuration
  ];
}
