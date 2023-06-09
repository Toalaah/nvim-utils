{lib}: let
  mkPluginSpec = {
    slug,
    src,
    name ? null,
    dependencies ? [],
    ...
  } @ inputs: let
    isExtraArg = x: _: !(builtins.elem x ["slug" "src" "dependencies"]);
    extraArgs = lib.filterAttrs isExtraArg inputs;
    # extract name from slug if not explicitly passed
    name' =
      if name != null
      then name
      else (builtins.elemAt (lib.strings.splitString "/" slug) 1);
    attrs = (
      {
        __index__ = slug;
        dir =
          if lib.isString src
          then src
          else src.outPath;
        name = name';
      }
      // extraArgs
      // (lib.filterAttrs (_: v: v != []) { dependencies = builtins.map mkPluginSpec dependencies; })
    );
  in
    attrs;
in
  mkPluginSpec
