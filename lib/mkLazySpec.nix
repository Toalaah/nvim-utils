{lib}: let
  mkLazySpec = {
    pluginSlug,
    src,
    ...
  } @ inputs: let
    mkLuaTable = import ./stringifyAttrSet.nix {inherit lib;};
    isExtraArg = x: _: !(builtins.elem x ["pluginSlug" "src"]);
    extraArgs = lib.filterAttrs isExtraArg inputs;
    attrs = (
      {
        __index__ = pluginSlug;
        dir = src;
      }
      // extraArgs
    );
  in
    mkLuaTable attrs;
in
  mkLazySpec
