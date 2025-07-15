{ ... }:

{
  programs.ncspot = {
    enable = true;
    package = null;
    settings = { };
  };

  nmt.script = ''
    assertPathNotExists home-files/.config/ncspot/config.toml
  '';
}
