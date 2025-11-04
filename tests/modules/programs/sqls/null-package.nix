{
  config = {
    programs.sqls = {
      enable = true;
      package = null;
    };

    nmt.script = ''
      # With null package, sqls should not be added to home.packages
      assertPathNotExists home-path/bin/sqls
    '';
  };
}
