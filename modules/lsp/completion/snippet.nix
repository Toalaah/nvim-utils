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
      rev = "98d9cb5c2c38532bd9bdb481067b20fea8f32e90";
      sha256 = "037sh4g1747wf07f9sqngiifp89hqww6m2rvizy5ra7jyd04magk";
    };
    plugins = [
      {
        inherit (cfg) src keys;
        dependencies = [
          {
            src = pkgs.fetchFromGitHub {
              owner = "rafamadriz";
              repo = "friendly-snippets";
              rev = "b2ea5c41a150ba72fb656eedb4ed0a86d138d945";
              sha256 = "07px3a8pq9yjhnr1pds0w2idzq9v8f5g4ccjvpimav0k5rd16nj8";
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
