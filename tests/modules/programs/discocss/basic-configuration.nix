{ config, ... }:

{
  config = {
    programs.discocss = {
      enable = true;
      package = null;
    };

    nmt.script = ''
      assertFileExists home-files/.config/discocss/custom.css
      assertFileContent \
        home-files/.config/discocss/custom.css \
        ${builtins.toFile "empty-css" ""}
    '';
  };
}
