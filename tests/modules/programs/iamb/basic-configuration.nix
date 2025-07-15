{
  config = {
    programs.iamb.enable = true;

    nmt.script = ''
      assertFileExists home-files/.config/iamb/config.toml
    '';
  };
}
