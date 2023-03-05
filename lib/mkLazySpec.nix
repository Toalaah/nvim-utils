{
  mkLazySpec = {
    pluginSlug,
    src,
    name,
    opts,
    lazy,
    enabled,
    cond,
    cmd,
    keys,
    ft,
    priority ? 50,
    ...
  }: ''
    {
      ${pluginSlug},
      dir = "${src}",
      lazy = ${lazy},
      enabled = ${enabled},
      priority = ${priority},
    }
  '';
}
