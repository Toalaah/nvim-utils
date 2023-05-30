{pkgs ? (import <nixpkgs> {}), ...}:
with pkgs;
  mkShell {
    buildInputs = [
      alejandra
      deadnix
      gitAndTools.git
    ];
  }
