{
  config = {
    programs.bashmount = {
      enable = true;
      extraConfig = ''
        # Basic bashmount configuration
        show_info="true"
      '';
    };

    nmt.script = ''
      assertFileExists home-files/.config/bashmount/config
      assertFileContains home-files/.config/bashmount/config 'show_info="true"'
    '';
  };
}
