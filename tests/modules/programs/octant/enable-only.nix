{
  config = {
    programs.octant.enable = true;

    nmt.script = ''
      # With no plugins, no config directory should be created
      assertPathNotExists home-files/.config/octant/plugins
    '';
  };
}
