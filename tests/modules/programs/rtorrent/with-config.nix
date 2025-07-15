{
  programs.rtorrent = {
    enable = true;
    extraConfig = ''
      # Download directory
      directory.default.set = ~/Downloads/rtorrent

      # Session directory
      session.path.set = ~/.local/share/rtorrent/session

      # Port range for incoming connections
      network.port_range.set = 49164-49164
      network.port_random.set = no

      # Enable DHT
      dht.mode.set = auto
      dht.port.set = 6881

      # Peer settings
      throttle.max_uploads.set = 100
      throttle.max_uploads.global.set = 250
      throttle.min_peers.normal.set = 20
      throttle.max_peers.normal.set = 60
      throttle.min_peers.seed.set = 30
      throttle.max_peers.seed.set = 80
    '';
  };

  nmt.script = ''
    assertFileExists home-files/.config/rtorrent/rtorrent.rc
    assertFileRegex home-files/.config/rtorrent/rtorrent.rc 'directory.default.set.*Downloads/rtorrent'
    assertFileRegex home-files/.config/rtorrent/rtorrent.rc 'session.path.set'
    assertFileRegex home-files/.config/rtorrent/rtorrent.rc 'network.port_range.set.*49164'
    assertFileRegex home-files/.config/rtorrent/rtorrent.rc 'dht.mode.set.*auto'
  '';
}
