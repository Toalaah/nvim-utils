{lib}: let
  mkPluginSpec = {
    src,
    slug ? "",
    dependencies ? [],
    ...
  } @ inputs: let
    extraArgs = builtins.removeAttrs inputs ["slug" "src" "dependencies"];

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
    );
  in
    attrs;
in
  mkPluginSpec
