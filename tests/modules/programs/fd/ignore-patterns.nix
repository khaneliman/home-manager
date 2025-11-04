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
      assertFileExists home-files/.config/fd/ignore
      assertFileContent \
        home-files/.config/fd/ignore \
        ${./ignore-patterns-expected}
    '';
  };
}
