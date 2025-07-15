{ config, ... }:

{
  config = {
    programs.fd = {
      enable = true;
      ignores = [
        ".git/"
        "*.bak"
        "node_modules/"
        "target/"
      ];
    };

    nmt.script = ''
      assertFileContent \
        home-files/.config/fd/ignore \
        ${./ignore-patterns-expected}
    '';
  };
}
