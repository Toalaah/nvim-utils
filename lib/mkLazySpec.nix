{
  mkLazySpec = {
    pluginSlug,
    src,
    lazy,
    enabled,
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
