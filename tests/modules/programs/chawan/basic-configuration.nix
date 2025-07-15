{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = {
    programs.chawan = {
      enable = true;
      package = null;
    };

    nmt.script = ''
      assertPathNotExists home-files/.config/chawan
    '';
  };
}
