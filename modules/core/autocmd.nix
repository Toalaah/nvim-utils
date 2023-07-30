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
          default = [];
          description = lib.mdDoc "Event(s) to trigger the autocommand on.";
        };
        pattern = mkOption {
          type = listOrSingletonOf strOrLuaFunction;
          default = [];
          description = lib.mdDoc "Pattern(s) to match against.";
        };
        description = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = lib.mdDoc "Description of the autocommand.";
        };
        group = mkOption {
          type = types.nullOr strOrLuaFunction;
          default = null;
          description = lib.mdDoc "Group of the autocommand.";
        };
        # can be called w/ rawLua (if lua function is desired, else if string
        # callback is interpreted as vimscript fn)
        callback = mkOption {
          type = types.nullOr strOrLuaFunction;
          description = lib.mdDoc ''
            lua / vimscript function to execute on trigger. Mutually exclusive
            with `command`.
          '';
          default = null;
        };
        command = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = lib.mdDoc ''
            The (vim) command to run on trigger. Mutually exclusive with
            `callback`
          '';
        };
        once = mkOption {
          type = types.bool;
          default = false;
          description = lib.mdDoc "Run the autocommand only once.";
        };
        nested = mkOption {
          type = types.bool;
          default = false;
          description = lib.mdDoc "Run any further nested autocommands.";
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
