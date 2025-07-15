{
  config,
  ...
}:

{
  config = {
    services.amberol = {
      enable = true;
    };

    assertions = [
      {
        assertion = config.dconf.settings."io/bassi/Amberol".background-play == true;
        message = "Expected background-play to be true.";
      }
      {
        assertion = config.dconf.settings."io/bassi/Amberol".enable-recoloring == true;
        message = "Expected enable-recoloring to be true (default).";
      }
      {
        assertion = config.dconf.settings."io/bassi/Amberol".replay-gain == "track";
        message = "Expected replay-gain to be 'track' (default).";
      }
    ];

    nmt.script = ''
      assertFileContent \
        home-files/.config/systemd/user/amberol.service \
        ${./basic-service-expected.service}
    '';
  };
}
