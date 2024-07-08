{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  src = pkgs.fetchFromGitHub {
    owner = "nvim-telescope";
    repo = "telescope.nvim";
    rev = "bfcc7d5c6f12209139f175e6123a7b7de6d9c18a";
    sha256 = "1ysbn67rlf2p63pp8155198a5v0hv5cn2bbhdjz9r5255y5f19sk";
  };
  cfg = config.telescope;
  configuredExtensions = builtins.mapAttrs (n: v:
    v
    // {
      module =
        if v.module == null
        then n
        else v.module;
    })
  cfg.extensions;
  extensionOpts = builtins.mapAttrs (_n: v: v.opts) configuredExtensions;
  extensionDeps = builtins.map (v: {inherit (v) src;}) (builtins.attrValues configuredExtensions);
in {
  imports = [
    ../util/plenary.nix
    ../util/devicons.nix
    # the extension sub-type
    ./extension.nix
  ];
  options.telescope = {
    enable = mkEnableOption (lib.mdDoc "telescope");
    src = mkOption {
      type = types.package;
      description = lib.mdDoc ''
        Source to use for this plugin. This allows you to swap out the pinned
        version with a newer revision/fork or add patches by creating a
        wrapper derivation.
      '';
      default = src;
    };
    keys = mkOption {
      type = types.listOf types.attrs;
      description = lib.mdDoc ''
        A list of keybindings to set up for telescope. follows standard lazy
        keymap spec.
      '';
      default = [];
    };
    opts = mkOption {
      type = types.attrs;
      default = {};
      description = mdDoc "Options to pass to `telescope`.";
    };
  };
  config = mkMerge [
    (mkIf cfg.enable {
      util.plenary.enable = true;
      util.devicons.enable = true;
      extraPackages = [pkgs.ripgrep pkgs.fd];
      plugins = [
        {
          cmd = "Telescope";
          inherit (cfg) src keys;
          config = lib.lua.rawLua ''
            function(_, opts)
              local telescope = require('telescope')
              telescope.setup(opts)
              ${
              lib.strings.concatMapStringsSep
              "\n" (v: "telescope.load_extension('${v.module}')")
              (builtins.attrValues configuredExtensions)
            }
            end
          '';
          opts = lib.attrsets.recursiveUpdate cfg.opts {
            extensions = extensionOpts;
          };
          dependencies =
            extensionDeps
            ++ [
              config.util.plenary.slug
              config.util.devicons.slug
            ];
        }
      ];
    })
  ];
}
