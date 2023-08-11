{
  config,
  lib,
  ...
}:
with lib; let
  inherit (lib.lua) toLua;
  _mkKeymapImpl = expr:
  # Small sanity check: `expr` must only be callable once, specifically, only
  # `opts` should be optional. See `lib/vim.nix` for more details.
  let
    isMissingArguments = x: !(builtins.isAttrs x) && builtins.isFunction (x {});
  in
    if isMissingArguments expr
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
    description = lib.mdDoc ''
      List of keymaps to set. Refer to `vim.keymap.set` for usage
      and option documentation.
    '';
    # XXX: ordering in `oneOf` matters here!
    type = types.listOf (types.oneOf [(types.functionTo types.attrs) keymap]);
    default = [];
    example = lib.literalExpression ''
      [
        # syntactic sugar for setting a (non recursive) normal-mode keymap.
        (vim.nnoremap "<leader>p" (rawLua "function() print('hello world') end"))
        # note that you can also (but do not have to) pass additional keymap options
        (vim.nnoremap 'j'  "v:count == 0 ? 'gj' : 'j'"  "Move down"  { expr = true; silent = true; })
        # you can also just use raw attrsets if you prefer
        {
          mode = "n";
          lhs = "<leader>r";
          rhs = rawLua "function() print('hello world 2') end";
          opts = {desc = "print another cool message";};
        }
      ]
    '';
  };
  config = {
    preHooks = ''
      ${lib.strings.concatStringsSep "\n" (builtins.map mkKeymap config.keymaps)}
    '';
  };
}
