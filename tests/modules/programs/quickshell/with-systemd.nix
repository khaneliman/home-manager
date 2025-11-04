{
  programs.quickshell = {
    enable = true;
    systemd.enable = true;
  };

  nmt.script = ''
    serviceFile=home-files/.config/systemd/user/quickshell.service
    assertFileExists "$serviceFile"
    assertFileRegex "$serviceFile" "Description=quickshell"
    assertFileRegex "$serviceFile" "ExecStart=.*quickshell"
    assertFileRegex "$serviceFile" "WantedBy=.*target"
  '';
}
