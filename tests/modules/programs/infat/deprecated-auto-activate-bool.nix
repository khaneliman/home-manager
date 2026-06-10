{ lib, options, ... }:

{
  programs.infat = {
    enable = true;
    autoActivate = false;
    settings = {
      extensions = {
        md = "TextEdit";
      };
    };
  };

  test = {
    asserts.warnings.expected = [
      ''
        Using `programs.infat.autoActivate` defined in ${lib.showFiles options.programs.infat.autoActivate.files} as a Boolean is deprecated and will be
        removed in a future release. Please use `programs.infat.autoActivate.enable` instead.
      ''
    ];

    stubs.infat = { };
  };

  nmt.script = ''
    assertFileNotRegex activate '.*@infat@/bin/infat'
  '';
}
