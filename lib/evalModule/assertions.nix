{lib}:
with lib; {
  assertionModule = let
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
  };

  testAssertions = assertions: let
    failedAssertions = map (x: x.message) (lib.filter (x: !x.assertion) assertions);
  in
    if failedAssertions == []
    then lib.id
    else throw "\nFailed assertions:\n${lib.concatMapStringsSep "\n" (x: "- ${x}") failedAssertions}";
}
