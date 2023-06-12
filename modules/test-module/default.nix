{
  config,
  lib,
  ...
}: {
  config = lib.mkMerge [
    {
      postHooks = ''
        require('module').hello()
        require('another-module').hello()
      '';

      rtp = [./lua];
    }
  ];
}
