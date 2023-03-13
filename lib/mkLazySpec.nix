{lib}: let
  mkLazySpec = {
    slug,
    src,
    name ? null,
    ...
  } @ inputs: let
    isExtraArg = x: _: !(builtins.elem x ["slug" "src"]);
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
    );
  in
    attrs;
in
  mkLazySpec
