{ config, ... }:

{
  config = {
    services.vdirsyncer = {
      enable = true;
      verbosity = "DEBUG";
    };

    nmt.script = ''
      assertFileContent \
        home-files/.config/systemd/user/vdirsyncer.service \
        ${./verbosity-options-expected.service}

      assertFileContent \
        home-files/.config/systemd/user/vdirsyncer.timer \
        ${./verbosity-options-expected.timer}
    '';
  };
}
