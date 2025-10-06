{ config, pkgs, ... }:

{
  config = {
    services.getmail = {
      enable = true;
      frequency = "hourly";
      package = pkgs.getmail6;
    };

    nmt.script = ''
      # Test systemd service file is created correctly
      assertFileContains \
        home-files/.config/systemd/user/getmail.service \
        "Description=getmail email fetcher"

      assertFileContains \
        home-files/.config/systemd/user/getmail.service \
        "@getmail6@/bin/getmail"

      # Test systemd timer file is created with custom frequency
      assertFileContains \
        home-files/.config/systemd/user/getmail.timer \
        "OnCalendar=hourly"

      assertFileContains \
        home-files/.config/systemd/user/getmail.timer \
        "WantedBy=timers.target"
    '';
  };
}
