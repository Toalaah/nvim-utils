/*
Defines the assertion type. Allows for checking module integrity via custom
validators
*/
{lib}:
with lib; let
  hasAttrOfType = attr: type: x:
    (builtins.hasAttr attr x) && (builtins.typeOf x.${attr} == type.name);
  assertionType = types.mkOptionType {
    name = "assertion";
    check = x: (hasAttrOfType "assertion" types.bool x) && (hasAttrOfType "message" lib.types.string x);
  };
in {
  options = {
    assertions = mkOption {
      type = types.listOf assertionType;
      description = "A list of assertions which must pass";
      default = [];
    };
  };
}
