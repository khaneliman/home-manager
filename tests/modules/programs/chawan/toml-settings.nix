{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = {
    programs.chawan = {
      enable = true;
      settings = {
        buffer = {
          images = true;
          autofocus = true;
          wordwrap = false;
        };
        page."C-k" = "() => pager.load('ddg:')";
        page."C-l" = "() => pager.load('localhost:8080')";
        display = {
          color_mode = "256";
          images = true;
        };
        search = {
          engine = "duckduckgo";
          case_insensitive = true;
        };
      };
    };

    nmt.script = ''
      assertFileExists home-files/.config/chawan/config.toml
      assertFileContent \
        home-files/.config/chawan/config.toml \
        ${./toml-settings-expected.toml}
    '';
  };
}
