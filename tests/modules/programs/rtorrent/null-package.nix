{
  config = {
    programs.rtorrent = {
      enable = true;
      package = null;
    };

    nmt.script = ''
      # With null package, rtorrent should not be added to home.packages
      assertPathNotExists home-path/bin/rtorrent
    '';
  };
}
