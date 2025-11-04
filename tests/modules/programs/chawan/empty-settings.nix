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
      settings = { };
    };

    nmt.script = ''
      assertPathNotExists home-files/.config/chawan
    '';
  };
}
