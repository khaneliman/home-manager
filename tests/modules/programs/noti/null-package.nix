{
  config = {
    programs.noti = {
      enable = true;
      package = null;
      settings = {
        banner = {
          message = "Test";
        };
      };
    };

    nmt.script = ''
      # Configuration file should still be created even with null package
      assertFileExists home-files/.config/noti/noti.yaml
      assertFileRegex home-files/.config/noti/noti.yaml 'banner:'
      assertFileRegex home-files/.config/noti/noti.yaml 'message.*Test'
    '';
  };
}
