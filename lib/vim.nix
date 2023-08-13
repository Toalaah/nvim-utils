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
    # The top-level config you have access to in your module.
    config,
    # The plugin source (for instance a source produced by `pkgs.fetchFromGitHub`).
    plugin,
    # The path to expose your module options under. Each element correspons to
    # a level of nesting in the config. For instace, `category = ["foo" "bar"]`
    # would expose the options: `foo.bar = {...}`. You may also pass a string
    # where each nested level is separated by a `/`. For instance, `"foo/bar"` is
    # equivalent to the example above.
    category ? [],
    # A function to derive the plugin name from the plugin source. The default
    # implementation uses the `repo` attribute from `plugin` (assumes structure
    # similar to a source produced by `fetchFromGitHub`). The input to this
    # function is `plugin`. The output must be a string.
    derivePluginNameFunc ? (p: builtins.head (lib.strings.splitString "." p.repo)),
    # The name of the plugin to use in the module options. By default, the
    # implmentation uses the result of `derivePluginNameFunc` to derive the
    # option namespace from the plugin source.
    moduleName ? null,
    # Extra options to pass to the lazy plugin spec. The function receives the
    # plugin config at evaluation time as its only input. The output must be an
    # attribute set, which is merged with the final spec. Any options which are
    # accepted by layz's plugin spec should be valid.
    extraPluginConfig ? (_cfg: {}),
    # Omit the `opt` options from the final module as well as the plugin spec.
    # You may want to use this if the plugin which you specify does not support
    # a conventional `setup()` function, for example a vimscript plugin which
    # simply gets loaded.
    noSetup ? false,
    # Any extra module options to generate for this module. Standard
    # option-conventions apply.
    extraModuleOpts ? {},
    # Extra `config` to generate for this module if it is enabled. This is
    # merged with the final config. You may, for example, use this to set
    # additional pre/post-hooks or set keymaps, etc.
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
      moduleName =
        if moduleName == null
        then pluginName
        else moduleName;
      modulePath = categoryPath ++ [moduleName];
      cfg = getAttrFromPath modulePath config;
    in {
      options = setAttrByPath modulePath (extraModuleOpts
        // {
          enable = mkEnableOption (lib.mdDoc pluginName);
          src = mkOption {
            type = types.package;
            description = mdDoc "Source to use for `${pluginName}`.";
            default = plugin;
          };
        }
        // (
          if noSetup
          then {}
          else {
            opts = mkOption {
              type = types.attrs;
              default = {};
              description = mdDoc "Options to pass to `${pluginName}`.";
            };
          }
        ));
      config = let
        pluginSpec =
          recursiveUpdate
          (extraPluginConfig cfg)
          {inherit (cfg) src;}
          // (
            if noSetup
            then {}
            else {inherit (cfg) opts;}
          );
      in
        mkIf (cfg.enable) (recursiveUpdate extraConfig {plugins = [pluginSpec];});
    };
}
