{
  config = {
    programs.afew = {
      enable = true;
    };

    nmt.script = ''
      assertFileExists home-files/.config/afew/config
      assertFileContent \
        home-files/.config/afew/config \
        ${./basic-configuration-expected.config}
    '';
  };
}
