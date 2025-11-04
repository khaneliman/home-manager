{
  config,
  ...
}:

{
  config = {
    services.amberol = {
      enable = true;
      enableRecoloring = false;
      replaygain = "album";
    };

    assertions = [
      {
        assertion = config.dconf.settings."io/bassi/Amberol".background-play == true;
        message = "Expected background-play to be true.";
      }
      {
        assertion = config.dconf.settings."io/bassi/Amberol".enable-recoloring == false;
        message = "Expected enable-recoloring to be false.";
      }
      {
        assertion = config.dconf.settings."io/bassi/Amberol".replay-gain == "album";
        message = "Expected replay-gain to be 'album'.";
      }
    ];

    nmt.script = ''
      assertFileExists home-files/.config/systemd/user/amberol.service
      assertFileContent \
        home-files/.config/systemd/user/amberol.service \
        ${./custom-settings-expected.service}
    '';
  };
}
