{ lib, options, ... }:

{
  config = {
    home.stateVersion = "26.05";

    programs.man = {
      enable = true;
      package = null;
      generateCaches = true;
    };

    test.asserts.warnings.expected = [
      (lib.concatStringsSep "\n" [
        "programs.man.generateCaches has no effect when programs.man.package is null"
        ""
        "Warning defined in ${lib.showFiles options.programs.man.generateCaches.files}."
      ])
    ];

    nmt.script = ''
      assertPathNotExists home-files/.manpath
    '';
  };
}
