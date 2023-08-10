# NixOS / Home Manager Modules

`nvim-utils` can also directly be used as a NixOS or Home Manager module.

You can import the NixOS module by adding `nvim-utils.nixosModules.nvim` to
your configuration imports.

```nix
# configuration.nix
{
  imports = [nvim-utils.nixosModules.nvim]
  # ...
  programs.nvim = {
    enable = true;
    configuraiton = {};
    modules = [];
  };
}
```

Similarly, you can import the Home Manager module to specify your configuration
in a `homeManagerConfiguration`. Again, you must add the module to Home
Manager's `extraSpecialArgs` when using flakes.

```nix
# flake.nix
# ...
outputs = {...}: {
}
```

```nix
# home.nix
{
  imports = [nvim-utils.homeManagerModules.nvim];
  programs.nvim = {
    enable = true;
    configuraiton = {};
    modules = [];
  };
}
```
