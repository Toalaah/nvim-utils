{
  lib,
  toLua,
}: rec {
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

  /*
  Creates a lua keymap. Note that `opts` may be omitted when using this
  function. Although this results in a curried function, the internal keymap
  module takes care of this by automatically adding an empty option set at
  eval-time (see `modules/core/keymap.nix`).
  */
  mkKeymap = mode: lhs: rhs: opts: {inherit mode lhs rhs opts;};

  nmap = mkKeymap "n";
  nnoremap = lhs: rhs: opts: nmap lhs rhs (opts // {noremap = true;});

  vmap = mkKeymap "v";
  vnoremap = lhs: rhs: opts: vmap lhs rhs (opts // {noremap = true;});

  imap = mkKeymap "i";
  inoremap = lhs: rhs: opts: imap lhs rhs (opts // {noremap = true;});
}
