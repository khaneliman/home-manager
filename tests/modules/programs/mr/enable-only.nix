{
  config = {
    programs.mr.enable = true;

    nmt.script = ''
      assertFileExists home-files/.mrconfig
      assertFileContent home-files/.mrconfig ${builtins.toFile "expected-mrconfig" ""}
    '';
  };
}
