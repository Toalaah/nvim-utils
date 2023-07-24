{
  config,
  lib,
  toLua,
  ...
}:
with lib; let
  stringifyAutoCmd = au: ''
    vim.api.nvim_create_autocmd(${toLua au.event}, {
      pattern = ${toLua au.pattern},
      callback = ${toLua au.callback},
      group = ${toLua au.group},
      ${optionalString (au.description != null) "desc = ${toLua au.desc},"}
    })
  '';
  inherit (config) autocmds;
  optionalStrList = types.oneOf [(types.listOf types.str) types.str];
  strOrLuaFunction = types.oneOf [(types.functionTo types.str) types.str];
in {
  options.autocmds = mkOption {
    type = types.listOf (types.submodule {
      options = {
        event = mkOption {
          type = optionalStrList;
        };
        pattern = mkOption {
          type = optionalStrList;
        };
        description = mkOption {
          type = types.nullOr types.str;
          default = null;
        };
        group = mkOption {
          type = strOrLuaFunction;
        };
        # to be called w/ rawLua
        callback = mkOption {
          type = strOrLuaFunction;
        };
      };
    });
    default = [];
    description = "list of autocmds to set";
  };
  config = {
    postHooks = ''
      ${lib.strings.concatStringsSep "\n" (builtins.map stringifyAutoCmd autocmds)}
    '';
  };
}
