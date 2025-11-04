{
  config = {
    programs.mr = {
      enable = true;
      package = null;
    };

    nmt.script = ''
      # Configuration file should still be created even with null package
      assertFileExists home-files/.mrconfig
      assertFileContent home-files/.mrconfig ${builtins.toFile "expected-mrconfig" ""}
    '';
  };
}
