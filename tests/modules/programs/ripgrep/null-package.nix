{ config, ... }:

{
  config = {
    programs.ripgrep = {
      enable = true;
      package = null;
      arguments = [
        "--smart-case"
        "--follow"
      ];
    };

    nmt.script = ''
      # Test that config is created even with null package
      assertFileExists home-files/.config/ripgrep/ripgreprc
      assertFileContent \
        home-files/.config/ripgrep/ripgreprc \
        ${./null-package-expected.conf}

      # Test that environment variable is still set
      assertFileRegex home-path/etc/profile.d/hm-session-vars.sh \
        'export RIPGREP_CONFIG_PATH=.*ripgreprc'
    '';
  };
}
