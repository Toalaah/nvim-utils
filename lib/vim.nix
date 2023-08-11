{
  lib,
  toLua,
}: rec {
  # TODO: not a public function, move to core module and use as part of option =>
  # cfg generation.
  /*
  processes each vim namespace (for example `vim.g` or `vim.o`) into
  stringified lua code
  */
  processVimPrefs = ns: values:
    lib.strings.concatStringsSep "\n"
    (
      lib.mapAttrsToList
      (name: value: "vim.${ns}.${name} = ${toLua value}")
      values
    );

  /*
  Creates a lua keymap. Note that `opts` may be omitted when using this
  function. Although this results in a curried function, the internal keymap
  module takes care of this by automatically adding an empty option set at
  eval-time (see `modules/core/keymap.nix`).
  */
  mkKeymap = mode: lhs: rhs: opts: {inherit mode lhs rhs opts;};

  nmap = mkKeymap "n";
  nnoremap = lhs: rhs: opts: nmap lhs rhs (opts // {noremap = true;});

  vmap = mkKeymap "v";
  vnoremap = lhs: rhs: opts: vmap lhs rhs (opts // {noremap = true;});

  imap = mkKeymap "i";
  inoremap = lhs: rhs: opts: imap lhs rhs (opts // {noremap = true;});

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
