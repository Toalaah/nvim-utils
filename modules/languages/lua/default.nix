{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.languages.lua;
in {
  options = {
    languages.lua = {
      enable = mkEnableOption "lua";
      lspPkg = mkOption {
        type = types.package;
        default = pkgs.lua-language-server;
        description = "Lua language server package to use";
      };
      settings = mkOption {
        type = types.attrsOf types.anything;
        default = {
          single_file_support = true;
          Lua = {
            semantic = {enable = false;};
            diagnostics = {
              globals = ["vim"];
              unusedLocalExclude = ["_*"];
            };
            # expose custom lua modules to lsp config, for instance to enable goto definition.
            workspace.library = [config._rtpPath];
          };
        };
        description = lib.mdDoc ''
          server-configuration settings to pass to the lsp-config setup.
        '';
      };
    };
  };
  config = mkMerge [
    (mkIf cfg.enable {
      treesitter.parsers = ["lua"];

      lsp.null-ls.formatters = ["stylua"];
      extraPackages = lib.optionals config.lsp.null-ls.enable [pkgs.stylua];

      lsp.lsp-config.serverConfigurations.lua_ls = {
        cmd = ["${cfg.lspPkg}/bin/lua-language-server"];
        inherit (cfg) settings;
      };
    })
  ];
}
