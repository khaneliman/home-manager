{
  config = {
    programs.librewolf = {
      enable = true;
      package = null;
    };

    nmt.script = ''
      # With null package, librewolf should not be added to home.packages
      assertPathNotExists home-path/bin/librewolf
    '';
  };
}
