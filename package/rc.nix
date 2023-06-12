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
    require('lazy').setup(${cfg.plugins}, ${cfg.lazy})
    ${cfg.vim.opt}
    ${cfg.vim.g}
    ${cfg.postHooks}
  ''
