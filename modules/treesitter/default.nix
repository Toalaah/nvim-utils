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
    rev = "575f5a4b1fcb60c1ac4f560c46a5171454d674ca";
    hash = "sha256-WbOqur7pZVK/iJXbse6rRP0OyLkFDHxfIjMn8J+xOUU=";
  };
  cfg = config.treesitter;
  mkKeymapOptionFor = what: default:
    mkOption {
      type = types.str;
      inherit default;
      description = "keybinding for ${what}";
    };
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
  options = {
    treesitter = {
      enable = mkEnableOption "treesitter";
      src = mkOption {
        type = types.attrs;
        description = lib.mdDoc ''
          Source to use for this plugin. This allows you to swap out the pinned
          version with a newer revision/fork or add patches by creating a
          wrapper derivation.
        '';
        default = src;
      };
      parsers = mkOption {
        type = types.listOf types.str;
        description = "list of language parsers to install";
        default = [];
        example = lib.literalExpression ''
          [ "c" "lua" ]
        '';
      };
      opts = {
        highlight.enable = mkEnableOption "highlighting";
        incremental_selection = {
          enable = mkEnableOption "incremental_selection";
          keymaps = {
            init_selection = mkKeymapOptionFor "init_selection" "<CR>";
            node_incremental = mkKeymapOptionFor "node_incremental" "<CR>";
            node_decremental = mkKeymapOptionFor "node_decremental" "<BS>";
          };
        };
      };
    };
  };
  config = mkMerge [
    (mkIf cfg.enable {
      assertions = [];
      plugins = [
        {
          main = "nvim-treesitter.configs";
          event = ["BufReadPost" "BufNewFile"];
          inherit (cfg) src opts;
        }
      ];
      rtp = [parsers];
    })
  ];
}
