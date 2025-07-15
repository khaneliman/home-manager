{
  config = {
    programs.afew = {
      enable = true;
      extraConfig = ''
        [SpamFilter]

        [Filter.0]
        query = from:boss@company.com
        tags = -new;+important;+boss
        message = Message from boss

        [Filter.1]
        query = from:noreply@github.com
        tags = -new;+github
        message = GitHub notification

        [InboxFilter]'';
    };

    nmt.script = ''
      assertFileExists home-files/.config/afew/config
      assertFileContent \
        home-files/.config/afew/config \
        ${./custom-config-expected.config}
    '';
  };
}
