{
  config,
  lib,
  toLua,
  ...
}:
with lib; let
  _mkKeymapImpl = expr:
  # Small sanity check: `expr` must only be callable once, specifically, only
  # `opts` should be optional. See `lib/vim.nix` for more details.
  let
    missingArguments = !(builtins.isAttrs expr) && builtins.isFunction (expr {});
  in
    if missingArguments
    then throw "mkKeymap (or derivative thereof): missing argument(s)"
    else if (builtins.isFunction expr)
    then expr {}
    else expr;
  mkKeymap = key: let
    key' = _mkKeymapImpl key;
  in ''
    vim.keymap.set(
      ${toLua key'.mode},
      ${toLua key'.lhs},
      ${toLua key'.rhs},
      ${toLua key'.opts}
    )
  '';
  listOrSingletonOf = t: types.oneOf [(types.listOf t) t];
  strOrLuaFunction = types.oneOf [(types.functionTo types.str) types.str];
  # the type of a keymap
  keymap = types.submodule {
    options = {
      mode = mkOption {
        type = listOrSingletonOf (types.enum ["n" "v" "i" "o" "x" "s" "c" "t"]);
        default = "n";
      };
      lhs = mkOption {type = types.str;};
      rhs = mkOption {type = strOrLuaFunction;};
      opts = mkOption {
        type = types.attrs;
        default = {};
      };
    };
  };
in {
  options.keymaps = mkOption {
    # XXX: ordering in `oneOf` matters here!
    type = types.listOf (types.oneOf [(types.functionTo types.attrs) keymap]);
    default = [];
  };
  config = {
    preHooks = ''
      ${lib.strings.concatStringsSep "\n" (builtins.map mkKeymap config.keymaps)}
    '';
  };
}
