{
  home.stateVersion = "23.05";

  programs.beets = {
    enable = true;
    settings = {
      directory = "~/Music";
      library = "~/.config/beets/musiclibrary.db";

      import = {
        move = true;
        copy = false;
        write = true;
        resume = true;
        incremental = true;
        quiet_fallback = "skip";
      };

      plugins = [
        "lyrics"
        "duplicates"
        "replaygain"
        "web"
      ];

      lyrics = {
        auto = true;
        fallback = "''";
      };

      web = {
        host = "127.0.0.1";
        port = 8337;
        cors = true;
      };

      paths = {
        default = "%the{$albumartist}/$album%aunique{}/$track $title";
        singleton = "Non-Album/$artist - $title";
        comp = "Compilations/$album%aunique{}/$track $title";
      };
    };
  };

  nmt.script = ''
    assertFileExists home-files/.config/beets/config.yaml
    assertFileContent \
      home-files/.config/beets/config.yaml \
      ${./basic-configuration-expected.yaml}
  '';
}
