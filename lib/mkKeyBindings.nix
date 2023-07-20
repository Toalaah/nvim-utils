/*
Converts a list or single string into a table of keybindings. All standard
attributes in the keybinding (for example `desc`) are passed through.

The special attributes `lhs` and `rhs` are reserved and are used to define the
keybinding. These attributes are required for each object.

Optionally, a single string can be passed, which is simply passed through with
no changes.

Example:
  foo = [ { lhs = "<leader>o"; rhs = "lua print('hi')"; desc = "Print hello";  } ]

  mkKeyBindings foo
  => { keys = [
        {
          __index__0 = "<leader>o";
          __index__1 == "lua print('hi')";
          desc = "Print hello";
        } ]; }

Type:
  mkKeyBindings :: List[Attrs] | String -> Attrs
*/
keys: let
  mkKeyBindingsFromList = keys': let
    bindingType = builtins.typeOf (builtins.elemAt keys' 0);
  in
    # TODO: make this a submodule instead of type-checking directly
    if !(builtins.isAttrs keys' && builtins.hasAttr "lhs" keys' && builtins.hasAttr "rhs" keys')
    then throw "Keybinding must have 'lhs' and 'rhs' attributes"
    else if builtins.length keys == 0
    then []
    else if bindingType == "set"
    then builtins.map mapKeyToLazyKeyBindingSpec keys'
    else keys';

  mapKeyToLazyKeyBindingSpec = key:
    {
      __index__0 = key.lhs;
      __index__1 = key.rhs;
    }
    // (builtins.removeAttrs key ["lhs" "rhs"]);
in
  # for single string keybinding, ex keys = "<leader>x";
  if builtins.isString keys
  then {keys = keys;}
  # for more complex binding declarations, ex List[str] or List[LazyKeys]
  else if builtins.isList
  then {keys = mkKeyBindingsFromList keys;}
  else throw "Invalid type for 'keys'"