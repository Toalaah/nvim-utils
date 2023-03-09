{lib}: let
  mkLazySpec = {
    slug,
    src,
    ...
  } @ inputs: let
    isExtraArg = x: _: !(builtins.elem x ["slug" "src"]);
    extraArgs = lib.filterAttrs isExtraArg inputs;
    attrs = (
      {
        __index__ = slug;
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
