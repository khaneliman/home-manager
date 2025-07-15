{
  config = {
    programs.librewolf.enable = true;

    nmt.script = ''
      # LibreWolf should be installed but no custom config files created
      assertPathNotExists home-files/.librewolf/librewolf.overrides.cfg
      assertPathNotExists home-files/.librewolf/profiles.ini
    '';
  };
}
