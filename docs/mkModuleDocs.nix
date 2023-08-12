{
  pkgs ? (import <nixpkgs> {}),
  traceModules ? true,
  ...
}: let
  inherit (pkgs) lib;

  evalModule = import ../lib/evalModule {
    lib = lib.extend (_: prev: (import ../lib {lib = prev;}) // prev);
  };

  maybeTrace =
    if traceModules
    then builtins.trace
    else _: x: x;

  recurseAttrValuesToList = v: let
    recurseAttrValuesToList' = list:
      builtins.map (
        v:
          if builtins.typeOf v == "set"
          then recurseAttrValuesToList' (lib.attrValues v)
          else v
      )
      list;
  in
    lib.lists.flatten (recurseAttrValuesToList' (builtins.attrValues v));

  options =
    (evalModule {
      modules = recurseAttrValuesToList (import ../modules);
      specialArgs = {inherit pkgs;};
    })
    .options;

  moduleCategories = builtins.attrNames (builtins.removeAttrs options ["_module"]);

  # adapted from https://github.com/nix-community/home-manager/blob/master/docs/default.nix
  mkDocs = subModule: let
    modulePath =
      if builtins.isString subModule
      then [subModule]
      else if builtins.isList subModule
      then subModule
      else throw "argument `subModule` must be a string or a list of strings";
  in
    (pkgs.nixosOptionsDoc {
      options = lib.attrsets.getAttrFromPath modulePath options;
      transformOptions = let
        gitHubDeclaration = user: repo: subpath: let
          urlRef = "master";
        in {
          url = "https://github.com/${user}/${repo}/blob/${urlRef}/${subpath}";
          name = "<${repo}/${subpath}>";
        };
        root = toString ./..;
      in
        opt:
          opt
          // {
            declarations = map (decl:
              if lib.hasPrefix root (toString decl)
              then
                gitHubDeclaration "toalaah" "nvim-utils"
                (lib.removePrefix "/" (lib.removePrefix root (toString decl)))
              else if decl == "lib/modules.nix"
              then gitHubDeclaration "NixOS" "nixpkgs" decl
              else decl)
            opt.declarations;
          };
    })
    .optionsCommonMark;
in
  maybeTrace "(module-docs-builder) generating documentation for categories: [${lib.strings.concatStringsSep ", " moduleCategories}]"
  pkgs.runCommand "module-options" {} ''
    mkdir -p $out
    ${
      # construct per-module documentation files
      lib.strings.concatMapStringsSep "\n"
      (v: ''
        cat ${mkDocs v} > $out/${v}.md
      '')
      moduleCategories
    }
  ''
