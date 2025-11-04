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
      userName = "Jane Smith";
      userEmail = "jane.smith@example.com";

      aliases = {
        st = "status";
        co = "checkout";
        br = "branch";
        hist = "log --graph --pretty=format:'%h %d %s (%cr) <%an>'";
      };

      extraConfig = {
        extensions = {
          color = "";
          pager = "";
        };
        pager = {
          pager = "LESS='FRX' less";
        };
      };
    };

    test.stubs.mercurial = { };

    nmt.script = ''
      assertFileExists home-files/.config/hg/hgrc

      assertFileContent home-files/.config/hg/hgrc ${./ini-settings-expected.ini}
    '';
  };
}
