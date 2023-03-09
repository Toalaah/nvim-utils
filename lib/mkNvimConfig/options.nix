/*
This file defines the top-level options of `mkNvimConfig`.
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
      # TODO: add more concrete type-checking here
      type = lib.types.listOf lib.types.anything;
      description = ''
        Combined plugin spec passed to lazy.nvim startup function
      '';
      default = [];
    };

    /*
    Defines various lua commands to execute after lazy.nvim startup, separated
    by newlines. Like with `options.plugins`, these preferences are merged by
    each module.

    TODO: maybe "preferences" should be pure vim options (i.e `vim.opt`). This
    would allow defining commands via attrsets similar to how is done with
    `options.plugins` Arbitary commands could then be made possible via
    pre/post-hook options.

    */
    preferences = lib.mkOption {
      type = lib.types.str;
      description = ''
        List of vim-preferences / lua functions to execute, separated by \n.
        Called after lazy startup
      '';
      example = ''
        vim.opt.leader = ' '
        vim.cmd.colorscheme 'tokyonight'
      '';
      default = "";
    };
  };
}
