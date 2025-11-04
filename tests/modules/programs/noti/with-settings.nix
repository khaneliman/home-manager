{
  config = {
    programs.noti = {
      enable = true;
      settings = {
        say = {
          voice = "Alex";
        };
        slack = {
          token = "1234567890abcdefg";
          channel = "@jaime";
        };
        banner = {
          message = "Command completed";
        };
      };
    };

    nmt.script = ''
      assertFileExists home-files/.config/noti/noti.yaml
      assertFileRegex home-files/.config/noti/noti.yaml 'say:'
      assertFileRegex home-files/.config/noti/noti.yaml 'voice.*Alex'
      assertFileRegex home-files/.config/noti/noti.yaml 'slack:'
      assertFileRegex home-files/.config/noti/noti.yaml 'token.*1234567890abcdefg'
      assertFileRegex home-files/.config/noti/noti.yaml 'channel.*@jaime'
      assertFileRegex home-files/.config/noti/noti.yaml 'banner:'
      assertFileRegex home-files/.config/noti/noti.yaml 'message.*Command completed'
    '';
  };
}
