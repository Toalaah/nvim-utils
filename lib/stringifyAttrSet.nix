{lib}: let
  /*
   Converts a primitive value to its stringified lua counterpart.

  Types `nil`, `boolean`, `number`, `string`, and `table` are convertable from
  their respective nix-equivalents. The types `function`, `userdata`, and
  `thread` are not able to be converted to.

   Example:
     x = { a = "foo"; b = null }
     processPrimitive x.a
     => "foo"
     processPrimitive x.b
     => "nil"

   Type:
     processPrimitive :: AttrSet -> String
  */
  processPrimitive = with builtins;
    value: let
      isNumber = x: isInt x || isFloat x;
      literalQuote = x: ''"${x}"'';
      stringifyBool = x:
        if x
        then "true"
        else "false";
    in
      if isString value
      then literalQuote value
      else if isNumber value
      then toString value
      else if value == null
      then "nil"
      else if isBool value
      then stringifyBool value
      else if isList value
      then "{${lib.concatStringsSep ", " (map processPrimitive value)}}"
      else if isPath value
      then literalQuote value
      else if isAttrs value
      then stringifyAttrs value
      else throw "Unsupported type: ${typeOf value}";

  /*
  Converts an attribute set into its stringified lua table representation.

  Since lua supports both named and unnamed table values (but nix attrsets do
  not), a magic identifier `__index__` is used to convert from named values to
  anonymous ones. This identified may occur anywhere inside the name. Note that
  since attrsets are implicitly sorted by key names, you will need to
  lexicographically sort the keys which you want to anonymize by hand, ex:
  `zzz__index__`.

  Example:
    x = { a = { b = 3; }; __index__baz = "some string"; c = "foo"; d = null; }
    stringifyAttrs x
    => ''
     { "some string", a = { b = 3 }, c = "foo", d = nil }
    ''

  Type:
    stringifyAttrs :: AttrSet -> String
  */
  stringifyAttrs = attrs: let
    listToStr = list: "${lib.concatStringsSep ", " list}";
    magicIdentifier = "__index__";
    hasSubstr = substr: string: builtins.length (lib.strings.splitString substr string) > 1;
    convertToLua = name: value:
      if hasSubstr magicIdentifier name
      then "${processPrimitive value}"
      else "${name} = ${processPrimitive value}";
  in
    "{" + listToStr (lib.mapAttrsToList convertToLua attrs) + "}";
in
  stringifyAttrs
