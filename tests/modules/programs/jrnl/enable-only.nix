{
  config = {
    programs.jrnl.enable = true;

    nmt.script = ''
      assertFileExists home-files/.config/jrnl/jrnl.yaml
      assertFileContent home-files/.config/jrnl/jrnl.yaml ${builtins.toFile "expected-jrnl.yaml" "{}\n"}
    '';
  };
}
