{ config, ... }:

{
  config = {
    services.vdirsyncer = {
      enable = true;
      verbosity = "DEBUG";
    };

    nmt.script = ''
      assertFileExists home-files/.config/systemd/user/vdirsyncer.service
      assertFileContent \
        home-files/.config/systemd/user/vdirsyncer.service \
        ${./verbosity-options-expected.service}

      assertFileExists home-files/.config/systemd/user/vdirsyncer.timer
      assertFileContent \
        home-files/.config/systemd/user/vdirsyncer.timer \
        ${./verbosity-options-expected.timer}
    '';
  };
}
