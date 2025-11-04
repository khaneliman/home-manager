{
  config = {
    programs.java = {
      enable = true;
      package = null;
    };

    nmt.script = ''
      # With null package, java should not be added to home.packages
      assertPathNotExists home-path/bin/java
    '';
  };
}
