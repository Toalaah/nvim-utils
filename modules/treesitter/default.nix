{
  config,
  lib,
  pkgs,
  plugins,
  ...
}:
with lib; let
  cfg = config.treesitter;
  mkKeymapOptionFor = what: default:
    mkOption {
      type = types.str;
      inherit default;
      description = "keybinding for ${what}";
    };
  parsers = pkgs.symlinkJoin {
    name = "treesitter-parsers";
    paths = let
      parsers' = p: (builtins.map (x: p."${x}") config.treesitter.parsers);
    in
      (pkgs.vimPlugins.nvim-treesitter.withPlugins parsers').dependencies;
  };
in {
  options = {
    treesitter = {
      enable = mkEnableOption "treesitter";
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
          slug = "nvim-treesitter/nvim-treesitter";
          name = "nvim-treesitter";
          src = plugins.nvim-treesitter;
          main = "nvim-treesitter.configs";
          event = "BufReadPost";
          inherit (cfg) opts;
        }
      ];
      preHooks = "vim.opt.runtimepath:prepend('${parsers}')";
    })
  ];
}
