{
  config,
  pkgs,
  lib,
  ...
}: {
  options = {
    plugins = lib.mkOption {
      # TODO: submodule
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

    _rtpPath = lib.mkOption {
      type = lib.types.path;
      readOnly = true;
      internal = true;
      default = let
        mkRtp = import ./mkRtp.nix pkgs;
      in
        (mkRtp config.rtp).outPath;
    };

    vim = let
      mkVimNamespaceOption = ns:
        lib.mkOption {
          type = lib.types.attrs;
          description = lib.mdDoc ''
            Values to set under the `vim.${ns}` namespace.

            Run `:help vim.o` for from inside the nvim process more information.
          '';
          default = {};
        };
    in {
      opt = mkVimNamespaceOption "opt";
      g = mkVimNamespaceOption "g";
    };

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
