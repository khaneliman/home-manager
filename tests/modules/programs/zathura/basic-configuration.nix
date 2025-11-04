{ ... }:

{
  programs.zathura = {
    enable = true;
    options = {
      default-bg = "#000000";
      default-fg = "#FFFFFF";
      statusbar-bg = "#333333";
      inputbar-bg = "#222222";
      pages-per-row = 2;
      scroll-hstep = 50;
      zoom-step = 0.1;
      selection-clipboard = "clipboard";
      recolor = true;
    };
    mappings = {
      D = "toggle_page_mode";
      "<Right>" = "navigate next";
      "<Left>" = "navigate previous";
      "[fullscreen] <C-i>" = "zoom in";
      "[normal] <C-b>" = "scroll left";
      "gr" = "reload";
    };
    extraConfig = ''
      # Additional custom configuration
      set window-title-basename true
      set adjust-open width
    '';
  };

  test.stubs.zathura = { };

  nmt.script = ''
    assertFileExists home-files/.config/zathura/zathurarc
    assertFileContent \
      home-files/.config/zathura/zathurarc \
      ${./basic-configuration-expected.zathurarc}
  '';
}
