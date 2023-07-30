{
  config,
  lib,
  pkgs,
  ...
}: let
  src = pkgs.fetchFromGitHub {
    owner = "folke";
    repo = "lazy.nvim";
    rev = "da8b00581a52f5f87ad2aba9f52171fda7491f18";
    hash = "sha256-+sp8opLLJhZVb98IkqqKDbdKuKOhNIgnllySIr8zUKw=";
  };
  mkPlugNameDrv = plug: let
    src = plug.src;
    name = plug.name or src.repo;
  in
    pkgs.runCommand name {} ''
      mkdir -p $out
      cp -r ${src} $out/${name}
    '';
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
      type = lib.types.attrsOf lib.types.str;
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
