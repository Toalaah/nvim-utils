{
  config,
  lib,
  pkgs,
  rawLua,
  toLua,
  ...
}:
with lib; let
  cfg = config.lsp.lsp-config;
  src = pkgs.fetchFromGitHub {
    owner = "neovim";
    repo = "nvim-lspconfig";
    rev = "08f1f347c718e945c3b1712ebb68c6834182cf3a";
    hash = "sha256-TeGmo0axt1iUuPf2fkYAhIy6G5Kyr3R2Jtk8WJZfHU8=";
  };
  setupServer = name: opts: let
    serverConfig =
      {
        capabilities = rawLua "capabilities";
        on_attach = rawLua "on_attach";
      }
      // opts;
  in ''
    require('lspconfig')['${name}'].setup ${toLua serverConfig}
  '';
in {
  options.lsp.lsp-config = {
    enable = mkEnableOption (lib.mdDoc "lsp-config");
    src = mkOption {
      type = types.package;
      description = lib.mdDoc ''
        Source to use for this plugin. This allows you to swap out the pinned
        version with a newer revision/fork or add patches by creating a
        wrapper derivation.
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
    serverConfigurations = mkOption {
      default = {};
      # TODO: submodule type
      type = types.attrsOf types.attrs;
      description = lib.mdDoc ''
        A map of server names to their configuration. The configuration is
        passed to the `setup` function of the server. Only servers that are
        expicitly passed `servers` will be configured.
      '';
      # This value is set by enabling a language, ex `languages.lua.enable = true`.
      # It is not meant to be directly set by the user.
      internal = true;
      visible = false;
    };
  };

  config = mkMerge [
    (mkIf cfg.enable {
      assertions = [];
      plugins = [
        {
          event = ["BufReadPre" "BufNewFile"];
          inherit (cfg) src;
          config = rawLua ''
            function(_, _)
              local on_attach = ${toLua (rawLua cfg.onAttach)};
              local capabilities = ${toLua (rawLua cfg.capabilities)};
              ${lib.strings.concatStringsSep "\n" (lib.mapAttrsToList setupServer cfg.serverConfigurations)}
            end
          '';
        }
      ];
    })
  ];
}
