{lib}:
with lib; {
  assertionModule = let
    # the type of an assertion
    assertion = lib.types.submodule {
      options = {
        assertion = lib.mkOption {
          type = types.bool;
          description = "assertion which must pass";
        };
        message = lib.mkOption {
          type = types.str;
          description = "message to output on assertion failure";
        };
      };
    };
  in {
    options = {
      assertions = mkOption {
        type = types.listOf assertion;
        description = "A list of assertions which must pass";
        default = [];
        visible = false;
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
