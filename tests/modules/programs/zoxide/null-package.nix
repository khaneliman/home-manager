{
  config = {
    programs.zoxide = {
      enable = true;
      package = null;
    };

    nmt.script = ''
      # With null package, zoxide should not be added to home.packages
      assertPathNotExists home-path/bin/zoxide
    '';
  };
}
