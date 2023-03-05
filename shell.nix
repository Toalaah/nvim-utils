{pkgs, ...}:
with pkgs;
  mkShell {
    buildInputs = [
      alejandra
      deadnix
      vim
      gitAndTools
    ];
  }
