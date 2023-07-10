/*
This file defines the top-level options of `mkNvimConfig`, more specifically
options which are not directly plugin-specific.
*/
{
  config,
  pkgs,
  lib,
  ...
}: {
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
      description = lib.mdDoc ''
        Combined plugin spec passed to lazy.nvim startup function
      '';
      default = [];
    };

    rtp = lib.mkOption {
      type = lib.types.listOf lib.types.path;
      description = lib.mdDoc ''
        A list of paths to add to the `runtimepath`. The paths must be placed
        inside a parent folder named in accordance to where they should be
        in the `runtimepath`.

        For instance, if you wish to have a lua module `module.lua` to be
        available in the `rtp`, you must place it **inside** a folder named
        `lua`, then add this folder to `opt.rtp`.

        See `:h rtp` for more information.
      '';
      default = [];
    };

    # used internally for read-access to final derivation output path
    _rtpPath = lib.mkOption {
      type = lib.types.path;
      readOnly = true;
      internal = true;
      default = let
        mkRtp = import ./rtp.nix pkgs;
      in
        (mkRtp config.rtp).outPath;
    };

    lazy = lib.mkOption {
      type = lib.types.nullOr lib.types.attrs;
      description = lib.mdDoc ''
        Options passed to lazy.nvim startup function.

        Consult the project's [readme](https://github.com/folke/lazy.nvim) for
        all currently available options.
      '';
      example = lib.literalExpression ''
          {
            dev.path = "~/dev";
            defaults = {
              lazy = true;
            };
          }
        };
      '';
      default = {};
    };

    /*
    Defines an interface for specifiying vim options to set, for instance
    `vim.g` or `vim.opt`.
    */
    vim = let
      mkVimNamespaceOption = ns:
        lib.mkOption {
          type = lib.types.attrs;
          description = lib.mdDoc ''
            Values to set under the `vim.${ns}` namespace".

            Run `:help vim.o` for from inside the nvim process more information.
          '';
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
      type = lib.types.lines;
      description = lib.mdDoc "lua statements to be executed **before** lazy startup, newline separated";
      example = ''
        print('hello world')
      '';
      default = "";
    };

    postHooks = lib.mkOption {
      type = lib.types.lines;
      description = lib.mdDoc "lua statements to be executed **after** lazy startup, newline separated";
      example = ''
        print('hello world')
      '';
      default = "";
    };

    /*
    Extra packages to be included in the wrapped program's PATH
    */
    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      description = lib.mdDoc "Extra packages to be included in the wrapped program's PATH";
      example = lib.literalExpression ''
        [ pkgs.hello ]
      '';
      default = [];
    };
  };
}
