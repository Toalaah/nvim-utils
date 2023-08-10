{pkgs ? (import (builtins.fetchTarball "https://github.com/NixOS/nixpkgs/archive/c2596b396ca0a0d9f82fa6e64839b37473008a58.tar.gz") {})}: let
  inherit (pkgs) mdbook mdbook-cmdrun nixdoc stdenv writeShellScriptBin;
  nixdoc-to-md = writeShellScriptBin "nixdoc-to-md.sh" (builtins.readFile ./nixdoc-to-md.sh);
  moduleDocs = import ./mkModuleDocs.nix {inherit pkgs; traceModules = false;};
  options-to-md = writeShellScriptBin "options-to-md.sh" ''
    [ -z "$1" ] && echo "Usage: $0 <module>" >&2 && exit 1
    cat ${moduleDocs}/$1.md
  '';
in
  stdenv.mkDerivation {
    name = "documentation";

    src = ./.;

    buildInputs = [
      mdbook
      mdbook-cmdrun
      nixdoc
      nixdoc-to-md
      options-to-md
    ];

    dontInstall = true;
    dontPatch = true;
    dontConfigure = true;

    buildPhase = ''
      export LIB=${../lib}
      export MDBOOK_ROOT=$(pwd)
      mkdir -p $out
      mdbook build --dest-dir $out
    '';

  }
