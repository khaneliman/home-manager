{
  config = {
    programs.jrnl = {
      enable = true;
      package = null;
    };

    nmt.script = ''
      # Configuration file should still be created even with null package
      assertFileExists home-files/.config/jrnl/jrnl.yaml
      assertFileContent home-files/.config/jrnl/jrnl.yaml ${builtins.toFile "expected-jrnl.yaml" "{}\n"}
    '';
  };
}
