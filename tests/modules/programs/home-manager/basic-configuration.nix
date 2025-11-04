{
  config = {
    programs.home-manager.enable = true;

    nmt.script = ''
      assertPathNotExists home-files/.config/home-manager
    '';
  };
}
