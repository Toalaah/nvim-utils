{
  lib,
  toLua,
}: {
  /*
  processes each vim namespace (for example "vim.g" or "vim.o") into
  stringified lua code
  */
  processVimPrefs = ns: values:
    lib.strings.concatStringsSep "\n"
    (
      lib.mapAttrsToList
      (name: value: "vim.${ns}.${name} = ${toLua value}")
      values
    );
}
