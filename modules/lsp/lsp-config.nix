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
    rev = "e25994a1c2373784364852cd904cb39b6d75f227";
    sha256 = "18s6ngglynajysmvp0975lnbhavd1dckj87g0hyzbydrj73f401m";
  };

  mkServerConfig = name: value: let
    defaultConfig = {
      capabilities = rawLua "capabilities";
      on_attach = rawLua "on_attach";
    };
    serverConfig =
      defaultConfig
      // (
        if value.cmd == null
        then {}
        else {inherit (value) cmd;}
      )
      // value.extraOpts;
  in ''
    require('lspconfig')['${name}'].setup ${toLua serverConfig}
  '';

  # used for server capabilities if `config.lsp.completion` is enabled
  cmp-nvim-lsp = pkgs.fetchFromGitHub {
    owner = "hrsh7th";
    repo = "cmp-nvim-lsp";
    rev = "bd5a7d6db125d4654b50eeae9f5217f24bb22fd3";
    sha256 = "0yqcnpb6qkjyw1fk4zk66q2c9schxvascxqzk3mi7i7n0ykyjnjz";
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
            type = types.nullOr (types.listOf types.str);
            default = null;
            description = lib.mdDoc ''
              The command used to start the language server. Each `argv` should be a separate list entry.

              If you want to use the default lspconfig 'cmd' value, set this
              value to null (this is the default).
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
