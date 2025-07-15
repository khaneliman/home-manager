let
  testConfig = builtins.toFile "test-config.qml" ''
    import QtQuick 2.12
    Rectangle {
      color: "red"
      width: 100
      height: 100
    }
  '';
in
{
  programs.quickshell = {
    enable = true;
    configs = {
      "test" = testConfig;
    };
    activeConfig = "test";
  };

  nmt.script = ''
    assertFileExists home-files/.config/quickshell/test
    assertFileContent home-files/.config/quickshell/test ${testConfig}
  '';
}
