{ ... }:

{
  services.pueue = {
    enable = true;
    package = null;
    settings = { };
  };

  nmt.script = ''
    assertFileExists home-files/.config/pueue/pueue.yml
    assertPathNotExists home-files/.config/systemd/user/pueued.service
    assertPathNotExists home-path/bin/pueue
  '';
}
