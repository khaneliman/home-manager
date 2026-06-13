{ lib, options, ... }:

{
  config = {
    test.asserts.warnings.expected = [
      (lib.concatStringsSep "\n" [
        "programs.man.man-db.extraConfig has no effect when programs.man.generateCaches is false"
        ""
        "Warning defined in ${lib.showFiles options.programs.man.man-db.extraConfig.files}."
      ])
    ];

    programs.man = {
      enable = true;
      generateCaches = false;
      man-db.extraConfig = ''
        MANDATORY_MANPATH /usr/man
        SECTION 1 n l 8
      '';
    };
  };
}
