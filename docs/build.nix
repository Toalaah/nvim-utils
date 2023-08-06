{
  lib,
  mdbook,
  mdbook-cmdrun,
  nix,
  nixdoc,
  pkgs,
  runCommand,
  stdenv,
  writeShellScriptBin,
  ...
}: let
  nixdoc-to-md = writeShellScriptBin "nixdoc-to-md.sh" (builtins.readFile ./nixdoc-to-md.sh);
  module-docs = import ./build-module-docs.nix {inherit pkgs;};
  options-to-md = writeShellScriptBin "options-to-md.sh" ''
    [ -z "$1" ] && echo "Usage: $0 <module>" >&2  && exit 1
    cat ${module-docs}/$1/out.md
  '';
in
  stdenv.mkDerivation {
    name = "documentation";
    version = "1.0.0";

    # we rely on the entire project for building documentation
    src = ../.;

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
      export LIB=$(pwd)/lib
      cd docs
      mkdir -p $out
      mdbook build --dest-dir $out
    '';
  }
