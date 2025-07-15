{ config, ... }:

{
  config = {
    programs.fd = {
      enable = true;
    };

    nmt.script = ''
      # Test that fd is enabled but doesn't add extra shell aliases when no options are set
      assertFileNotRegex home-files/.bashrc \
        'alias fd='
    '';
  };
}
