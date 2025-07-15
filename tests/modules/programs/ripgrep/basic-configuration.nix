{ config, ... }:

{
  config = {
    programs.ripgrep = {
      enable = true;
    };

    nmt.script = ''
      # Test that ripgrep is enabled but no config file is created with default settings
      assertPathNotExists home-files/.config/ripgrep/ripgreprc

      # Test that no environment variable is set
      assertFileNotRegex home-path/etc/profile.d/hm-session-vars.sh \
        'RIPGREP_CONFIG_PATH'
    '';
  };
}
