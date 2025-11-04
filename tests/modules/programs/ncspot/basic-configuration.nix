{ ... }:

{
  programs.ncspot = {
    enable = true;
    settings = {
      shuffle = true;
      gapless = true;
      use_nerdfont = true;
      backend = "pulseaudio";
      audio_cache = true;
      audio_cache_size = 1024;
      keybindings = {
        "q" = "quit";
        "s" = "shuffle";
        "r" = "repeat";
      };
    };
  };

  test.stubs.ncspot = { };

  nmt.script = ''
    assertFileExists home-files/.config/ncspot/config.toml
    assertFileContent \
      home-files/.config/ncspot/config.toml \
      ${./basic-configuration-expected.toml}
  '';
}
