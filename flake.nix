{
  description = "Neovim flake powered via Lazy.nvim";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";

    # plugins
    lazy-nvim = {
      url = "github:folke/lazy.nvim";
      flake = false;
    };
    rose-pine = {
      url = "github:rose-pine/neovim";
      flake = false;
    };
    tokyonight-nvim = {
      url = "github:folke/tokyonight.nvim";
      flake = false;
    };
    gitsigns-nvim = {
      url = "github:lewis6991/gitsigns.nvim";
      flake = false;
    };
    nvim-treesitter = {
      url = "github:nvim-treesitter/nvim-treesitter";
      flake = false;
    };
    nvim-lspconfig = {
      url = "github:neovim/nvim-lspconfig";
      flake = false;
    };
    null-ls-nvim = {
      url = "github:jose-elias-alvarez/null-ls.nvim";
      flake = false;
    };
    plenary-nvim = {
      url = "github:nvim-lua/plenary.nvim";
      flake = false;
    };
    lsp_lines = {
      url = "git+https://git.sr.ht/~whynothugo/lsp_lines.nvim";
      flake = false;
    };
    nvim-cmp = {
      url = "github:hrsh7th/nvim-cmp";
      flake = false;
    };
    cmp-nvim-lsp = {
      url = "github:hrsh7th/cmp-nvim-lsp";
      flake = false;
    };
    cmp-nvim-lua = {
      url = "github:hrsh7th/cmp-nvim-lua";
      flake = false;
    };
    cmp-async-path = {
      url = "github:felipelema/cmp-async-path";
      flake = false;
    };
    cmp-cmdline = {
      url = "github:hrsh7th/cmp-cmdline";
      flake = false;
    };
    cmp-buffer = {
      url = "github:hrsh7th/cmp-buffer";
      flake = false;
    };
    cmp_luasnip = {
      url = "github:saadparwaiz1/cmp_luasnip";
      flake = false;
    };
    luasnip = {
      url = "github:L3MON4D3/LuaSnip";
      flake = false;
    };
    friendly-snippets = {
      url = "github:rafamadriz/friendly-snippets";
      flake = false;
    };
    neovim-nightly.url = "github:neovim/neovim?dir=contrib";
    neovim-nightly.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    flake-utils,
    lazy-nvim,
    neovim-nightly,
    nixpkgs,
    rose-pine,
    tokyonight-nvim,
    ...
  } @ inputs:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        config = {};
        overlays = [];
      };
      mkNvimPackage = import ./package/nvim.nix {inherit pkgs;};
      configurations = import ./configurations;
      plugins = pkgs.lib.filterAttrs (x: _:
        !(builtins.elem x [
          "flake-utils"
          "lazy-nvim"
          "neovim-nightly"
          "nixpkgs"
          "self"
        ]))
      inputs;
      neovim-nightly' = inputs.neovim-nightly.packages.${system}.neovim.overrideAttrs (_finalAttrs: {
        patches = [];
      });
    in {
      # map each configuration to an individual package
      packages = builtins.mapAttrs (name: _:
        mkNvimPackage {
          configuration = configurations.${name};
          package = neovim-nightly';
          inherit plugins lazy-nvim;
        })
      configurations;
      # expose each package as an app
      apps = builtins.mapAttrs (name: _:
        flake-utils.lib.mkApp {
          drv = self.packages.${name};
          exePath = "/bin/nvim";
        })
      self.packages;

      # TODO: nixos + home-manager modules
      formatter = pkgs.alejandra;

      devShells.default = import ./shell.nix {inherit pkgs;};
    });
}
