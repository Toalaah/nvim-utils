{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  inherit (lib.lua) toLua rawLua;

  cfg = config.lsp.lsp-config;

  src = pkgs.fetchFromGitHub {
    owner = "neovim";
    repo = "nvim-lspconfig";
    rev = "ac478757efcde1ac346f7044ab774e7cbb482533";
    sha256 = "05nladrq3i3flja17pwfy3bqplys17s5ydyfrnd6rpk6fr4pcdjl";
  };

  mkServerConfig = name: value: let
    defaultConfig = {
      capabilities = rawLua "capabilities";
      on_attach = rawLua "on_attach";
    };
    serverConfig =
      defaultConfig
      // {inherit (value) cmd;}
      // value.extraOpts;
  in ''
    require('lspconfig')['${name}'].setup ${toLua serverConfig}
  '';

  # used for server capabilities if `config.lsp.completion` is enabled
  cmp-nvim-lsp = pkgs.fetchFromGitHub {
    owner = "hrsh7th";
    repo = "cmp-nvim-lsp";
    rev = "44b16d11215dce86f253ce0c30949813c0a90765";
    sha256 = "1ny64ls3z9pcflsg3sd7xnd795mcfbqhyan3bk4ymxgv5jh2qkcr";
  };

  serverConfigurations = lib.attrsets.mapAttrsToList mkServerConfig cfg.servers;
in {
  options.lsp.lsp-config = {
    enable = mkEnableOption (lib.mdDoc "lsp-config");
    src = mkOption {
      type = types.package;
      description = lib.mdDoc ''
        Source to use for this plugin (note this source refers to the
        `nvim-lspconfig` package to use, although you could swap this out for
        whatever you like (at the cost of functionality).
      '';
      default = src;
    };
    capabilities = mkOption {
      default = "vim.lsp.protocol.make_client_capabilities()";
      type = types.str;
      description = lib.mdDoc ''
        A stringified lua table which is inserted into each language
        server's setup function as the `capabilities` parameter.
      '';
    };
    onAttach = mkOption {
      default = builtins.readFile ./on_attach.lua;
      type = types.str;
      description = lib.mdDoc ''
        A stringified lua function which is inserted into each language
        server's setup function as the `on_attach` parameter.
      '';
    };
    servers = mkOption {
      default = {};
      description = lib.mdDoc ''
        A map of server names to their configuration. The configuration is
        passed to the `setup` function of the server.
      '';
      # the type of lspconfig server
      type = types.attrsOf (types.submodule {
        options = {
          cmd = mkOption {
            type = types.listOf types.str;
            description = lib.mdDoc ''
              The command used to start the language server. Each `argv` should be a separate list entry.
            '';
            example = lib.literalExpression ''
              cmd = [ "''${pkgs.myLanguageServer}/bin/my-lsp" "--stdio"];
            '';
          };
          extraOpts = mkOption {
            type = types.attrs;
            default = {};
            description = mdDoc ''
              Additional options to pass to the lsp server setup in
              `require('lspconfig')[<name>].setup(<opts>)`.

              Refer to the LSPconfig server [configuration
              documentation](https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md)
              for all available options.
            '';
          };
        };
      });
    };
  };

  config = mkMerge [
    (mkIf config.lsp.completion.enable {
      # TODO: vim.merge tables
      lsp.lsp-config.capabilities = "require('cmp_nvim_lsp').default_capabilities()";
      lsp.completion.sources.nvim_lsp.src = cmp-nvim-lsp;
    })
    (mkIf cfg.enable {
      assertions = [];
      plugins = [
        {
          event = ["BufReadPre" "BufNewFile"];
          inherit (cfg) src;
          config = rawLua ''
            function(_, _)
              local on_attach = ${cfg.onAttach};
              local capabilities = ${cfg.capabilities};
              ${lib.strings.concatStringsSep "\n" serverConfigurations}
            end
          '';
          dependencies = lib.optional config.lsp.completion.enable {src = cmp-nvim-lsp;};
        }
      ];
    })
  ];
}
