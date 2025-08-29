{
  config,
  lib,
  pkgs,
  ...
}:

{
  programs.gitui = {
    enable = true;
    theme = ./theme.ron;
    keyConfig = ./key_bindings.ron;
  };

  nmt.script = ''
    assertFileExists home-files/.config/gitui/theme.ron
    assertFileExists home-files/.config/gitui/key_bindings.ron

    # Test theme content from external file
    assertFileContent home-files/.config/gitui/theme.ron ${./theme.ron}

    # Test keyConfig content from external file  
    assertFileContent home-files/.config/gitui/key_bindings.ron ${./key_bindings.ron}
  '';
}
