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
    enable = mkEnableOption "snippet support. Uses `luasnip` under the hood.";
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
      rev = "18095520391186d634a0045dacaa346291096566";
      sha256 = "sha256-Z5SPy3j2oHFxJ7bK8DP8Q/oRyLEMlnWyIfDaQcNVIS0=";
    };
    plugins = [
      {
        inherit (cfg) src keys;
        dependencies = [
          {
            src = pkgs.fetchFromGitHub {
              owner = "rafamadriz";
              repo = "friendly-snippets";
              rev = "00e191fea2cfbbdd378243f35b5953296537a116";
              sha256 = "sha256-BWB14J4NaKapL+N5I4vYYgsHvN4C/Z6heN1h0Snszb4=";
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
