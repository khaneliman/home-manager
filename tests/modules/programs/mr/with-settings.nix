{
  config = {
    programs.mr = {
      enable = true;
      settings = {
        foo = {
          checkout = "git clone git@github.com:joeyh/foo.git";
          update = "git pull --rebase";
        };
        ".local/share/password-store" = {
          checkout = "git clone git@github.com:myuser/password-store.git";
        };
        DEFAULT = {
          git_update = "git pull";
          git_status = "git status -s";
        };
      };
    };

    nmt.script = ''
      assertFileExists home-files/.mrconfig
      assertFileRegex home-files/.mrconfig '\[foo\]'
      assertFileRegex home-files/.mrconfig 'checkout.*git clone.*foo\.git'
      assertFileRegex home-files/.mrconfig 'update.*git pull --rebase'
      assertFileRegex home-files/.mrconfig '\[\.local/share/password-store\]'
      assertFileRegex home-files/.mrconfig 'checkout.*password-store\.git'
      assertFileRegex home-files/.mrconfig '\[DEFAULT\]'
      assertFileRegex home-files/.mrconfig 'git_update.*git pull'
      assertFileRegex home-files/.mrconfig 'git_status.*git status -s'
    '';
  };
}
