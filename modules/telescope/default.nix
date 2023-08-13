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
    rev = "2d92125620417fbea82ec30303823e3cd69e90e8";
    hash = "sha256-BU6LFfuloNDhGSFS55sehZAX6mIqpD+R4X+sfu8aZwQ=";
  };
  cfg = config.telescope;
  enabledExtensions = lib.attrsets.filterAttrs (n: v: v.enable) cfg.extensions;
  extensionOpts = builtins.mapAttrs (n: v: v.opts) enabledExtensions;
  extensionDeps = builtins.map (v: {inherit (v) src;}) (builtins.attrValues enabledExtensions);
in {
  imports = [../util/plenary.nix ../util/devicons.nix];
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
    extensions.fzf = {
      enable = mkEnableOption (lib.mdDoc "fzf-native.nvim extension to telescope");
      module = mkOption {
        default = "fzf";
        readOnly = true;
        type = lib.types.str;
        description = lib.mdDoc ''
          The name of the lua module to load for this extension.
        '';
      };
      src = mkOption {
        type = types.package;
        description = lib.mdDoc ''
          Source to use for this plugin. This allows you to swap out the pinned
          version with a newer revision/fork or add patches by creating a
          wrapper derivation.
        '';
        default =
          pkgs.vimPlugins.telescope-fzf-native-nvim
          // {
            owner = "nvim-telescope";
            repo = "fzf-native.nvim";
          };
      };
      opts = mkOption {
        type = types.attrs;
        default = {};
        description = mdDoc ''
          Extension options to use for `fzf-native`. These are passed into
          telescope's opts during setup.
        '';
      };
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
              (builtins.attrValues enabledExtensions)
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
