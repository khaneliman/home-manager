{
  programs.pylint = {
    enable = true;
    settings = {
      MASTER = {
        load-plugins = [ "pylint.extensions.docparams" ];
      };
      "MESSAGES CONTROL" = {
        disable = [
          "missing-docstring"
          "line-too-long"
        ];
      };
      FORMAT = {
        max-line-length = "88";
      };
    };
  };

  nmt.script = ''
    assertFileExists home-files/.pylintrc
    assertFileRegex home-files/.pylintrc 'load-plugins.*pylint.extensions.docparams'
    assertFileRegex home-files/.pylintrc 'disable.*missing-docstring'
    assertFileRegex home-files/.pylintrc 'max-line-length.*88'
  '';
}
