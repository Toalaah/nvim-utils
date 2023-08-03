{
  lib,
  mdbook,
  stdenv,
  nixdoc,
  runCommand,
  ...
}: let
  vimLib = ../lib/default.nix;
  nixHighlightJS = builtins.fetchurl {
    url = "https://cdnjs.cloudflare.com/ajax/libs/highlight.js/10.1.1/languages/nix.min.js";
    sha256 = "sha256:06hn5qarzf8hhkm77icq3v9r2cmb5b1q8r234hi4hifkw06k5327";
  };
in
  stdenv.mkDerivation {
    name = "static docs";
    version = "1.0.0";

    src = ./.;
    buildInputs = [mdbook nixdoc];

    dontInstall = true;
    dontConfigure = true;

    buildPhase = ''
      mkdir -p $out
      nixdoc --category "nvim" \
             --description "nvim-utils library functions" \
             --file ${vimLib} > src/lib.md

      # remove extra fluff generated by nixdoc that we don't care about
      sed -z --in-place 's/`\n\n:/`/g' src/*.md
      sed --in-place '/:::/d' src/*.md

      mdbook build --dest-dir $out
    '';

    fixupPhase = ''
      cat ${nixHighlightJS} >> $out/highlight.js
    '';
  }
