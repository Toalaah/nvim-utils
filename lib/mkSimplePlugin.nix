{lib}: {
  /*
  Convenience wrapper for creating plugin modules. Note that this function
  simply returns a standard module, and as such is equivalent to you doing so.

  Type:
    mkSimplePlugin :: Attrs -> Attrs

  Example:
    myPluginSrc = pkgs.fetchFromGitHub {
      owner = "aUser";
      repo = "aRepo";
      # ...
    }

    # From inside a module, call mkSimplePlugin:

    # myModule.nix
    {pkgs, config, lib, ...}: lib.mkSimplePlugin {
      inherit config;
      plugin = myPluginSrc;
      category = [ "colorschemes" "myColorscheme"]
    }
  */
  mkSimplePlugin = {
    # the evalModules config
    config,
    # everything to do with the local plugin module
    plugin,
    # each element correspons to a level of nesting in the config. For instace,
    # `category = ["foo" "bar"]` would expose the options: `foo.bar = {...}`
    category ? [],
    derivePluginNameFunc ? (p: builtins.head (lib.strings.splitString "." p.repo)),
    # TODO
    extraPluginConfig ? (_cfg: {}),
    # TODO
    extraModuleOpts ? {},
    # TODO
    extraConfig ? {},
  }:
    with lib; let
      inherit (lib.attrsets) setAttrByPath getAttrFromPath recursiveUpdate;
      pluginName = derivePluginNameFunc plugin;
      categoryPath =
        if isString category
        then splitString "/" category
        else if isList category
        then category
        else throw "mkSimplePlugin: argument `category` must be a string or a list of strings";
      modulePath = categoryPath ++ [pluginName];
      cfg = getAttrFromPath modulePath config;
    in {
      options = setAttrByPath modulePath (extraModuleOpts
        // {
          enable = mkEnableOption (lib.mdDoc pluginName);
          src = mkOption {
            type = types.package;
            description = mdDoc "Source to use for ${pluginName}.";
            default = plugin;
          };
          opts = mkOption {
            type = types.attrs;
            default = {};
            description = mdDoc "Options to pass to ${pluginName}";
          };
        });
      config = let
        pluginSpec = recursiveUpdate (extraPluginConfig cfg) {inherit (cfg) src opts;};
      in
        mkIf (cfg.enable) (recursiveUpdate extraConfig {plugins = [pluginSpec];});
    };
}
