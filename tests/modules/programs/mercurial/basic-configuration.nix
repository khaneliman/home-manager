{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = {
    programs.mercurial = {
      enable = true;
      userName = "John Doe";
      userEmail = "john.doe@example.com";
    };

    test.stubs.mercurial = { };

    nmt.script = ''
      assertFileExists home-files/.config/hg/hgrc

      assertFileContent home-files/.config/hg/hgrc ${pkgs.writeText "expected-hgrc" ''
        [ui]
        username=John Doe <john.doe@example.com>
      ''}
    '';
  };
}
