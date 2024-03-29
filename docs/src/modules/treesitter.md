<!-- This file is autogenerated at build time. If you want to make
documentation edits, refer to the original source file instead. -->

# Adding Treesitter Extensions

Since everyone has different needs in their workflow, we have opted **not** to
pre-configure any treesitter extensions. You can, however, quite easily add your
own in only a couple lines of code.

Let's use the very popular treesitter `playground` extension as an example. All
you have to to is declare the extension source from your configuration.
Registration with `treesitter` will be handled automatically.

```nix
{ pkgs, ... }: {
  treesitter.extensions.treesitter-playground = {
    # you can optionally specify `module` to override the name of the table
    # entry which is passed to `telescope.opts`. By default, the name of
    # the attribute set is used (in this case `treesitter-playground`), but
    # since we specified the `module` parameter explicitly, `playground` will be used
    # instead.
    module = "playground"
    src = pkgs.fetchFromGitHub {
      owner = "nvim-treesitter";
      repo = "playground";
      rev = "2b81a018a49f8e476341dfcb228b7b808baba68b";
      hash = "sha256-2wSTVSkuEvTAq3tB5yLw13WWpp1lAycCL4U1BKMm8Kw=";
    };
    # these values are passed under `opts.playground` in `treesitter.setup()`
    opts.enable = true;
  };
}
```

# Options

<!-- cmdrun options-to-md.sh treesitter -->
