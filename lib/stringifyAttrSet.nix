{lib}: let
  /*
   Converts a primitive value to its stringified lua counterpart.

  Types `nil`, `boolean`, `number`, `string`, and `table` are convertable from
  their respective nix-equivalents. Functions are supported in limited a
  fashion; a passed function must be callable with exactly one argument (which
  should be ignored in the implementation). The function must return raw lua
  code (stringified). The following lambda is an example of such a valid
  function:

  foo = _: "function(msg) print('hello ' .. msg) end"

  The remaining types `userdata` and `thread` are not able to be converted to.

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
      stringifyList = "{${lib.concatStringsSep ", " (map processPrimitive value)}}";
      isNull = x: x == null;
    in
      if isString value
      then literalQuote value
      else if isNumber value
      then toString value
      else if isNull value
      then "nil"
      else if isBool value
      then stringifyBool value
      else if isList value
      then stringifyList value
      else if isPath value
      then literalQuote value
      /*
      Implies that the lambda must return a string which contains raw lua code
      (arguments are ignored)
      */
      else if isFunction value
      then value null
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
    hasSubstr = substr: string: (builtins.match ".*${substr}.*" string) != null;
    convertToLua = name: value:
      if hasSubstr magicIdentifier name
      then "${processPrimitive value}"
      else "${name} = ${processPrimitive value}";
  in
    "{" + listToStr (lib.mapAttrsToList convertToLua attrs) + "}";
in
  stringifyAttrs
