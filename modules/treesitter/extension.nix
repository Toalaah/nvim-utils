{lib, ...}:
with lib; let
  # the type of a treesitter extension
  extension = types.submodule {
    options = {
      module = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = lib.mdDoc ''
          The name of the lua module to load for this extension. If not set,
          the attribute's name is used.
        '';
      };
      src = mkOption {
        type = types.package;
        description = lib.mdDoc ''
          Source to use for this plugin. This allows you to swap out the pinned
          version with a newer revision/fork or add patches by creating a
          wrapper derivation.
        '';
      };
      opts = mkOption {
        type = types.attrs;
        default = {};
        description = mdDoc ''
          Options to use for this extension. These are passed into treesitter's
          `extension` opts during setup.
        '';
      };
    };
  };
in {
  options.treesitter.extensions = mkOption {
    type = types.attrsOf extension;
    default = {};
    description = lib.mdDoc ''
      The set of treesitter extensions to make available.
    '';
  };
}
