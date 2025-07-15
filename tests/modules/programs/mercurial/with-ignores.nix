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
      userName = "Bob Wilson";
      userEmail = "bob.wilson@example.com";

      ignores = [
        "*.tmp"
        "*.log"
        "*~"
        ".DS_Store"
      ];

      ignoresRegexp = [
        "^.*\\.swp$"
        "^.*\\.orig$"
        "^build/.*"
      ];
    };

    test.stubs.mercurial = { };

    nmt.script = ''
      assertFileExists home-files/.config/hg/hgrc
      assertFileExists home-files/.config/hg/hgignore_global

      assertFileContent home-files/.config/hg/hgrc ${pkgs.writeText "expected-hgrc" ''
        [ui]
        ignore=/home/hm-user/.config/hg/hgignore_global
        username=Bob Wilson <bob.wilson@example.com>
      ''}

      assertFileContent home-files/.config/hg/hgignore_global ${./with-ignores-expected.hgignore}
    '';
  };
}
