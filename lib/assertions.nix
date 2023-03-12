/*
Defines the assertion option type. Enabled checking of module integrity via
custom validators / assertions.
*/
{lib}:
with lib; let
  hasAttrOfType = attr: type: x:
    builtins.hasAttr attr x && type.check x.${attr};
  assertionType = types.mkOptionType {
    name = "assertion";
    check = x:
      hasAttrOfType "assertion" types.bool x
      && hasAttrOfType "message" types.str x;
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
