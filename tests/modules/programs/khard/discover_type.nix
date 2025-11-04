{
  accounts.contact = {
    basePath = ".contacts";
    accounts.test = {
      local.type = "filesystem";
      khard = {
        enable = true;
        type = "discover";
      };
    };
  };

  programs.khard.enable = true;

  nmt.script = ''
    assertFileExists home-files/.config/khard/khard.conf
    assertFileContent \
      home-files/.config/khard/khard.conf \
      ${./discover_type_expected}
  '';
}
