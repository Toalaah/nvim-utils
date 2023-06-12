{
  config,
  lib,
  ...
}: let
  allColorschemes = with builtins; attrNames (readDir (filterSource (_: type: type == "directory") ./.));
  cfg = config.colorschemes;
in {
  imports = builtins.map (x: ./${x}) allColorschemes;
  options = {
    colorschemes.default = lib.mkOption {
      type = lib.types.nullOr (lib.types.enum allColorschemes);
      default = null;
      description = lib.mdDoc ''
        The default colorscheme to set during startup
      '';
    };
  };
  config = lib.mkMerge [
    (lib.mkIf (cfg.default != null) {
      postHooks = "vim.cmd.colorscheme('${cfg.default}')";
    })
  ];
}
