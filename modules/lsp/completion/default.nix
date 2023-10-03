{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.lsp.completion;
  src = pkgs.fetchFromGitHub {
    owner = "hrsh7th";
    repo = "nvim-cmp";
    rev = "5dce1b778b85c717f6614e3f4da45e9f19f54435";
    sha256 = "1yl5b680p6vhk1741riiwjnw7a4wn0nimjvcab0ij6mx3kf28rsq";
  };
  completionSourceDeps = builtins.map (v: {inherit (v) src;}) (builtins.attrValues cfg.sources);
  completionSourceOpts = lib.attrsets.mapAttrsToList (n: v:
    v.opts
    // {
      name =
        if v.name == null
        then n
        else v.name;
    })
  cfg.sources;
in {
  imports = [./snippet.nix];
  options.lsp.completion = {
    enable = mkEnableOption "completion support. Uses `nvim-cmp` under the hood";
    src = mkOption {
      type = types.package;
      description = lib.mdDoc ''
        Source to use for this plugin (note this source refers to the
        `nvim-cmp` package to use, although you could swap this out for
        whatever you like (at the cost of functionality).
      '';
      default = src;
    };
    opts = mkOption {
      type = types.attrs;
      default = {};
      description = mdDoc ''
        Additional options to pass to `cmp.setup()`. Note that for simple
        setups (ex: keybindings and sources), you do not need to pass anything
        to this option and should instead use the `keys` and `sources` options
        respectively (in fact, default keymaps are already set, although they
        may be overwritten using this option).

        The `nvim-cmp` module is made available in this scope under the variable
        name `cmp`.
      '';
      example = lib.literalExpression ''
        window = {
          completion = rawLua "cmp.config.window.bordered()";
          documentation = rawLua "cmp.config.window.bordered()";
        };
      '';
    };
    sources = mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          name = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = lib.mdDoc ''
              The name of the completion source module. If not set, the
              attribute's name is used.
            '';
          };
          src = mkOption {
            type = types.package;
            description = lib.mdDoc ''
              The source of the completion module.
            '';
          };
          opts = mkOption {
            type = types.attrs;
            default = {};
            example = lib.literalExpression ''
              {
                keyword_length = 5;
              }
            '';
            description = mdDoc ''
              Options to use for this completion source. Consult the nvim-cmp documentation for available options.
            '';
          };
        };
      });
      default = {};
      description = lib.mdDoc ''
        Extra cmp sources to make available during `cmp.setup()`.
      '';
    };
  };
  config = mkIf cfg.enable {
    plugins = [
      {
        event = ["InsertEnter"];
        dependencies = completionSourceDeps;
        opts = lib.lua.rawLua ''
          function()
            local cmp = require 'cmp'
            local opts = {
              sources = ${lib.lua.toLua completionSourceOpts},
              mapping = cmp.mapping.preset.insert({
                ["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
                ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
                ["<C-b>"] = cmp.mapping.scroll_docs(-4),
                ["<C-f>"] = cmp.mapping.scroll_docs(4),
                ["<C-Space>"] = cmp.mapping.complete(),
                ["<C-e>"] = cmp.mapping.abort(),
                ["<CR>"] = cmp.mapping.confirm({ select = true }),
                ["<S-CR>"] = cmp.mapping.confirm({
                  behavior = cmp.ConfirmBehavior.Replace,
                  select = true,
                }),
              }),
              completion = {
                autocomplete = {
                  cmp.TriggerEvent.TextChanged,
                  cmp.TriggerEvent.InsertEnter,
                },
              },
            }
            return vim.tbl_deep_extend(
              "force",
              opts,
              -- custom user-set option overrides
              ${lib.lua.toLua cfg.opts}
            )
          end
        '';
        inherit (cfg) src;
      }
    ];
  };
}
