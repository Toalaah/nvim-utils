{
  config,
  lib,
  toLua,
  ...
}:
with lib; let
  stringifyAutoCmd = let
    ifNotNull = value: field: lib.optionalString (value != null) "${field} = ${toLua value},";
    ifNotFalse = value: field: lib.optionalString value "${field} = ${toLua value},";
  in
    au: ''
      vim.api.nvim_create_autocmd(${toLua au.event}, {
        pattern = ${toLua au.pattern},
        ${ifNotNull au.callback "callback"}
        ${ifNotNull au.command "command"}
        ${ifNotNull au.group "group"}
        ${ifNotNull au.description "desc"}
        ${ifNotFalse au.once "once"}
        ${ifNotFalse au.nested "nested"}
      })
    '';
  inherit (config) autocmds;
  listOrSingletonOf = t: types.oneOf [(types.listOf t) t];
  strOrLuaFunction = types.oneOf [(types.functionTo types.str) types.str];
in {
  options.autocmds = mkOption {
    type = types.listOf (types.submodule {
      options = {
        event = mkOption {
          type = listOrSingletonOf strOrLuaFunction;
        };
        pattern = mkOption {
          type = listOrSingletonOf strOrLuaFunction;
        };
        description = mkOption {
          type = types.nullOr types.str;
          default = null;
        };
        group = mkOption {
          type = types.nullOr strOrLuaFunction;
          default = null;
        };
        # can be called w/ rawLua (if lua function is desired, else if string
        # callback is interpreted as vimscript fn)
        callback = mkOption {
          type = types.nullOr strOrLuaFunction;
          default = null;
        };
        command = mkOption {
          type = types.nullOr types.str;
          default = null;
        };
        once = mkOption {
          type = types.boolean;
          default = false;
        };
        nested = mkOption {
          type = types.boolean;
          default = false;
        };
      };
    });
    default = [];
    description = lib.mdDoc ''
      List of autocmds to set. Refer to `vim.api.nvim_create_autocmd` for usage
      and option documentation.
    '';
  };
  config = {
    assertions = let
      xor = a: b: (a == null) != (b == null);
      invalidAuCmds = lib.lists.filter (x: !(xor x.callback x.command)) autocmds;
    in
      builtins.map (
        _: {
          assertion = false;
          message = "autocmd: exactly one of `command` or `callback` must be specified";
        }
      )
      invalidAuCmds;
    postHooks = ''
      ${lib.strings.concatStringsSep "\n" (builtins.map stringifyAutoCmd autocmds)}
    '';
  };
}
