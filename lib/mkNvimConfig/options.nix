/*
This file defines the top-level options of `mkNvimConfig`, more specifically
options which are not directly plugin-specific.
*/
{lib}: {
  options = {
    /*
    Defines an array of merged plugin specs. These specs are defined on a
    per-module basis.

    When executing `mkNvimConfig`, the merged specs are mapped to a
    lazy.nvim-compatible format and are then converted to stringified lua code,
    which is finally insered into the custom RC of the wrapped binary.
    */
    plugins = lib.mkOption {
      type = lib.types.listOf lib.types.attrs;
      description = ''
        Combined plugin spec passed to lazy.nvim startup function
      '';
      default = [];
    };

    lazy = lib.mkOption {
      type = lib.types.nullOr lib.types.attrs;
      description = ''
        Options passed to lazy.nvim startup function. See the project's readme
        for all currently available options.
      '';
      example = {
        dev.path = "~/dev";
        defaults.lazy = true;
      };
      default = null;
    };

    /*
    Defines an interface for specifiying vim options to set, for instance
    `vim.g` or `vim.opt`.
    */
    vim = let
      mkVimNamespaceOption = ns:
        lib.mkOption {
          type = lib.types.attrs;
          description = "values to set under the `vim.${ns}` namespace";
          default = {};
        };
    in {
      opt = mkVimNamespaceOption "opt";
      g = mkVimNamespaceOption "g";
    };

    /*
    Allows the user to specify pre-and-post hooks to run before and after lazy
    startup respectively.
    */
    preHooks = lib.mkOption {
      # TODO: types.lines?
      type = lib.types.listOf lib.types.str;
      description = "List of pieces of lua-code to execute before lazy startup";
      example = ["print('hello world')"];
      default = [];
    };

    postHooks = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = "List of pieces of lua-code to execute after lazy startup";
      example = ["print('hello world')"];
      default = [];
    };
  };
}
