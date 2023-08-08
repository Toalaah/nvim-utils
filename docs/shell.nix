{pkgs ? (import (builtins.fetchTarball "https://github.com/NixOS/nixpkgs/archive/c2596b396ca0a0d9f82fa6e64839b37473008a58.tar.gz") {}), ...}:
with pkgs;
  mkShell {
    buildInputs = [
      mdbook
      mdbook-cmdrun
      nixdoc
    ];
    shellHook = ''
      export LIB=$(pwd)/../lib
      export PATH=$(pwd):$PATH
      export MDBOOK_ROOT=$(pwd)
    '';
  }
