{pkgs ? (import <nixpkgs> {}), ...}:
with pkgs;
  mkShell {
    buildInputs = [
      alejandra
      deadnix
      git
      update-nix-fetchgit
    ];
  }
