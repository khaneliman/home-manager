{
  xdg.enable = true;
  xdg.localBinInPath = true;

  nmt.script = ''
    assertFileExists home-path/etc/profile.d/hm-session-vars.sh
    assertFileContains home-path/etc/profile.d/hm-session-vars.sh \
      '__hm_new="/home/hm-user/.local/bin"'
    assertFileContains home-path/etc/profile.d/hm-session-vars.sh \
      '__hm_cur="''${PATH-}"'
  '';
}
