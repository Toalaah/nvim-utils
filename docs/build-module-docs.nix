{
  pkgs ? (import <nixpkgs> {}),
  traceModules ? true,
  ...
}: let
  inherit (pkgs) lib;
  evalModule = import ../lib/evalModule {inherit lib;};
  modules = import ../modules;

  # TODO: this is also in root flake, outsource to lib
  recurseAttrValuesToList = list:
    builtins.map (
      v:
        if builtins.typeOf v == "set"
        then recurseAttrValuesToList (lib.attrValues v)
        else v
    )
    list;

  x = lib.attrsets.mapAttrsRecursive (path: value: lib.strings.concatStringsSep "/" path) modules;
  y = lib.flatten (recurseAttrValuesToList (lib.attrValues x));

  moduleList = lib.flatten (recurseAttrValuesToList (lib.attrValues modules));

  maybeTrace =
    if traceModules
    then builtins.trace
    else _: x: x;

  options =
    (evalModule {
      modules = [../package/mkConfig/options.nix] ++ moduleList;
      specialArgs = {inherit pkgs;};
    })
    .options;
  mkDocs = subModule: let
    modulePath =
      if builtins.isString subModule
      then [subModule]
      else if builtins.isList subModule
      then subModule
      else throw "argument `subModule` must be a string or a list of strings";
  in
    pkgs.nixosOptionsDoc {
      # options = options.${subModule};
      options = lib.attrsets.getAttrFromPath modulePath options;
      # adapted from https://github.com/nix-community/home-manager/blob/master/docs/default.nix
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
    };
  submodules = builtins.attrNames (builtins.removeAttrs options ["_module"]);
  mkDocsCatCommand = v: let
    modulePath = builtins.filter (v: v != "core") (lib.strings.splitString "/" v);
  in ''
    mkdir -p $out/${v} && cat ${(mkDocs modulePath).optionsCommonMark} > $out/${v}/out.md
  '';
in
  maybeTrace "(module-docs-builder) detected submodules: [${lib.strings.concatStringsSep ", " y}]"
  maybeTrace "(module-docs-builder) old submodules: [${lib.strings.concatStringsSep ", " submodules}]"
  pkgs.runCommand "module-options" {} ''
    mkdir -p $out
    # construct per-module documentation files
    ${
      lib.strings.concatMapStringsSep "\n"
      mkDocsCatCommand
      y
    }
  ''
