{ config, ... }:

{
  config = {
    services.xidlehook = {
      enable = true;
    };

    nmt.script = ''
      assertFileExists home-files/.config/systemd/user/xidlehook.service
      assertFileRegex \
        home-files/.config/systemd/user/xidlehook.service \
        'ExecStart=.*xidlehook'
    '';
  };
}
