{lib}: let
  mkPluginSpec = {
    src,
    slug ? "",
    keys ? [],
    dependencies ? [],
    ...
  } @ inputs: let
    extraArgs = builtins.removeAttrs inputs ["src" "slug" "keys" "dependencies"];

    tryGetSlug = src:
      if !(builtins.isAttrs src && builtins.hasAttr "owner" src && builtins.hasAttr "repo" src)
      then
        throw ''
          Failed to compute slug. Either pass a `slug` parameter manually or pass
          a src which has an `owner`, `repo`, and `outPath` attribute (for
          example, pkgs.fetchFromGitHub).
        ''
      else "${src.owner}/${src.repo}";

    slug' =
      if slug != ""
      then slug
      else tryGetSlug src;

    keys' =
      if (builtins.length keys > 0)
      then (import ./mkKeyBindings.nix) keys
      else {};

    dependencies' = lib.filterAttrs (_: v: v != []) {
      dependencies = builtins.map (p:
        if builtins.isString p
        then p
        else mkPluginSpec p)
      dependencies;
    };

    attrs = (
      {__index__ = slug';}
      // extraArgs
      // dependencies'
      // keys'
    );
  in
    attrs;
in
  mkPluginSpec
