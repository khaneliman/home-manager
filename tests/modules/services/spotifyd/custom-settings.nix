{ ... }:

{
  services.spotifyd = {
    enable = true;
    settings = {
      global = {
        username = "testuser";
        device_name = "nix-spotifyd";
        backend = "pulseaudio";
        device_type = "computer";
        bitrate = 320;
        cache_path = "/tmp/spotifyd-cache";
        no_audio_cache = false;
        initial_volume = "90";
        volume_normalisation = true;
        normalisation_pregain = -10;
      };
      spotify = {
        client_id = "your_client_id";
        client_secret = "your_client_secret";
      };
    };
  };

  test.stubs.spotifyd = { };

  nmt.script = ''
    assertFileExists home-files/.config/systemd/user/spotifyd.service
    assertFileContent \
      home-files/.config/systemd/user/spotifyd.service \
      ${./custom-settings-expected.service}
  '';
}
