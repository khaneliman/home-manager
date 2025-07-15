{
  config = {
    programs.noti.enable = true;

    nmt.script = ''
      # With empty settings, no config file should be created
      assertPathNotExists home-files/.config/noti/noti.yaml
    '';
  };
}
