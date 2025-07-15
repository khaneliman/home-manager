{
  programs = {
    pywal.enable = true;
    zsh.enable = true;
    kitty.enable = true;
    rofi.enable = true;
    neovim.enable = true;
  };

  xsession.windowManager.i3.enable = true;

  nmt.script = ''
    # Verify pywal package is available
    assertNotNull "$(command -v wal)"

    # Check zsh integration
    if [[ -f home-files/.zshrc ]]; then
      assertFileRegex home-files/.zshrc 'wal/sequences'
    fi

    # Check kitty integration
    if [[ -f home-files/.config/kitty/kitty.conf ]]; then
      assertFileRegex home-files/.config/kitty/kitty.conf 'colors-kitty.conf'
    fi

    # Check i3 integration
    if [[ -f home-files/.config/i3/config ]]; then
      assertFileRegex home-files/.config/i3/config 'set_from_resource.*i3wm.color'
    fi
  '';
}
