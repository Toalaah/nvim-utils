{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  src = pkgs.fetchFromGitHub {
    owner = "nvim-treesitter";
    repo = "nvim-treesitter";
    rev = "bf0a96568a54618138ac42c84758945cdafef86b";
    sha256 = "1d05141a8bj4bdklwsss89nlrx3xfcjw5a5nyzcgmhfinr0jpznv";
  };
  cfg = config.treesitter;
  configuredExtensions = builtins.mapAttrs (n: v:
    v
    // {
      module =
        if v.module == null
        then n
        else v.module;
    })
  cfg.extensions;
  extensionOpts = builtins.mapAttrs (_n: v: v.opts) configuredExtensions;
  extensionDeps = builtins.map (v: {inherit (v) src;}) (builtins.attrValues configuredExtensions);
  parsers = pkgs.stdenv.mkDerivation {
    name = "parser";
    src = let
      parsers' = p: (builtins.map (x: p."${x}") config.treesitter.parsers);
    in
      (pkgs.vimPlugins.nvim-treesitter.withPlugins parsers').dependencies;
    phases = ["installPhase"];
    installPhase = ''
      mkdir -p $out
      find $src -name '*.so' -exec cp -r {} $out \;
    '';
  };
in {
  imports = [
    # the extension sub-type
    ./extension.nix
  ];
  options.treesitter = {
    enable = mkEnableOption (lib.mdDoc "treesitter");
    src = mkOption {
      type = types.package;
      description = lib.mdDoc ''
        Source to use for this plugin. This allows you to swap out the pinned
        version with a newer revision/fork or add patches by creating a
        wrapper derivation.
      '';
      default = src;
    };
    parsers = mkOption {
      type = types.listOf types.str;
      description = lib.mdDoc "list of language parsers to install";
      default = [];
      example = lib.literalExpression ''
        [ "c" "lua" ]
      '';
    };
    keys = mkOption {
      type = types.listOf types.attrs;
      description = lib.mdDoc ''
        A list of keybindings to set up for treesitter. follows standard lazy
        keymap spec.
      '';
      default = [];
    };
    opts = mkOption {
      type = types.attrs;
      default = {};
      description = mdDoc "Options to pass to `treesitter`.";
    };
  };
  config = mkMerge [
    (mkIf cfg.enable {
      plugins = [
        {
          inherit (cfg) src;
          main = "nvim-treesitter.configs";
          opts = lib.attrsets.recursiveUpdate cfg.opts extensionOpts;
          dependencies = extensionDeps;
          event = ["BufReadPost" "BufNewFile"];
        }
      ];
      rtp = [parsers];
    })
  ];
}
