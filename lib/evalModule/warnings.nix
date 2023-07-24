{lib}:
with lib; {
  warningModule = {
    options = {
      warnings = mkOption {
        type = types.listOf types.str;
        description = "A list of warnings to show to the user at build time";
        default = [];
      };
    };
  };

  evalWarnings = warnings:
    if warnings == []
    then lib.id
    else builtins.head (builtins.map (x: lib.warn x lib.id) warnings);
}
