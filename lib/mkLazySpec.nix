{lib}: let
  mkLazySpec = {
    pluginSlug,
    src,
    ...
  } @ inputs: let
    isExtraArg = x: _: !(builtins.elem x ["pluginSlug" "src"]);
    extraArgs = lib.filterAttrs isExtraArg inputs;
    attrs = (
      {
        __index__ = pluginSlug;
        dir =
          if lib.isString src
          then src
          else src.outPath;
      }
      // extraArgs
    );
  in
    attrs;
in
  mkLazySpec
