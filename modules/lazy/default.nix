{
  config,
  lib,
  pkgs,
  ...
}: let
  src = pkgs.fetchFromGitHub {
    owner = "folke";
    repo = "lazy.nvim";
    rev = "d3974346b6cef2116c8e7b08423256a834cb7cbc";
    sha256 = "1k8nx3wgh87kv15qa023caqxbngajx1f2b44g8bvzxhs5jf1ldfh";
  };
  mkPlugNameDrv = plug:
    pkgs.stdenv.mkDerivation rec {
      src = plug.src;
      nativeBuildInputs = [pkgs.neovim];
      name = plug.name or plug.src.repo;
      phases = ["unpackPhase" "installPhase" "fixupPhase"];
      installPhase = ''
        target=$out/${name}
        mkdir -p $out
        cp -r . $target
      '';
      fixupPhase = ''
        if [ -d "$target/doc" ]; then
          nvim -N -u NONE -i NONE -n --cmd "helptags $target/doc" +quit!
        fi
      '';
    };
  lazyRoot = let
    nestedPlugins = lib.lists.flatten (builtins.map (p: p.dependencies or []) config.plugins);
    nestedPluginSpecs = builtins.filter (p: builtins.isAttrs p) nestedPlugins;
    allPlugins = config.plugins ++ nestedPluginSpecs;
  in
    pkgs.symlinkJoin {
      name = "lazy-root";
      paths = builtins.map mkPlugNameDrv allPlugins;
    };
  # lazy startup opts which must, under all circumstances, not be overwritten
  # in order to ensure proper functionality
  defaults = {
    performance.rtp.paths = [config._rtpPath];
    root = lazyRoot.outPath;
  };
in {
  options.lazy = {
    src = lib.mkOption {
      type = lib.types.package;
      description = lib.mdDoc ''
        Source to use for this plugin. This allows you to swap out the pinned
        version with a newer revision/fork or add patches by creating a
        wrapper derivation.
      '';
      default = src;
    };
    _readOnlyOpts = lib.mkOption {
      type = lib.types.attrsOf lib.types.unspecified;
      internal = true;
      readOnly = true;
      default = defaults;
    };
    opts = lib.mkOption {
      type = lib.types.attrsOf lib.types.unspecified;
      description = lib.mdDoc ''
        Options passed to lazy.nvim startup function.

        Consult the project's [readme](https://github.com/folke/lazy.nvim) for
        all currently available options.

        Note that some options, notably `root` are hard-coded inside the
        derivation and are not overridable.
      '';
      example = lib.literalExpression ''
        {
          dev.path = "~/dev";
          defaults = {
            lazy = true;
          };
        };
      '';
      default = {};
    };
  };
}
