{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.lsp.snippets;
  src =
    pkgs.vimPlugins.luasnip
    // {
      owner = "L3MON4D3";
      repo = "LuaSnip";
    };
in {
  options.lsp.snippets = {
    enable = mkEnableOption "snippet support. Uses `luasnip` under the hood";
    src = mkOption {
      type = types.package;
      description = lib.mdDoc ''
        Source to use for this plugin (note this source refers to the
        `luasnip` package to use, although you could swap this out for
        whatever you like (at the cost of functionality).
      '';
      default = src;
    };
    keys = mkOption {
      type = types.listOf types.attrs;
      description = lib.mdDoc ''
        A list of keybindings to set up for Luasnip. Follows standard lazy
        keymap spec.
      '';
      default = [];
    };
  };
  config = mkIf cfg.enable {
    lsp.completion.opts.snippet = {
      expand = lib.lua.rawLua "function(args) require('luasnip').lsp_expand(args.body) end";
    };
    lsp.completion.sources.luasnip.src = pkgs.fetchFromGitHub {
      owner = "saadparwaiz1";
      repo = "cmp_luasnip";
      rev = "05a9ab28b53f71d1aece421ef32fee2cb857a843";
      sha256 = "0gw3jz65dnxkc618j26zj37gs1yycf7wql9yqc9glazjdjbljhlx";
    };
    plugins = [
      {
        inherit (cfg) src keys;
        dependencies = [
          {
            src = pkgs.fetchFromGitHub {
              owner = "rafamadriz";
              repo = "friendly-snippets";
              rev = "5cc1f45c6aac699ad008fb85f6ae03236062667d";
              sha256 = "01dimq0nca103zss6qfxv07q7bnwsjd32pnncaz4bzmaia34w5kd";
            };
            config = lib.lua.rawLua ''
              function()
                require("luasnip.loaders.from_vscode").lazy_load()
              end,
            '';
          }
        ];
      }
    ];
  };
}
