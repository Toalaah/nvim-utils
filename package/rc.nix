{
  cfg,
  lazy-nvim,
}: let
  wrapLuaConfig = luaCode: ''
    lua << EOF
    ${luaCode}
    EOF
  '';
in
  wrapLuaConfig ''
    ${cfg.preHooks}
    vim.opt.runtimepath:prepend('${lazy-nvim}')
    require('lazy').setup(${cfg.plugins}, ${cfg.lazy})
    ${cfg.vim.opt}
    ${cfg.vim.g}
    ${cfg.postHooks}
  ''
